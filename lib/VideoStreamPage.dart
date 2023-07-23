import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Global.dart';

class VideoStreamPage extends StatefulWidget {
  @override
  _VideoStreamPageState createState() => _VideoStreamPageState();
}

class _VideoStreamPageState extends State<VideoStreamPage> {
  Uint8List? _currentImageBytes;
  Uint8List? _nextImageBytes;
  Key _imageKey = UniqueKey(); // 新增Key来避免图片切换时的闪烁
  bool _isImageReady = false;
  bool disposed = false;
  late Timer _timer;

  void _fetchVideoStream() async {
    final response = await http.get(
        Uri.parse("http://" + global_detector_server_address+ "/video_feed?cam_source="
        + global_current_detector['cam_source']),
      headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': global_user_info['token'],
    },);
    if (response.statusCode == 200) {
      print(response.headers);
      if(response.headers['content-type'] == "image/jpeg" && response.bodyBytes.lengthInBytes > 0) {

        setState(() {
          _nextImageBytes = response.bodyBytes;
          //_imageKey = UniqueKey(); // 更新Key以避免图片切换时的闪烁
          _updateCurrentImage();
        });
      }
      //_fetchVideoStream(); // 继续请求下一帧
    }
  }

  @override
  void initState() {
    super.initState();
    // 每500毫秒执行一次视频帧的刷新
    _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
      _fetchVideoStream();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
  }

  void _updateCurrentImage() {
    if (_nextImageBytes != null) {
      _currentImageBytes = _nextImageBytes;
      _nextImageBytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Stream'),
      ),
      body: Center(
        child: _currentImageBytes!= null
            ? Image.memory(_currentImageBytes!,
            gaplessPlayback: true) // 使用Key来避免图片切换时的闪烁)
            : CircularProgressIndicator(),
      ),
    );
  }
}
