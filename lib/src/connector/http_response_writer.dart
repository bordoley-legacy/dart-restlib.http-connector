part of restlib.connector.http;

@visibleForTesting
void writeHttpResponse(final Response response, final HttpResponse serverResponse) {
  final HttpHeaders headers = serverResponse.headers;
  
  void write(final String header, final value) {
    final String valueAsString = Header.asHeaderValue(value);
    if (valueAsString.isNotEmpty) {
      headers.add(header, valueAsString);
    }
  }
  
  serverResponse.statusCode = response.status.code;
  serverResponse.reasonPhrase = response.status.reason;
  response.contentInfo.length.map((final int length) => 
      serverResponse.contentLength = length);
  
  write(HttpHeaders.ACCEPT_RANGES, response.acceptedRangeUnits);
  write(HttpHeaders.AGE, response.age);
  write(HttpHeaders.ALLOW, response.allowedMethods); 
  write(HttpHeaders.CACHE_CONTROL, response.cacheDirectives);
  write(HttpHeaders.CONTENT_ENCODING, response.contentInfo.encodings);
  write(HttpHeaders.CONTENT_LANGUAGE, response.contentInfo.languages);
  write(HttpHeaders.CONTENT_LOCATION, response.contentInfo.location);
  write(HttpHeaders.CONTENT_RANGE, response.contentInfo.range);
  write(HttpHeaders.CONTENT_TYPE, response.contentInfo.mediaRange);
  write(HttpHeaders.DATE, response.date);
  write(HttpHeaders.ETAG, response.entityTag);
  write(HttpHeaders.EXPIRES, response.expires);
  write(HttpHeaders.LAST_MODIFIED, response.lastModified);
  write(HttpHeaders.LOCATION, response.location);
  write(HttpHeaders.PROXY_AUTHENTICATE, response.proxyAuthenticationChallenges);
  write(HttpHeaders.RETRY_AFTER, response.retryAfter);
  write(HttpHeaders.SERVER, response.server);
  write(HttpHeaders.VARY, response.vary);
  write(HttpHeaders.WARNING, response.warnings);
  write(HttpHeaders.WWW_AUTHENTICATE, response.authenticationChallenges);  
}