import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:upharm_common/upharm_common.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  test('test', () async {
    SignalR.initialize(99999999, 'testtest');
    sleep(Duration(seconds: 1));
    SignalR.sendquery('select * from st약국정보');
  });
}
