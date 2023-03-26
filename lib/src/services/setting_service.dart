import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:Rider/src/helper/custom_trace.dart';
import 'package:Rider/src/helper/helper.dart';
import 'package:Rider/src/models/setting.dart';

Future<Setting> getSettings() async {
  var response = await http.get(Helper.getUri('settings', addApiToken: false),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
      }).timeout(const Duration(seconds: 15));
  if (response.statusCode == HttpStatus.ok) {
    return Setting.fromJSON(json.decode(response.body)['data']);
  } else {
    CustomTrace(StackTrace.current, message: response.body);
    throw Exception(response.statusCode);
  }
}
