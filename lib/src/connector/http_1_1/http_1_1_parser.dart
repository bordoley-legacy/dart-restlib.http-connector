part of connector.http_1_1;

final Parser<Response> RESPONSE = (_STATUS_LINE + _HEADERS + CRLF)
  .map((final Tuple3<Pair<HttpVersion, Status>, Iterable<Pair<Header, String>>, String> e) =>
      new Response.wrapHeaders(e.e0.e1, EMPTY_SEQUENCE_MULTIMAP.putAll(e.e1)));

final Parser<Iterable<Pair<Header,String>>> _HEADERS = _HEADER_FIELD.many();

final Parser<Pair<Header, String>> _HEADER_FIELD =
  (Header.parser + COLON + OWS + _FOLDABLE_FIELD_VALUE + OWS + CRLF).map(
      (final Tuple6<Header, int, IterableString, String, IterableString, String> e) =>
          new Pair(e.e0, e.e3));

final Parser<String> OBS_FOLD = (CRLF + WSP.many1()).map((_) => " ");

// FIXME: FIELD_VALUE defined in parsing internal is really field-content simplified not to check for no leading whitespace
final Parser<String> _FOLDABLE_FIELD_VALUE =
  (FIELD_VALUE.many1() | (OBS_FOLD as dynamic)).many()
    .map((final Iterable strings) =>
        (new StringBuffer()..writeAll(strings)).toString());

final Parser<IterableString> _REASON_PHRASE =  (HTAB | SP | VCHAR | OBS_TEXT).many();

final Parser<Pair<HttpVersion, Status>> _STATUS_LINE =
  (HttpVersion.parser + SP + _3_DIGIT + _REASON_PHRASE + CRLF)
    .map((final Tuple5<HttpVersion, int, int, IterableString, String> e) =>
        new Pair(e.e0, new Status(e.e2, e.e3.toString())));

final Parser<int> _3_DIGIT =
  (DIGIT + DIGIT + DIGIT).map((final Tuple3<int,int,int> e) =>
      e.e0 * 100 + e.e1 * 10 + e.e2);

final Parser<int> CHUNK_SIZE = HEXDIG.many1().map((final IterableString str) =>
    try_(() =>
        int.parse(str.toString(), radix:16))
          .catchError(
              (e, [st]) => null,
              test:(e) => e is FormatException).value).named("chunk-size");

final Parser<Pair<String, String>> CHUNK_EXTENSION =
  (SEMICOLON + TOKEN + (EQUALS + WORD).optional())
    .map((final Tuple3<int, String, Option<Pair<int, String>>> result) {
      final String fst = result.e1;
      final String snd = result.e2.map((final Pair<int, String> pair) => pair.e1).orElse("");

      return new Pair(fst, snd);
    });

final Parser<Iterable<Pair<String, String>>> LAST_CHUNK =
  (isChar("0").many1() + CHUNK_EXTENSION.many() + CRLF)
    .map((final Tuple3<IterableString, Iterable<Pair<String,String>>, String> e) => e.e1);

final Parser<ChunkInfo> CHUNK_INFO =
  (CHUNK_SIZE + CHUNK_EXTENSION.many() + CRLF)
    .map((Tuple3<int, Iterable<Pair<String, String>>, String> e) =>
        new ChunkInfo._(e.e0, e.e1));
