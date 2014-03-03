part of restlib.connector.http;

@visibleForTesting
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