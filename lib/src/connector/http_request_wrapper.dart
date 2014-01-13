part of restlib.connector.http;

Option<Uri> _parseUri(final String uri) {
  checkNotNull(uri);

  if (uri.isEmpty) {
    return Option.NONE;
  } else {
    // FIXME: Try catch for exceptions.
    final Uri result = Uri.parse(uri);
    return new Option(result);
  }
}

abstract class _Parseable {
  HttpRequest get _request;
  
  Option _parse(final Parser parser, final String header) =>
      // FIXME: If the same headers is used more than once this doesn't work
      parser.parse(nullToEmpty(_request.headers.value(header)));
}

class _HttpRequestContentInfoImpl 
    extends Object 
    with ContentInfoToString,
      ContentInfoWith_,
      _Parseable
    implements ContentInfo {
  final HttpRequest _request;
  ImmutableSequence<ContentEncoding> _encodings;
  ImmutableSet<Language> _languages;
  Option<int> _length;
  Option<Uri> _location;
  Option<MediaRange> _mediaRange;
  Option<ContentRange> _range;

  _HttpRequestContentInfoImpl(this._request);
  
  ImmutableSequence<ContentEncoding> get encodings =>
      computeIfNull(_encodings, () {
        _encodings = 
            _parse(CONTENT_ENCODING_HEADER, HttpHeaders.CONTENT_ENCODING)
              .map((final Iterable<ContentEncoding> encodings) => 
                  Persistent.EMPTY_SEQUENCE.addAll(encodings))
              .orElse(Persistent.EMPTY_SEQUENCE);
            
        return _encodings;
      });
  
  ImmutableSet<Language> get languages =>
      computeIfNull(_languages, () {
        _languages = 
            _parse(CONTENT_LANGUAGE, HttpHeaders.CONTENT_LANGUAGE)
              .map((final Iterable<Language> languages) => 
                  Persistent.EMPTY_SET.addAll(languages))
              .orElse(Persistent.EMPTY_SET);    
            
        return _languages;
      });
 
  
  Option<int> get length =>
      computeIfNull(_length, () {
        _length = (_request.contentLength > -1) ? 
            new Option(_request.contentLength) : Option.NONE;
        return _length;
      });
  
  Option<Uri> get location =>
      computeIfNull(_location, () {
        _location = _parseUri(nullToEmpty(_request.headers.value(HttpHeaders.CONTENT_LOCATION)));
        return _location;
      });
  
  Option<MediaRange> get mediaRange =>
      computeIfNull(_mediaRange, () {
        _mediaRange = _parse(MEDIA_RANGE, HttpHeaders.CONTENT_TYPE);
        return _mediaRange;
      });
  
  Option<ContentRange> get range =>
      computeIfNull(_range, () {
        _range = _parse(CONTENT_RANGE, HttpHeaders.CONTENT_RANGE);
        return _range;
      });
}

class _HttpRequestPreconditionsImpl 
    extends Object 
    with RequestPreconditionsToString,
      RequestPreconditionsWith_,
      _Parseable
    implements RequestPreconditions {
  final HttpRequest _request;
  ImmutableSet<EntityTag> _ifMatch;
  Option<DateTime> _ifModifiedSince;
  ImmutableSet<EntityTag> _ifNoneMatch;
  Option<Either<EntityTag,DateTime>> _ifRange;
  Option<DateTime> _ifUnmodifiedSince;
  
  _HttpRequestPreconditionsImpl(this._request);
  
  ImmutableSet<EntityTag> get ifMatch =>
      computeIfNull(_ifMatch, () {
        _ifMatch = 
            _parse(IF_MATCH, HttpHeaders.IF_MATCH)
              .map((final Iterable<EntityTag> ifMatch) =>
                  Persistent.EMPTY_SET.addAll(ifMatch))
              .orElse(Persistent.EMPTY_SET);
        return _ifMatch;
      });
  
  Option<DateTime> get ifModifiedSince =>
      computeIfNull(_ifModifiedSince, () {
        _ifModifiedSince = 
            _parse(HTTP_DATE_TIME, HttpHeaders.IF_MODIFIED_SINCE);
        return _ifModifiedSince;
      });
  
  ImmutableSet<EntityTag> get ifNoneMatch =>
      computeIfNull(_ifNoneMatch, () {
        _ifNoneMatch = 
            _parse(IF_NONE_MATCH, HttpHeaders.IF_NONE_MATCH)
              .map((final Iterable<EntityTag> ifNoneMatch) => 
                  Persistent.EMPTY_SET.addAll(ifNoneMatch))
              .orElse(Persistent.EMPTY_SET);
        return _ifNoneMatch;
      });
  
  Option<Either<EntityTag,DateTime>> get ifRange =>
      computeIfNull(_ifRange, () {
        final String ifRange = nullToEmpty(_request.headers.value(HttpHeaders.IF_RANGE));
        _ifRange = new Option(
            ETAG.parse(ifRange)
              .map((final EntityTag tag) => 
                  new Either<EntityTag,DateTime>.leftValue(tag))
              .orCompute(() =>
                  HTTP_DATE_TIME.parse(ifRange)
                    .map((HttpDateTime date) => 
                        new Either.rightValue(date))
                    .orCompute(() => null)));
        return _ifRange;
      });
  
  Option<DateTime> get ifUnmodifiedSince =>
      computeIfNull(_ifUnmodifiedSince, () {
        _ifUnmodifiedSince = _parse(HTTP_DATE_TIME, HttpHeaders.IF_UNMODIFIED_SINCE);
        return _ifUnmodifiedSince;
      });
}

