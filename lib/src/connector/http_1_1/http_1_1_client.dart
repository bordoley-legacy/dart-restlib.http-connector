part of connector.http_1_1;

typedef Future<Socket> SocketProvider(URI authority);

// FIXME: Provide a higher level abstraction class for following redirects, max redirects, etc.

class Http_1_1_Client<TReq, TRes> {
  final SocketProvider _socketProvider;

  Http_1_1_Client(this._socketProvider);

  RequestHandle<TRes> call(Request<TRes> request) =>
      new _RequestHandle(request, _socketProvider);
}

class _RequestHandle implements RequestHandle<Stream<List<int>>> {
  final Request<Stream<List<int>>> request;
  final SocketProvider socketProvider;
  final StreamController<RequestStateEvent> requestStateStreamController;

  Option<Socket> _socket = Option.NONE;
  Future<Response<Stream<List<int>>>> _result = null;

  _RequestHandle(this.request, this.socketProvider)
      : this.requestStateStreamController = new StreamController();

  Future<Response<Stream<List<int>>>> _start() =>
      socketProvider(request.uri).then((final Socket socket) {
        this._socket = new Option(socket);

        requestStateStreamController.add(RequestStateEvent.CONNECTION_ESTABLISHED);

        socket.add(request.without(entity: true).toString().codeUnits);
        requestStateStreamController.add(RequestStateEvent.HEADERS_SENT);

        return request.expectations[Expectation.EXPECTS_100_CONTINUE]
          .map((_) => parseResponse(socket))
          .orCompute(() =>
              new Future.value(
                  statuses.INFORMATIONAL_CONTINUE.toResponse().with_(entity: socket)))
          .then((final Response<Stream<List<int>>> response) {
            if (response.status != statuses.INFORMATIONAL_CONTINUE) {
              return response;
            }

            request.entity.map((final Stream<List<int>> entityStream) =>
                socket.addStream(entityStream));

            return parseResponse(response.entity.value)
                .then((final Response<Stream<List<int>>> response) =>
                    // FIXME: check if the stream is actually chunked encoded.
                    // Need to add API to response or not filter out the TransferEncoding header
                    // from the custom headers.
                    response.entity
                      .map((final Stream<List<int>> entity) =>
                          response.with_(entity: new ChunkEncodedStreamTransformer().bind(entity)))
                      .orElse(response));
          });
      });

  Future<Response<Stream<List<int>>>> parseResponse(final Stream<List<int>> stream) =>
      RESPONSE.parseAsync(stream, (final List<int> bytes) => new IterableString.latin1(bytes))
        .then((final AsyncParseResult<Response> parseResult) =>
            parseResult.fold(
                (final Response response) =>
                    response.with_(entity: parseResult.next),
                (final FormatException e) {}));

  Stream<RequestStateEvent> get requestState =>
      requestStateStreamController.stream;

  Future<Response<Stream<List<int>>>> get response =>
      computeIfNull(_result, () {
        _result = _start();
        return _result;
      });

  Future cancel() =>
      _socket
        .map((final Socket socket) => socket.close())
        .orCompute(() => throw new StateError("no socket"));
}