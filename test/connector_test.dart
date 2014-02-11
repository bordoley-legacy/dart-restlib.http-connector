library restlib.connector_test;

import "dart:async";
import "dart:io";

import "package:restlib_http_connector/connector.dart";

import "package:restlib_server/io.dart";
import "package:restlib_server/server.dart";

import "package:restlib_core/data.dart";
import "package:restlib_core/data.media_ranges.dart";
import "package:restlib_core/http.dart";
import "package:restlib_core/http.future_responses.dart";
import "package:restlib_core/net.dart";

import "package:restlib_common/collections.dart";
import "package:restlib_common/collections.immutable.dart";
import "package:restlib_testing/testing.dart";

import "package:unittest/mock.dart";
import "package:unittest/unittest.dart";

import "mocks.dart";

part "src/connector/http_response_writer_test.dart";
part "src/connector/http_server_listener_test.dart";

void connectorTestGroups() {
  httpServerListenerTestGroup();
  httpResponseWriterTestGroup();
}

main() {
  connectorTestGroups();
}