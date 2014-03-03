part of restlib.connector.http;

final RestClient<Stream<List<int>>, Stream<List<int>>> dartIOStreamHttpClient = dartIOHttpClient(
      (_) => const Option.constant(const _StreamRequestWriter()),
      (_) => const Option.constant(_streamResponseParser));

RestClient dartIOHttpClient(final RequestWriterProvider requestWriterProvider,
                          final ResponseParserProvider responseParserProvider) =>
    new _DartIOHttpClient(requestWriterProvider, responseParserProvider);

class _StreamRequestWriter implements RequestWriter<Stream<List<int>>> {
  const _StreamRequestWriter();

  Request withContentInfo(final Request<Stream<List<int>>> request) =>
      request;

  Future write(final Request<Stream<List<int>>> request, StreamSink<List<int>> msgSink) =>
      msgSink.addStream(request.entity.value);
}

Future<Response<Stream<int>>> _streamResponseParser(final Response response, final Stream<List<int>> msgStream) =>
    new Future.value(response.with_(entity: msgStream));

class _DartIOHttpClient<TReq, TRes> implements RestClient<TReq, TRes> {
  final HttpClient _client;
  final RequestWriterProvider _requestWriterProvider;
  final ResponseParserProvider _responseParserProvider;

  _DartIOHttpClient(this._requestWriterProvider, this._responseParserProvider) :
    _client = new HttpClient() {
    //_client.findProxy = HttpClient.findProxyFromEnvironment;
  }

  Future<Response<TRes>> call(final Request<TReq> request) =>
      _client
        .open(request.method.toString(),
            request.uri.authority.value.host.value.toString(),
            request.uri.authority.value.port.orElse(80), // FIXME standard ports?
            request.uri.path.toString())
        .then((final HttpClientRequest httpRequest) {
          final HttpHeaders headers = httpRequest.headers;
          // FIXME: Zero out the default headers set by the connector.

          void writeHeaders(final Request request) =>
              writeRequestHeaders(request, (final String header, final String value) =>
                  headers.add(header, value));

          return request.entity
              .map((final entity) =>
                  _requestWriterProvider(request)
                    .map((final RequestWriter requestWriter) {
                      final Request requestWithContentInfo = requestWriter.withContentInfo(request);

                      writeHeaders(requestWithContentInfo);
                      return requestWriter.write(requestWithContentInfo, httpRequest);
                    }).orCompute(() =>
                        throw new StateError("Not RequestWriter available for entity")))
              .orCompute(() {
                writeHeaders(request);
                return new Future.value();
              }).then((_) => httpRequest.close());

        }).then((final HttpClientResponse httpResponse) {
          // FIXME: Use API provided by status to a status message that is const.
          final Status status = new Status(httpResponse.statusCode, httpResponse.reasonPhrase, "");
          final Response response = new Response.wrapHeaders(status, new _HeadersMultimap(httpResponse.headers));

          return _responseParserProvider(response.contentInfo)
            .map((final ResponseParser responseParser) =>
                responseParser(response, httpResponse))
            .orElse(response);
        });
}