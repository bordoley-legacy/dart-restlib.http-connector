library reslib.mocks;

import "dart:io";

import "package:unittest/mock.dart";

import "package:restlib_server/io.dart";
import "package:restlib_server/server.dart";

class MockHttpConnectionInfo extends Mock implements HttpConnectionInfo {
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class MockHttpHeaders extends Mock implements HttpHeaders {
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class MockHttpRequest extends Mock implements HttpRequest {
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class MockHttpResponse extends Mock implements HttpResponse {
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class MockApplication extends Mock implements Application {
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class MockIOResource extends Mock implements IOResource {
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class MockRoute extends Mock implements Route {
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}


