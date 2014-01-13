part of restlib.connector_test;

void httpRequestWrapperTestGroup() {
  group("class:HttpRequestWrapper", () {
    test("with no headers present", () { 
      final HttpHeaders mockHttpHeaders =
          new MockHttpHeaders()
            ..when(callsTo("value"))
              .alwaysCall((final String header) =>
                  {"host" : "example.com"}[header]);
      
      final HttpRequest mockHttpRequest = 
          new MockHttpRequest()
          ..when(callsTo("get headers")).alwaysReturn(mockHttpHeaders)
          ..when(callsTo("get contentLength")).alwaysReturn(-1)
          ..when(callsTo("get method")).alwaysReturn(Method.PUT.toString())
          ..when(callsTo("get uri")).alwaysReturn(Uri.parse("/test"));

      final Request request = wrapHttpRequest(mockHttpRequest, "http");
      
      expect(request.authorizationCredentials, isEmpty);
      expect(request.cacheDirectives, isEmpty);
      expect(request.contentInfo.encodings, isEmpty);
      expect(request.contentInfo.languages, isEmpty);
      expect(request.contentInfo.length, isEmpty);
      expect(request.contentInfo.location, isEmpty);
      expect(request.contentInfo.mediaRange, isEmpty);
      expect(request.contentInfo.range, isEmpty);
      expect(request.entity, isEmpty);
      expect(request.expectations, isEmpty);
      expect(request.method, equals(Method.PUT));
      expect(request.pragmaCacheDirectives, isEmpty);
      expect(request.preconditions.ifMatch, isEmpty);
      expect(request.preconditions.ifModifiedSince, isEmpty);
      expect(request.preconditions.ifNoneMatch, isEmpty);
      expect(request.preconditions.ifRange, isEmpty);
      expect(request.preconditions.ifUnmodifiedSince, isEmpty);
      expect(request.preferences.acceptedCharsets, isEmpty);
      expect(request.preferences.acceptedEncodings, isEmpty);
      expect(request.preferences.acceptedLanguages, isEmpty);
      expect(request.preferences.acceptedMediaRanges, isEmpty);
      expect(request.proxyAuthorizationCredentials, isEmpty);
      expect(request.referer, isEmpty);
      expect(request.uri, equals(Uri.parse("http://example.com/test")));
      expect(request.userAgent, isEmpty);
    });
    
    test("with all headers present", () {
      final String scheme = "https";
      
      final ImmutableSet<Preference<Charset>> acceptedCharsets =
          Persistent.EMPTY_SET.addAll([new Preference(Charset.UTF_8), new Preference(Charset.US_ASCII)]);
      
      final ImmutableSet<Preference<ContentEncoding>> acceptedEncodings =
          Persistent.EMPTY_SET.addAll([]);     
      
      final ImmutableSet<Preference<Language>> acceptedLanguages =
          Persistent.EMPTY_SET.addAll([]);
      
      final ImmutableSet<Preference<MediaRange>> acceptedMediaRanges =
          Persistent.EMPTY_SET.addAll([new Preference(MediaRange.APPLICATION_ATOM), new Preference(MediaRange.APPLICATION_JSON)]);

      final ChallengeMessage authorizationCredentials =
          CHALLENGE_MESSAGE.parse("Basic dGVzdDp0ZXN0").value;
      
      ImmutableSet<CacheDirective> cacheDirectives =
          Persistent.EMPTY_SET.addAll([CacheDirective.MUST_REVALIDATE, CacheDirective.PRIVATE]);
      
      ImmutableSequence<ContentEncoding> contenEncodings =
          Persistent.EMPTY_SEQUENCE.addAll([]); 
      
      ImmutableSet<Language> contentLanguages =
          Persistent.EMPTY_SET.addAll([]);
      
      final int contentLength = 10;
      final Uri contentLocation = 
          Uri.parse("https://example.com/fake/content/location");
      
      final MediaRange contentMediaRange = 
          MEDIA_RANGE.parse("application/json; charset=\"UTF-8\"").value;
      
      ContentRange contentRange;
      
      ImmutableSet<Expectation> expectations =
          Persistent.EMPTY_SET.addAll([Expectation.EXPECTS_100_CONTINUE]);
     
      final String host = "www.example.com:8080";
      
      final ImmutableSet<EntityTag> ifMatch =
          Persistent.EMPTY_SET.addAll([ETAG.parse("\"abcd\"").value, ETAG.parse("W/\"efgh\"").value]);
      
      DateTime ifModifiedSince;
      
      final ImmutableSet<EntityTag> ifNoneMatch =
          Persistent.EMPTY_SET.addAll([ETAG.parse("\"abcd\"").value, ETAG.parse("W/\"efgh\"").value]);
      
      final EntityTag ifRange = ETAG.parse("\"abcd\"").value;
      DateTime ifUnmodifiedSince;
      
      final Method method = Method.PUT;
      final String path = "/test";
      
      ImmutableSet<CacheDirective> pragmaCacheDirectives =
          Persistent.EMPTY_SET.addAll([CacheDirective.PROXY_REVALIDATE, CacheDirective.NO_STORE]);
      
      //final Range range = "";
      
      final Uri referer = 
          Uri.parse("https://example.com/fake/referer");
      
      final Uri uri = Uri.parse("$scheme://$host$path");
      
      final UserAgent userAgent = USER_AGENT.parse("test/1.1").value;
      
      final Dictionary<String, String> values =
          new Dictionary<String, String>.wrapMap(
              {HttpHeaders.ACCEPT : acceptedMediaRanges,
               HttpHeaders.ACCEPT_CHARSET : acceptedCharsets,
               HttpHeaders.ACCEPT_ENCODING : acceptedEncodings,
               HttpHeaders.ACCEPT_LANGUAGE : acceptedLanguages,
               HttpHeaders.ACCEPT_RANGES : "", //FIXME:
               HttpHeaders.AUTHORIZATION : authorizationCredentials,
               HttpHeaders.CACHE_CONTROL : cacheDirectives,
               HttpHeaders.CONTENT_ENCODING : contenEncodings,
               HttpHeaders.CONTENT_LANGUAGE : contentLanguages,
               HttpHeaders.CONTENT_LENGTH  : "", //FIXME:
               HttpHeaders.CONTENT_LOCATION : contentLocation, 
               HttpHeaders.CONTENT_MD5 : "", //FIXME:
               HttpHeaders.CONTENT_RANGE : "", //FIXME:
               HttpHeaders.CONTENT_TYPE : contentMediaRange,
               HttpHeaders.EXPECT : expectations,
               HttpHeaders.FROM : "", //FIXME:
               HttpHeaders.HOST : host,
               HttpHeaders.IF_MATCH : ifMatch,
               HttpHeaders.IF_MODIFIED_SINCE : "", //FIXME:
               HttpHeaders.IF_NONE_MATCH : ifNoneMatch,
               HttpHeaders.IF_RANGE : ifRange,
               HttpHeaders.IF_UNMODIFIED_SINCE : "", //FIXME:
               HttpHeaders.PRAGMA : pragmaCacheDirectives,
               HttpHeaders.PROXY_AUTHORIZATION : authorizationCredentials,
               HttpHeaders.REFERER : referer,
               HttpHeaders.USER_AGENT : userAgent}).mapValues(Header.asHeaderValue);
      
      final HttpHeaders mockHttpHeaders =
          new MockHttpHeaders()
            ..when(callsTo("value"))
              .alwaysCall((final String header) =>
                  values[header].value);
      
      final HttpRequest mockHttpRequest = 
          new MockHttpRequest()
          ..when(callsTo("get headers")).alwaysReturn(mockHttpHeaders)
          ..when(callsTo("get contentLength")).alwaysReturn(contentLength)
          ..when(callsTo("get method")).alwaysReturn(method.toString())
          ..when(callsTo("get uri")).alwaysReturn(uri);
      
      final Request request = wrapHttpRequest(mockHttpRequest, scheme);
      
      expect(request.authorizationCredentials.value, equals(authorizationCredentials));
      expect(request.cacheDirectives, equals(cacheDirectives));
      expect(request.contentInfo.encodings, equals(contenEncodings));
      expect(request.contentInfo.languages, equals(contentLanguages));
      expect(request.contentInfo.length.value, equals(contentLength));
      expect(request.contentInfo.location.value, equals(contentLocation));
      expect(request.contentInfo.mediaRange.value, equals(contentMediaRange));
      expect(request.contentInfo.range, isEmpty);
      expect(request.entity, isEmpty);
      expect(request.expectations, equals(expectations));
      expect(request.method, equals(method));
      expect(request.pragmaCacheDirectives, equals(pragmaCacheDirectives));      
      expect(request.preconditions.ifMatch, equals(ifMatch));
      expect(request.preconditions.ifModifiedSince, isEmpty);
      expect(request.preconditions.ifNoneMatch, equals(ifNoneMatch));
      expect(request.preconditions.ifRange.value.value, equals(ifRange));
      expect(request.preconditions.ifUnmodifiedSince, isEmpty);
      expect(request.preferences.acceptedCharsets, equals(acceptedCharsets));
      expect(request.preferences.acceptedEncodings, equals(acceptedEncodings));
      expect(request.preferences.acceptedLanguages, equals(acceptedLanguages));
      expect(request.preferences.acceptedMediaRanges, equals(acceptedMediaRanges));
      expect(request.proxyAuthorizationCredentials.value, equals(authorizationCredentials));
      expect(request.referer.value, equals(referer));
      expect(request.uri, equals(uri));
      expect(request.userAgent.value, equals(userAgent));
    });
    
    test("with if-Range as date string", () {
      final HttpHeaders mockHttpHeaders =
          new MockHttpHeaders()
            ..when(callsTo("value"))
              .alwaysCall((final String header) =>
                  {HttpHeaders.IF_RANGE : ""}[header]);
      // FIXME:
      final HttpRequest mockHttpRequest = 
          new MockHttpRequest()
          ..when(callsTo("get headers")).alwaysReturn(mockHttpHeaders)
          ..when(callsTo("get contentLength")).alwaysReturn(-1)
          ..when(callsTo("get method")).alwaysReturn(Method.PUT.toString());
      final Request request = wrapHttpRequest(mockHttpRequest, "http");
      
      expect(request.preconditions.ifRange, isEmpty);
    });
  }); 
}