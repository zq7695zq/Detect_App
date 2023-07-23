import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'Global.dart';
import 'Packet.dart';
import 'package:flutter/material.dart';

import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'VideoStreamPage.dart';


class LivePage extends StatefulWidget {
  const LivePage({super.key});

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  //late final player = Player();
  //late final controller = VideoController(player);


  @override
  void initState() {
    http.get(
      Uri.parse("http://" + global_detector_server_address+ "/open_video?cam_source="
          + global_current_detector['cam_source']),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': global_user_info['token'],
      },);
    super.initState();

    //"http://" + global_detector_server_address+ "/video_feed?cam_source=" + base64Encode(utf8.encode(global_current_detector['cam_source']))
    //player.open(Media(global_current_detector['cam_source']));
  }

  @override
  void dispose() {
    //player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('监控画面'),
      ),
      body: VideoStreamPage(),
    );
  }
}
