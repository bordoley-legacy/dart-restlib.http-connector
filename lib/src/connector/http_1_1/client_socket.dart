/*
abstract class ClientSocket implements StreamSink<List<int>>, Stream<List<int>> {
  Stream<int> get bytesSent;
}

class _ClientSocket extends Stream<List<int>> implements ClientSocket {
  final RawSocket _rawSocket;
  final StreamController bytesSentController = new StreamController();
  final Queue<List<int>> _writeData = new Queue();
  final Completer doneCompleter = new Completer();
  final StreamController _streamController = new StreamController();
  Option<StreamSubscription> _socketSubscription;

  bool writeClosed = false;

  _ClientSocket(this._rawSocket);

  Stream<int> get bytesSent =>
      bytesSentController.stream;

  Future get done =>
      doneCompleter.future;

  StreamSubscription _subscribe() =>
      _socketSubscription.orCompute((){
        final StreamSubscription subscription =
            _rawSocket.listen(
                (final RawSocketEvent ev) {
                  switch(ev) {
                    case RawSocketEvent.READ: {
                      final List<int> bytes = _rawSocket.read();
                      _streamController.add(bytes);
                    } break;
                    case RawSocketEvent.WRITE: {
                      _write();
                    } break;
                    case RawSocketEvent.READ_CLOSED: {
                      _streamController.close();
                    } break;
                    case RawSocketEvent.CLOSED: {
                      doneCompleter.complete();
                    }
                  };
                },
                onError: () {},
                onDone: () {},
                cancelOnError: true);

        _socketSubscription = new Option(subscription);
      });

  void _write() {
    while(true) {
      final List<int> data = _writeData.removeFirst();
      final int bytesWritten = _rawSocket.write(data);
      bytesSentController.add(bytesWritten);

      if (bytesWritten != data.length) {
        _writeData.addFirst(sublist(data, bytesWritten));
        break;
      }
    }
  }

  void add(final List<int> event) {
    checkState(!writeClosed);
    _writeData.addLast(event);
    _write();
  }

  void addError(final errorEvent, [final StackTrace stackTrace]) =>
      throw new UnsupportedError("");

  Future addStream(final Stream<List<int>> stream) {
    checkState(!writeClosed);
    return stream.forEach((final List<int> bytes) => add(bytes));
  }

  Future close() {
    writeClosed = true;
    _rawSocket.shutdown(SocketDirection.SEND);
    return bytesSentController.close();
  }

  StreamSubscription<List<int>> listen(Function onData, {Function onError, Function onDone, bool cancelOnError}) =>
      _streamController.stream.listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}*/