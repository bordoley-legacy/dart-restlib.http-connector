part of connector.http_1_1;

abstract class ClientConnection implements Stream<List<int>> {
  factory ClientConnection(final RawSocket socket) =>
      new _ClientConnection(checkNotNull(socket));

  Stream<int> add(final List<int> bytes);
  Stream<int> addStream(final Stream<List<int>> bytes);

  Future close();
}

class _ClientConnection extends Stream<List<int>> implements ClientConnection {
  final RawSocket _rawSocket;
  final Queue<Tuple3<List<int>, StreamController, bool>> writeQueue = new Queue();

  Option<StreamController> _streamController = Option.NONE;
  Option<StreamSubscription> _subscription = Option.NONE;

  _ClientConnection(this._rawSocket);

  StreamSubscription _subscribe() =>
      _subscription.orCompute(() {
        _rawSocket.listen(
            (final RawSocketEvent ev) {
              if (ev == RawSocketEvent.READ) {
                _streamController.map((final StreamController controller) => controller.add(_rawSocket.read()));
              } else if (ev == RawSocketEvent.WRITE) {
                _tryWrite();
              }
            },
            onError: (e,st) {
              _streamController.map((final StreamController controller) => controller.addError(e, st));
            }, onDone: (){
              _streamController.map((final StreamController controller) => controller.close());
              writeQueue.forEach((final Tuple3<List<int>, StreamController, bool> next) =>
                  next.e1.close());
              writeQueue.clear();
            },
            cancelOnError: true);
      });

  void _tryWrite() {
    while(writeQueue.isNotEmpty) {
      final Tuple3<List<int>, StreamController, bool> next = writeQueue.removeFirst();
      final int result = _rawSocket.write(next.e0);
      next.e1.add(result);

      if (result != next.e0.length) {
        writeQueue.addFirst(Tuple.create3(sublist(next.e0, result), next.e1, next.e2));
        break;
      }

      if (next.e2) {
        next.e1.close();
      }
    }
  }

  Stream<int> add(final List<int> bytes) {
    _subscribe();
    final StreamController<int> controller = new StreamController();
    writeQueue.addLast(Tuple.create3(bytes, controller, true));
    _tryWrite();
    return controller.stream;
  }

  Stream<int> addStream(final Stream<List<int>> bytes) {
    final StreamController<int> controller = new StreamController();

    bytes.forEach((final List<int> bytes){
      writeQueue.addLast(Tuple.create3(bytes, controller, false));
      _tryWrite();
    }).then(
        (_) {
          writeQueue.addLast(Tuple.create3(const [], controller, true));
          _tryWrite();
        },
        onError: (e, st) {
          controller..addError(e, st);
          writeQueue.addLast(Tuple.create3(const [], controller, true));
          _tryWrite();
        });

    return controller.stream;
  }



  Future close() =>
      _rawSocket.close();

  StreamSubscription<List<int>> listen(void onData(List<int> event), {Function onError, void onDone(), bool cancelOnError}) =>
      _streamController.orCompute(() {
        final StreamController controller = new StreamController();
        _streamController = new Option(controller);
        return controller;
      }).stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);

}