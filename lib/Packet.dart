import 'dart:convert';

import 'Global.dart';

class packet
{
  static String login(String username, String password)
  {
    final post = {
      'username': username,
      'password' : generateMd5(password),
    };
    return json.encode(post);
  }

  static String register(String email, String username, String password)
  {
    final post = {
      'email': email,
      'username': username,
      'password' : generateMd5(password),
    };
    return json.encode(post);
  }

  static String detector(String username)
  {
    final post = {
      'owner': username,
    };
    return json.encode(post);
  }

  static String addDetector(String cam_source, String nickname)
  {
    final post = {
      'cam_source': cam_source,
      'nickname': nickname,
    };
    return json.encode(post);
  }

  static String cam2events(String cam_source)
  {
    final post = {
      'cam_source': cam_source,
    };
    return json.encode(post);
  }

  static String getEventFrames(String event_name)
  {
    final post = {
      'event_name': event_name,
    };
    return json.encode(post);
  }


  static String delEvent(String event_name, String cam_source)
  {
    final post = {
      'event_name': event_name,
      'cam_source': cam_source,
    };
    return json.encode(post);
  }

  static String getNotification(String cam_source)
  {
    final post = {
      'cam_source': cam_source,
    };
    return json.encode(post);
  }
}