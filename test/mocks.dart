library reslib.mocks;

import "dart:io";

import "package:unittest/mock.dart";

import "package:restlib_server/io.dart";
import "package:restlib_server/server.dart";

class MockHttpConnectionInfo extends Mock implements HttpConnectionInfo {}
class MockHttpHeaders extends Mock implements HttpHeaders {}
class MockHttpRequest extends Mock implements HttpRequest {}
class MockHttpResponse extends Mock implements HttpResponse {}
class MockApplication extends Mock implements Application {}
class MockIOResource extends Mock implements IOResource {}
class MockRoute extends Mock implements Route {}


