part of restlib.connector.http;

@visibleForTesting
void writeHttpResponse(final Response response, final HttpResponse serverResponse) {
  final HttpHeaders headers = serverResponse.headers;
  
  void write(final Header header, final value) {
    final String valueAsString = Header.asHeaderValue(value);
    if (valueAsString.isNotEmpty) {
      headers.set(header.toString(), valueAsString);
    }
  }
  
  serverResponse.statusCode = response.status.code;
  serverResponse.reasonPhrase = response.status.reason;
  response.contentInfo.length.map((final int length) => 
      serverResponse.contentLength = length);
  
  write(Header.ACCEPT_RANGES, response.acceptedRangeUnits);
  write(Header.AGE, response.age);
  write(Header.ALLOW, response.allowedMethods); 
  write(Header.CACHE_CONTROL, response.cacheDirectives);
  write(Header.CONTENT_ENCODING, response.contentInfo.encodings);
  write(Header.CONTENT_LANGUAGE, response.contentInfo.languages);
  write(Header.CONTENT_LOCATION, response.contentInfo.location);
  write(Header.CONTENT_RANGE, response.contentInfo.range);
  write(Header.CONTENT_TYPE, response.contentInfo.mediaRange);  
  write(Header.DATE, response.date);
  write(Header.ENTITY_TAG, response.entityTag);
  write(Header.EXPIRES, response.expires);
  write(Header.LAST_MODIFIED, response.lastModified);
  write(Header.LOCATION, response.location);
  write(Header.PROXY_AUTHENTICATE, response.proxyAuthenticationChallenges);
  write(Header.RETRY_AFTER, response.retryAfter);
  write(Header.SERVER, response.server);
  
  response.setCookies.forEach((final SetCookie setCookie) =>
      write(Header.SET_COOKIE, setCookie));
  
  write(Header.VARY, response.vary);
  write(Header.WARNING, response.warnings);
  write(Header.WWW_AUTHENTICATE, response.authenticationChallenges); 
  
  response.customHeaders.forEach((final Pair<Header, dynamic> header) => 
      write(header.fst, header.snd));
}