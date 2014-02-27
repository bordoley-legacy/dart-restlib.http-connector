part of restlib.connector.http;

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
        Header.parser.parse(key).map((final Header header) {
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