part of connector.http_1_1;

class ChunkInfo {
  final int size;
  final Iterable<Pair<String, String>> extensions;

  ChunkInfo._(this.size, this.extensions);
}

IterableString convert(final List<int> bytes) => new IterableString.latin1(bytes);

class ChunkEncodedStreamTransformer implements StreamTransformer<List<int>, List<int>> {
  final int maxChunkSize;

  const ChunkEncodedStreamTransformer([this.maxChunkSize=8192]);

  Future<AsyncParseResult> _parseChunk(final Stream<List<int>> stream, final StreamController<List<int>> controller) =>
      CHUNK_INFO.parseAsync(stream, convert)
        .then((final AsyncParseResult<ChunkInfo> result) =>
            result.fold(
                (final ChunkInfo info) {
                  if (info.size > maxChunkSize) {
                    // FIXME: Add special error result for this case;
                  }

                  final LimitStream stream = new LimitStream(result.next, info.size);
                  return controller.addStream(stream)
                    .then((_) =>
                        CRLF.parseAsync(stream.remainder, convert).then((final AsyncParseResult result) =>
                            result.fold(
                                (_) => result,
                                (final FormatException e) {
                                  controller.addError(e);
                                  throw(e);
                                })));
                }, (_) => result));

  Future<AsyncParseResult> _parseNextChunk(final Stream<List<int>> stream, final StreamController<List<int>> controller) =>
      _parseChunk(stream, controller).then((final AsyncParseResult result) =>
          result.fold(
              (_) => _parseNextChunk(result.next, controller),
              (_) => (LAST_CHUNK + CRLF + _HEADERS + CRLF).parseAsync(result.next, convert)));

  Stream<List<int>> bind(final Stream<List<int>> stream) {
    StreamController<List<int>> controller;
    controller =  new StreamController(
        onListen: () => _parseNextChunk(stream, controller),
        onPause: () {/* FIXME */},
        onResume: () => {/* FIXME */},
        onCancel: () => {/* FIXME */},
        sync: false);

    return controller.stream;
  }
}