class _HttpRequestPreferencesImpl 
    extends Object 
    with RequestPreferencesToString,
      RequestPreferencesWith_,
      _Parseable
    implements RequestPreferences {
  final HttpRequest _request;
  ImmutableSet<Preference<Charset>> _acceptedCharsets;
  ImmutableSet<Preference<ContentEncoding>> _acceptedEncodings;
  ImmutableSet<Preference<Language>> _acceptedLanguages;
  ImmutableSet<Preference<MediaRange>> _acceptedMediaRanges;
  Option<Range> _range;
  
  _HttpRequestPreferencesImpl(this._request);
  
  ImmutableSet<Preference<Charset>> get acceptedCharsets =>
      computeIfNull(_acceptedCharsets, () {
        _acceptedCharsets = 
            _parse(ACCEPT_CHARSET, HttpHeaders.ACCEPT_CHARSET)
              .map((final Iterable<Preference<Charset>> acceptedCharsets) => 
                  Persistent.EMPTY_SET.addAll(acceptedCharsets))
              .orElse(Persistent.EMPTY_SET);
        return _acceptedCharsets;
      });
  
  ImmutableSet<Preference<ContentEncoding>> get acceptedEncodings =>
      computeIfNull(_acceptedEncodings, () {
        _acceptedEncodings = 
            _parse(ACCEPT_ENCODING, HttpHeaders.ACCEPT_ENCODING)
              .map((final Iterable<Preference<ContentEncoding>> acceptedEncodings) =>
                  Persistent.EMPTY_SET.addAll(acceptedEncodings))
              .orElse(Persistent.EMPTY_SET);
        return _acceptedEncodings;
      });
  
  ImmutableSet<Preference<Language>> get acceptedLanguages =>
      computeIfNull(_acceptedLanguages, () {
        _acceptedLanguages = 
            _parse(ACCEPT_LANGUAGE, HttpHeaders.ACCEPT_LANGUAGE)
              .map((final Iterable<Preference<Language>> acceptedLanguages) =>
                  Persistent.EMPTY_SET.addAll(acceptedLanguages))
              .orElse(Persistent.EMPTY_SET);    
            
        return _acceptedLanguages;
      });
  
  ImmutableSet<Preference<MediaRange>> get acceptedMediaRanges =>
      computeIfNull(_acceptedMediaRanges, () {
        _acceptedMediaRanges = 
            _parse(ACCEPT, HttpHeaders.ACCEPT)
              .map((final Iterable<Preference<MediaRange>> acceptedMediaRanges) =>
                  Persistent.EMPTY_SET.addAll(acceptedMediaRanges))
              .orElse(Persistent.EMPTY_SET);
        
        return _acceptedMediaRanges;
      });
  
  Option<Range> get range =>
      computeIfNull(_range, () {
        _range = _parse(RANGE, HttpHeaders.RANGE);
        return _range;
      });
}

