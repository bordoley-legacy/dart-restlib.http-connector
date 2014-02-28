part of restlib.connector.http;

RestClient createHttpClient(final RequestWriterProvider requestWriterProvider,
                          final ResponseParserProvider responseParserProvider) =>
    new _DartIOHttpClient(requestWriterProvider, responseParserProvider);



class _DartIOHttpClient implements RestClient {
  static void writeHeader(final HttpHeaders headers, final Header header, final value) {
    final String headerValue = asHeaderValue(value);
    if (value.isNotEmpty) {
      headers.add(header.toString(), headerValue);
    }
  }

  static void writeHeaders(final HttpHeaders headers, final Request request) {
    writeHeader(headers, AUTHORIZATION, request.authorizationCredentials);
    writeHeader(headers, CACHE_CONTROL, request.cacheDirectives);
    writeHeader(headers, CONTENT_ENCODING, request.contentInfo.encodings);
    writeHeader(headers, CONTENT_LANGUAGE, request.contentInfo.languages);
    writeHeader(headers, CONTENT_LENGTH, request.contentInfo.length);
    writeHeader(headers, CONTENT_LOCATION, request.contentInfo.location);
    writeHeader(headers, CONTENT_TYPE, request.contentInfo.mediaRange);
    writeHeader(headers, CONTENT_RANGE, request.contentInfo.range);
    writeHeader(headers, COOKIE, request.cookies);
    writeHeader(headers, EXPECT, request.expectations);
    writeHeader(headers, PRAGMA, request.pragmaCacheDirectives);
    writeHeader(headers, IF_MATCH, request.preconditions.ifMatch);
    writeHeader(headers, IF_MODIFIED_SINCE, request.preconditions.ifModifiedSince);
    writeHeader(headers, IF_NONE_MATCH, request.preconditions.ifNoneMatch);
    writeHeader(headers, IF_RANGE, request.preconditions.ifRange.map((final Either<EntityTag, DateTime> ifRange) => ifRange.value));
    writeHeader(headers, IF_UNMODIFIED_SINCE, request.preconditions.ifUnmodifiedSince);
    writeHeader(headers, ACCEPT_CHARSET, request.preferences.acceptedCharsets);
    writeHeader(headers, ACCEPT_ENCODING, request.preferences.acceptedEncodings);
    writeHeader(headers, ACCEPT_LANGUAGE, request.preferences.acceptedLanguages);
    writeHeader(headers, ACCEPT, request.preferences.acceptedMediaRanges);
    writeHeader(headers, RANGE, request.preferences.range);
    writeHeader(headers, PROXY_AUTHORIZATION, request.proxyAuthorizationCredentials);
    writeHeader(headers, REFERER, request.referer);
    writeHeader(headers, USER_AGENT, request.userAgent);

    request.customHeaders.forEach((final Pair<Header, dynamic> header) =>
        writeHeader(headers, header.fst, header.snd));
  }

  final HttpClient _client;
  final RequestWriterProvider _requestWriterProvider;
  final ResponseParserProvider _responseParserProvider;

  _DartIOHttpClient(this._requestWriterProvider, this._responseParserProvider) :
    _client = new HttpClient() {
    //_client.findProxy = HttpClient.findProxyFromEnvironment;
  }

  Future<Response> call(final Request request) =>
      _client
        .open(request.method.toString(),
            request.uri.authority.value.host.value.toString(),
            request.uri.authority.value.port.orElse(80), // FIXME standard ports?
            request.uri.path.toString())
        .then((final HttpClientRequest httpRequest) {
          final HttpHeaders headers = httpRequest.headers;

          return request.entity
              .map((final entity) =>
                  _requestWriterProvider(request)
                    .map((final RequestWriter requestWriter) {
                      final Request requestWithContentInfo = requestWriter.withContentInfo(request);

                      writeHeaders(headers, requestWithContentInfo);
                      return requestWriter.write(requestWithContentInfo, httpRequest);
                    }).orCompute(() =>
                        throw new StateError("Not RequestWriter available for entity")))
              .orCompute(() {
                writeHeaders(headers, request);
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