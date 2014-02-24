part of restlib.connector.http;

@visibleForTesting
void writeHttpResponse(final Response response, final HttpResponse serverResponse) {
  final HttpHeaders headers = serverResponse.headers;

  void write(final Header header, final value) {
    final String valueAsString = asHeaderValue(value);
    if (valueAsString.isNotEmpty) {
      headers.set(header.toString(), valueAsString);
    }
  }

  serverResponse.statusCode = response.status.code;
  serverResponse.reasonPhrase = response.status.reason;
  response.contentInfo.length.map((final int length) =>
      serverResponse.contentLength = length);

  write(ACCEPT_RANGES, response.acceptedRangeUnits);
  write(AGE, response.age);
  write(ALLOW, response.allowedMethods);
  write(CACHE_CONTROL, response.cacheDirectives);
  write(CONTENT_ENCODING, response.contentInfo.encodings);
  write(CONTENT_LANGUAGE, response.contentInfo.languages);
  write(CONTENT_LOCATION, response.contentInfo.location);
  write(CONTENT_RANGE, response.contentInfo.range);
  write(CONTENT_TYPE, response.contentInfo.mediaRange);
  write(DATE, response.date);
  write(ENTITY_TAG, response.entityTag);
  write(EXPIRES, response.expires);
  write(LAST_MODIFIED, response.lastModified);
  write(LOCATION, response.location);
  write(PROXY_AUTHENTICATE, response.proxyAuthenticationChallenges);
  write(RETRY_AFTER, response.retryAfter);
  write(SERVER, response.server);

  response.setCookies.forEach((final SetCookie setCookie) =>
      write(SET_COOKIE, setCookie));

  write(VARY, response.vary);
  write(WARNING, response.warnings);
  write(WWW_AUTHENTICATE, response.authenticationChallenges);

  response.customHeaders.forEach((final Pair<Header, dynamic> header) =>
      write(header.fst, header.snd));
}