class _HttpRequestWrapper
    extends Object 
    with RequestToString,
      RequestWith_,
      _Parseable
    implements Request {
  Option<ChallengeMessage> _authorizationCredentials;
  ImmutableSet<CacheDirective> _cacheDirectives;
  ContentInfo _contentInfo;
  ImmutableSet<Expectation> _expectations;
  final String _scheme;
  final HttpRequest _request;
  final Option entity = Option.NONE;
  Method _method;
  ImmutableSet<CacheDirective> _pragmaCacheDirectives;
  RequestPreconditions _preconditions;
  RequestPreferences _preferences;
  Option<ChallengeMessage> _proxyAuthorizationCredentials;
  Option<Uri> _referer;
  RoutableUri _uri;
  Option<UserAgent> _userAgent;

  // FIXME: Should take a protocol argument so that the request URI
  // gets the correct protocol
  _HttpRequestWrapper(this._request, this._scheme);

  Option<ChallengeMessage> get authorizationCredentials =>
      computeIfNull(_authorizationCredentials, () {
        _authorizationCredentials = _parse(CHALLENGE_MESSAGE, HttpHeaders.AUTHORIZATION);
        return _authorizationCredentials;
      });
  
  ImmutableSet<CacheDirective> get cacheDirectives =>
      computeIfNull(_cacheDirectives, () {
        _cacheDirectives = 
            _parse(CACHE_CONTROL, HttpHeaders.CACHE_CONTROL)
              .map((final Iterable<CacheDirective> cacheDirectives) =>
                  Persistent.EMPTY_SET.addAll(cacheDirectives))
              .orElse(Persistent.EMPTY_SET);
            
        return _cacheDirectives;
      });
  
  ContentInfo get contentInfo =>
      computeIfNull(_contentInfo, () {
        _contentInfo = new _HttpRequestContentInfoImpl(_request);
        return _contentInfo;
      });
  
  ImmutableSet<Expectation> get expectations =>
      computeIfNull(_expectations, () {
        _expectations = 
            _parse(EXPECT, HttpHeaders.EXPECT)
              .map((final Iterable<Expectation> expectations) =>
                  Persistent.EMPTY_SET.addAll(expectations))
              .orElse(Persistent.EMPTY_SET);
            
        return _expectations;
      });

  Method get method =>
      computeIfNull(_method, () {
        _method = new Method.forName(_request.method);
        return _method;
      });
  
  ImmutableSet<CacheDirective> get pragmaCacheDirectives =>
      computeIfNull(_pragmaCacheDirectives, () {
        _pragmaCacheDirectives = 
            _parse(PRAGMA, HttpHeaders.PRAGMA)
              .map((final Iterable<CacheDirective> pragmaCacheDirectives) =>
                  Persistent.EMPTY_SET.addAll(pragmaCacheDirectives))
              .orElse(Persistent.EMPTY_SET);
        return _pragmaCacheDirectives;
      });
  
  RequestPreconditions get preconditions =>
      computeIfNull(_preconditions, () {
        _preconditions = new _HttpRequestPreconditionsImpl(this._request);
        return _preconditions;
      });
  
  RequestPreferences get preferences =>
      computeIfNull(_preferences, () {
        _preferences = new _HttpRequestPreferencesImpl(this._request);
        return _preferences;
      });
  
  Option<ChallengeMessage> get proxyAuthorizationCredentials =>
      computeIfNull(_proxyAuthorizationCredentials, () {
        _proxyAuthorizationCredentials = _parse(CHALLENGE_MESSAGE, HttpHeaders.PROXY_AUTHORIZATION);
        return _proxyAuthorizationCredentials;
      });

  Option<Uri> get referer =>
      computeIfNull(_referer, () {
        _referer = _parseUri(nullToEmpty(_request.headers.value(HttpHeaders.REFERER)));
        return _referer;
      });

  RoutableUri get uri =>
      computeIfNull(_uri, () {
        final String host = nullToEmpty(_request.headers.value(HttpHeaders.HOST));
      
        // this is terribly hacky, but dart's URI class sucks.
        // FIXME: what if host is empty?
        final Uri hostPort = Uri.parse("//" + host);
        _uri = new RoutableUri.wrap(
            new Uri(
                scheme: _scheme,
                host: hostPort.host, 
                port: hostPort.port,
                path: _request.uri.path,
                query: _request.uri.query));
        return _uri;
      });
  
  Option<UserAgent> get userAgent =>
      computeIfNull(_userAgent, () {
        _userAgent = _parse(USER_AGENT, HttpHeaders.USER_AGENT);
        return _userAgent;    
      });
}

@visibleForTesting
Request wrapHttpRequest(final HttpRequest request, final String scheme) =>
    new _HttpRequestWrapper(request, scheme);