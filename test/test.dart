import "dart:async";
import "dart:io" as io;

import "package:restlib_client/client.dart";
import "package:restlib_common/collections.dart";
import "package:restlib_common/preconditions.dart";
import "package:restlib_http_connector/connector.http_1_1.dart";
import "package:restlib_core/data.dart";
import "package:restlib_core/http.dart";
import "package:restlib_core/http.methods.dart" as methods;
import "package:restlib_core/net.dart";

void main() {
  final HttpClient client = new Http_1_1_Client((final URI uri) {
    checkNotNull(uri);
    checkArgument(uri.authority.isNotEmpty);
    checkArgument(uri.scheme.isNotEmpty);

    final String host = uri.authority.value.host.value.toString();
    final Option<int> port = uri.authority.value.port;

    if (uri.scheme == "http") {
      return io.RawSocket.connect(host, port.orElse(80))
          .then((final io.RawSocket socket) => new ClientConnection(socket));
    } else if (uri.scheme == "https") {
      return io.RawSecureSocket.connect(host, port.orElse(443))
          .then((final io.RawSocket socket) => new ClientConnection(socket));
    } else {
      throw new ArgumentError("invalid scheme: $uri.scheme");
    }
  });

  final URI uri = URI.parser.parseValue("http://www.google.com/");
  final Request request = new Request(methods.GET, uri,
      preferences: new RequestPreferences(acceptedMediaRanges: [new Preference(MediaRange.ANY)]),
      userAgent: UserAgent.parser.parseValue("curl/7.21.4 (universal-apple-darwin11.0) libcurl/7.21.4 OpenSSL/0.9.8y zlib/1.2.5"));

  print(request);

  RequestHandle handle = client(request);
  handle.response.then((final Response<Stream<List<int>>> response) {
    print(response.without(entity: true));
    response.entity.map((final Stream<List<int>> data) =>
        data.forEach((final List<int> d) =>
                 print(new String.fromCharCodes(d))));
  });
}