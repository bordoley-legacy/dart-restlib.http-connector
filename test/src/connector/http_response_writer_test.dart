part of restlib.connector_test;

void httpResponseWriterTestGroup() {
  group("writeHttpResponse()", (){
    test("with fully composed Response", () {
      final int age = 10;
      final ImmutableSet<RangeUnit> acceptedRangeUnits =
          Persistent.EMPTY_SET; // FIXME:
      final ImmutableSet<Method> allowedMethods = 
          Persistent.EMPTY_SET.addAll([Method.GET, Method.PUT]);
      final ImmutableSet<ChallengeMessage> authenticationChallenges =
          Persistent.EMPTY_SET.add(
              CHALLENGE_MESSAGE.parse("basic realm=\"test\", encoding=\"UTF-8\"").value);
      final ImmutableSet<CacheDirective> cacheDirectives =
          Persistent.EMPTY_SET.add(CacheDirective.MAX_STALE);
      final ImmutableSequence<ContentEncoding> contentEncodings =
          Persistent.EMPTY_SEQUENCE; // FIXME
      final ImmutableSequence<Language> contentLanguages =
          Persistent.EMPTY_SEQUENCE; // FIXME      
      final int contentLength = 10;
      final Uri contentLocation = Uri.parse("htt://www.example.com");
      final ContentRange contentRange = null; // FIXME
      final MediaRange contentType = MediaRange.APPLICATION_ATOM;
      final DateTime date = null; // FIXME:
      final String entity = "hello";
      final EntityTag etag = new EntityTag.strong("abc");
      final DateTime expires = null; // FIXME:
      final DateTime lastModified = null; // FIXME
      final Uri location = Uri.parse("www.example.com");
      final DateTime retryAfter = null; // FIXME
      final UserAgent userAgent = USER_AGENT.parse("test/1.1").value;
      final Status status = Status.CLIENT_ERROR_BAD_REQUEST;
      final ImmutableSet<Header> varyHeaders =
          Persistent.EMPTY_SET.addAll([Header.ACCEPT, Header.CONTENT_TYPE]);
      final ImmutableSet<Warning> warnings =
          Persistent.EMPTY_SET; //FIXME
      
      final ContentInfo contentInfo =
          (new ContentInfoBuilder()
            ..length = contentLength
            ..location = contentLocation
            ..mediaRange = contentType
            ..range = contentRange
            ..addEncodings(contentEncodings)
            ..addLanguages(contentLanguages)
          ).build();
      
      final Response<String> response =
          (new ResponseBuilder<String>()
            ..age = age
            ..contentInfo = contentInfo
            ..date = date 
            ..entity = entity
            ..entityTag = etag
            ..expires = expires
            ..lastModified = lastModified
            ..location = location
            ..retryAfter = retryAfter
            ..server = userAgent
            ..status = status
            ..addAcceptedRangeUnits(acceptedRangeUnits)
            ..addAllowedMethods(allowedMethods)
            ..addAuthenticationChallenges(authenticationChallenges)
            ..addCacheDirectives(cacheDirectives)
            ..addProxyAuthenticationChallenges(authenticationChallenges)
            ..addVaryHeaders(varyHeaders)
            ..addWarnings(warnings)
          ).build();
      
      final Dictionary<String,String> headerToValues =
          new Dictionary<String, String>.wrapMap({
              // FIXME: HttpHeaders.ACCEPT_RANGES : response.acceptedRangeUnits,
              HttpHeaders.AGE : response.age,
              HttpHeaders.ALLOW : response.allowedMethods, 
              HttpHeaders.CACHE_CONTROL : response.cacheDirectives,
              // FIXME: HttpHeaders.CONTENT_ENCODING : response.contentInfo.encodings,
              // FIXME: HttpHeaders.CONTENT_LANGUAGE : response.contentInfo.languages,
              HttpHeaders.CONTENT_LOCATION : response.contentInfo.location,
              // FIXME: HttpHeaders.CONTENT_RANGE : response.contentInfo.range,
              HttpHeaders.CONTENT_TYPE : response.contentInfo.mediaRange,
              // FIXME: HttpHeaders.DATE : response.date,
              HttpHeaders.ETAG : response.entityTag,
              // FIXME: HttpHeaders.EXPIRES : response.expires,
              // FIXME: HttpHeaders.LAST_MODIFIED : response.lastModified,
              HttpHeaders.LOCATION : response.location,
              HttpHeaders.PROXY_AUTHENTICATE : response.proxyAuthenticationChallenges,
              // FIXME: HttpHeaders.RETRY_AFTER : response.retryAfter,
              HttpHeaders.SERVER : response.server,
              HttpHeaders.VARY : response.vary,
              // FIXME: HttpHeaders.WARNING : response.warnings,
              HttpHeaders.WWW_AUTHENTICATE : response.authenticationChallenges}).mapValues(Header.asHeaderValue);
      
      final MockHttpHeaders httpResponseHeaders =
          new MockHttpHeaders()
            ..when(callsTo("add"))
              .alwaysCall((final String header, final String value) =>
                  expect(headerToValues[header].value, equals(value)));
      
      final HttpResponse httpResponse = 
          new MockHttpResponse()
            ..when(callsTo("get headers")).alwaysReturn(httpResponseHeaders);     
      
      writeHttpResponse(response, httpResponse);
      
      headerToValues.keys.forEach((final String key) =>
          httpResponseHeaders.getLogs(callsTo("add", key, anything)).verify(happenedOnce));
    });
  });
}
