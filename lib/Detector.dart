import 'dart:async';
import 'dart:convert';
import 'package:dondaApp/Stream.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dondaApp/EventView.dart';
import 'Global.dart';
import 'Packet.dart';

import 'package:archive/archive.dart';

class DetectorPage extends StatefulWidget {
  const DetectorPage({super.key});

  @override
  State<DetectorPage> createState() => _DetectorPageState();
}

class _DetectorPageState extends State<DetectorPage> {

  late Timer _timer;
  late String _time;

  @override
  void initState() {
    super.initState();
    _time = _formatTime(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _time = _formatTime(DateTime.now());
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime now) {
    return '${now.hour}:${now.minute}:${now.second}';
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 定义按钮宽度为屏幕宽度的80%
    double buttonWidth = screenWidth * 0.8;
    // 定义图片宽度为屏幕宽度的80%
    double imageWidth = screenWidth * 0.8;
    double imageHeight = screenHeight * 0.6;


    return Scaffold(
      appBar: AppBar(
        title: Text(global_current_detector["nickname"]),
      ),
      body: Column(
        children: [
          // 第一行：时间显示和标签
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 时间显示
              Text(
                _time, // 使用字符串变量显示时间
                style: TextStyle(fontSize: 20),
              ), // 标签
              Text(
                global_current_detector["state"] == "norm" ? "目前状态：正常" : "目前状态：异常",
                style: TextStyle(fontSize: 20, color: global_current_detector["state"] == "norm" ? Colors.black : Colors.redAccent),
              ),
            ],
          ),
          // 第二行：图像显示框
          Container(
            height: imageHeight, width: imageWidth, // 设置图片宽度为屏幕宽度的80%
            decoration: BoxDecoration(
              // border: Border.all(color: Color.fromRGBO(54, 207, 201, 1), width: 2),
              image: DecorationImage(
                fit: BoxFit.cover,
                image: global_current_detector['image_'],
              ),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(54, 207, 201, 1)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Stream()),
              );
            },
            child: Container(
              height: 40,
              child: FractionallySizedBox(
                widthFactor: 0.8, // 设置宽度占父容器宽度的比例（50%）
                child: Center(
                  child: Text(
                    '物品/区域管理',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          // 第四行：按钮2
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              //cam2events
              print(packet.cam2events(global_current_detector['cam_source'], 1));
              var url =
              Uri.http(global_detector_server_address, global_url_cam2events);
              http
                  .post(url,
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    'Authorization': global_user_info['token'],
                  },
                  body: packet.cam2events(global_current_detector['cam_source'], 1))
                  .then((http.Response response) {
                List<int> decompressedData = GZipDecoder().decodeBytes(response.bodyBytes);
                String responseBody = utf8.decode(decompressedData);
                final res = json.decode(responseBody.toString());
                String _content = "";
                global_events.clear();
                switch (res["state"]) {
                  case 'cam2events_success':
                    for(int i = 0; i < res["events"].length;i++) {
                      global_events.add(res["events"][i]);
                    }
                    // 反转
                    global_events = global_events.reversed.toList();
                    global_events.forEach((element) {
                      element['cover'] = Image.memory(
                        base64Decode(element['cover_frame']),
                        key: UniqueKey(), // Use a unique key associated with the image data
                      );
                    });
                    global_events.forEach((element) {
                      print(element['cover']);
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EventViewPage()),
                    );
                    break;
                  default:
                    _content = "未知错误";
                    break;
                }
                if (_content != "") {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          '提示',
                          style: TextStyle(fontSize: 15),
                        ),
                        content: Text(
                          _content,
                          style: TextStyle(fontSize: 25),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text(
                              '确定',
                              style: TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              });
            },
            child: Container(
              height: 40,
              child: FractionallySizedBox(
                widthFactor: 0.8, // 设置宽度占父容器宽度的比例（50%）
                child: Center(
                  child: Text(
                    '查看事件回放',
                    style: TextStyle(color: Colors.black, fontSize: 22),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
