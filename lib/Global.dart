import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

// md5 加密
String generateMd5(String data) {
  var content = Utf8Encoder().convert(data);
  var digest = md5.convert(content);
  return hex.encode(digest.bytes);
}

const String global_login_server_ip = "127.0.0.1";//"10.0.2.2"

const String global_login_server_port = "8080";

const String global_server_address = global_login_server_ip + ":" + global_login_server_port;

String global_detector_server_address = "";

const String global_url_login = "/login";

const String global_url_register = "/register";

const String global_url_detector = "/detector";

const String global_url_cam2events = "/cam2events";

const String global_url_get_event_frames = "/get_event_frames";

const String global_url_add_detector = "/add_detector";

const String global_url_del_event = "/del_event";

const String global_url_get_notification = "/get_notification";

// Create storage
final global_storage = new FlutterSecureStorage();

const String global_storage_label_username = "username";

const String global_storage_label_password = "password";

var global_user_info = {};

var global_detectors = [];

List<Map<String, dynamic>> global_events = [];

var global_current_detector;

Map<String, List<String>> global_event_frames = {}; // name - > frames

String global_current_event_name = "";

