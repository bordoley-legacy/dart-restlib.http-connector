part of connector.http;

typedef HttpServerListener(HttpServer);

final Logger _logger = new Logger("restlib.connector.connector");

void _logError(final e) {
  if (e is Error) {
   _logger.severe("${e.toString()}\n${e.stackTrace.toString()}");
  } else {
    _logger.severe(e.toString());
  }
}

HttpServerListener httpServerListener(Application applicationSupplier(Request request), final String scheme) =>
    (final HttpServer server) {
      _logger.info("Listening on port: ${server.port}");

      server.listen((final HttpRequest serverRequest) =>
          processRequest(serverRequest, applicationSupplier, scheme),
          onError: _logError);
    };

@visibleForTesting
Future processRequest(final HttpRequest serverRequest, Application applicationSupplier(Request request), final String scheme) {
  Response internalServerError(final e) {
    _logError(e);
    return new Response(
        statuses.SERVER_ERROR_INTERNAL,
        entity : e);
  }

  Request parseRequest() {
    final Method method = new Method(serverRequest.method);
    final String host = nullToEmpty(serverRequest.headers.value(HttpHeaders.HOST));
    if (host.isEmpty) {
      // throw exception?
    }

    final Authority authority = Authority.parser.parseValue(host);

    final URI requestUri = new URI(
        scheme : scheme,
        authority : authority,
        path: URI.parser.parse(serverRequest.uri.path).value.path, // FIXME Kind of hacky
        query : serverRequest.uri.query);

    return new Request.wrapHeaders(method, requestUri, new _HeadersMultimap(serverRequest.headers));
  }

  void writeHttpResponse(final Response response, final HttpResponse serverResponse) {
    final HttpHeaders headers = serverResponse.headers;

    serverResponse.statusCode = response.status.code;
    serverResponse.reasonPhrase = response.status.reason;
    response.contentInfo.length.map((final int length) =>
        serverResponse.contentLength = length);

    // FIXME: Use headers.set to zero out default header values
    void writeHeaderLine(final String header, final String value) =>
        headers.add(header, value);

    writeResponseHeaders(response, writeHeaderLine);
  }

  Future writeResponse(final Request request, final Response response, Future write(Request request, Response response, StreamSink<List<int>> msgSink)) {
    checkNotNull(response);

    _logger.finest(response.toString());

    writeHttpResponse(response, serverRequest.response);

    if (response.entity.isNotEmpty) {
      return write(request, response, serverRequest.response);
    } else {
      return new Future.value();
    }
  }

  Future<Response> resourceProcessRequest(Request request, final IOResource resource) {
    request = resource.filterRequest(request);
    return resource.handle(request)
        .then((final Response response) {
          if (response.status != statuses.INFORMATIONAL_CONTINUE) {
            return response;
          }

          return resource
              .parse(request, serverRequest)
              .then((final Request requestWithEntity) {
                request = requestWithEntity;
                return request.entity
                    .map((_) =>
                        resource.acceptMessage(request))
                    .orElse(CLIENT_ERROR_BAD_REQUEST);

              // FIXME: Maybe parse should return Either<Request, ParseException> or Option
              }, onError: (final e) =>
                  CLIENT_ERROR_BAD_REQUEST);
        }).then(resource.filterResponse,
            onError: (final e) =>
                resource.filterResponse(internalServerError(e)));
  }

  Future applicationProcessRequest(Request request, final Application application) {
    request = application.filterRequest(request);
    final IOResource resource = application.route(request);
    return resourceProcessRequest(request, resource)
        .then(application.filterResponse,
            onError: (final e) =>
                // Catch any uncaught exceptions in the Future chain.
                application.filterResponse(internalServerError(e)))
        .catchError(internalServerError)
        .then((final Response response) =>
            writeResponse(request, response, resource.write));
  }

  Try<Future> tryApplicationProcessRequest(final Request request, final Application application) =>
      try_(() =>
          applicationProcessRequest(request, application))
        .catchError((e, final StackTrace st) =>
            writeResponse(request,internalServerError(e), application.writeError));

  Try<Future> tryProcessRequest(final Request request) =>
      try_(() =>
          applicationSupplier(request))
        .then(curry1(tryApplicationProcessRequest, [request]),
          onError: (e, StackTrace st) =>
              // FIXME: Ideally the server application would still be able to mutate the response
              writeResponse(request,internalServerError(e), writeString));

  _logger.finest("Received request from ${serverRequest.connectionInfo.remoteAddress}");
  // FIXME: consider having a default fall back request that a provider can route to and explicitly need to handle
  // as the bad request.
  // Ditto for internal server error.
  return try_(parseRequest)
      .then((final Request request) {
        _logger.finest(request.toString());
        return tryProcessRequest(request);
      }, onError: (e, StackTrace st) =>
          // FIXME: Ideally the server application would still be able to mutate the response
          writeResponse(null, statuses.CLIENT_ERROR_BAD_REQUEST.toResponse(), writeString))
      .catchError((e, final StackTrace st) => new Future.error(e))
      .value
      .catchError(_logError)
      .then((_) =>
          serverRequest.response.close())
      .catchError(_logError);
}
