part of restlib.connector.http;

typedef HttpServerListener(HttpServer);

final Logger _logger = new Logger("restlib.connector.connector");

void _logError(final e) { 
  if (e is Error) {
   _logger.severe("${e.toString()}\n${e.stackTrace.toString()}");
  } else {
    _logger.severe(e.toString());
  }
}

Response _internalServerError(final e) {
  _logError(e);
  return new Response(
      Status.SERVER_ERROR_INTERNAL,
      entity : e);
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
  Future _writeResponse(final Request request, final Response response, Future write(Request request, Response response, StreamSink<List<int>> msgSink)) {
    checkNotNull(response);
    
    _logger.finest(response.toString());
    
    writeHttpResponse(response, serverRequest.response);
    
    if (response.entity.isNotEmpty) {
      return write(request, response, serverRequest.response);
    } else {
      return new Future.value();
    }
  }
  
  Future _doProcessRequest(Request request) {
    Future<Response> response;
    
    try {
      final Application application = applicationSupplier(request);
      
      try {
        request = application.filterRequest(request);
        final IOResource resource = application.route(request);
        request = resource.filterRequest(request);
        response = resource
            .handle(request)
            .then((final Response response) {
              if (response.status != Status.INFORMATIONAL_CONTINUE) {
                return response;
              }
                
              return resource
                  .parse(request, serverRequest)
                  .then((final Request requestWithEntity) {
                    request = requestWithEntity;
                    return resource.acceptMessage(request);
                  }, onError: (final e) => 
                      CLIENT_ERROR_BAD_REQUEST);
            }).then(resource.filterResponse, 
                onError: (final e) => 
                    resource.filterResponse(_internalServerError(e)))
            .then(application.filterResponse,
                onError: (final e) =>  
                    // Catch any uncaught exceptions in the Future chain.
                    application.filterResponse(_internalServerError(e)))
            .catchError(_internalServerError)
            .then((final Response response) =>
                _writeResponse(request, response, resource.write));
      } catch (e) {
        // Synchronous catch block for when application.filterReuqest(), application.route() or resource.handle() throw exceptions
        // Still attempt to filter the response first.
        try {
          response = _writeResponse(request,_internalServerError(e), application.writeError);
        } catch (e) {
          response = new Future.error(e);
        }
      }
    } catch (e) {
      // Synchronous catch block for when applicationSupplier throws exception
      // Also called if application.filterReuqest(), application.route() or resource.handle() throw exceptions and
      // application.filterResponse throws an exception.
      try {
        response = _writeResponse(request,_internalServerError(e), writeString);
      } catch (e) {
        response = new Future.error(e);
      }
    }
    
    return response;
  }
  
  _logger.finest("Received request from ${serverRequest.connectionInfo.remoteAddress}");
  
  // FIXME: This show block needs to be try catched.
  final Method method = new Method.forName(serverRequest.method);

  // FIXME: what if host is empty?
  
  final String host = nullToEmpty(serverRequest.headers.value(HttpHeaders.HOST));
  final Authority authority = AUTHORITY.parseValue(host);
  
  final URI requestUri = new URI(
      scheme : scheme,
      authority : authority,
      path: URI_.parse(serverRequest.uri.path).value.path, // FIXME Kind of hacky
      query : serverRequest.uri.query);
  
  
  final Request request = new Request.wrapHeaders(method, requestUri, new _HeadersMultimap(serverRequest.headers));
  
  _logger.finest(request.toString());
  
  return _doProcessRequest(request)
      .then((_) => 
          serverRequest.response.close(),
          onError: (final e) {
            _logError(e);
            serverRequest.response.close();
          })
      .catchError(_logError);
}

class _HeadersMultimap extends MultimapBase<Header, String, Sequence<String>> implements SequenceMultimap<Header,String> {
  Dictionary<Header, Sequence<String>> dictionary;
  
  _HeadersMultimap(final HttpHeaders headers) :
    dictionary = new _HeadersDictionary(headers);
  
  Sequence<String> get emptyValueContainer =>
      EMPTY_SEQUENCE;
}

class _HeadersDictionary extends DictionaryBase<Header, Sequence<String>> {
  final HttpHeaders headers;
  ImmutableSet<Header> _keys;
  
  _HeadersDictionary(this.headers);
  
  Iterator<Pair<Header, Sequence<String>>> get iterator =>
      new _HeadersIterator(this.headers, this.keys.iterator);
  
  Iterable<Header> get keys =>
    computeIfNull(_keys, (){
      ImmutableSet<Header> keys = EMPTY_SET;
      
      headers.forEach((final String key, final List<String> values) {
        HEADER.parse(key).map((final Header header) {
          keys = keys.add(header);
        });
      });
      
      _keys = keys;
      
      return _keys;
    });
 
  
  Option<Sequence<String>> operator[](final Header header) {
    final List<String> headerList = headers[header.toString()];
    return isNull(headerList) ? Option.NONE : new Option(new Sequence.wrapList(headerList));
  }
  
}

class _HeadersIterator implements Iterator<Pair<Header, Sequence<String>>> {
  final HttpHeaders _headers;
  final Iterator<Header> _keyItr;
  Pair<Header, Sequence<String>> _current = null;
  
  _HeadersIterator(this._headers, this._keyItr);
  
  Pair<Header, Sequence<String>> get current =>
      _current;
  
  bool moveNext() {
    if (_keyItr.moveNext()) {
      _current = new Pair(_keyItr.current, new Sequence.wrapList(_headers[_keyItr.current.toString()]));
      return true;
    }
    return false;
  }
}