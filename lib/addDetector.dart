import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Global.dart';
import 'Packet.dart';

class addDetectorPage extends StatefulWidget {
  const addDetectorPage({super.key});

  @override
  State<addDetectorPage> createState() => _addDetectorPageState();
}

class _addDetectorPageState extends State<addDetectorPage> {

  TextEditingController cam_source_controller = new TextEditingController();
  TextEditingController nickname_controller = new TextEditingController();

  bool isButtonEnabled = true;

  bool validateRTSPAddress(String address) {
    // RTSP地址的正则表达式（不包含用户名和密码）
    const pattern = r'rtsp:\/\/((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})(\.((2(5[0-5]|[0-4]\d))|[0-1]?\d{1,2})){3}:[0-9]*\/[a-zA-Z0-9]*';
    final regExp = RegExp(pattern);
    return regExp.hasMatch(address);
  }


  Future<bool> checkRTSPConnectivity(String address) async {
    // 解析地址中的主机和端口
    String rtspHost = address.split("://")[1].split(":")[0];
    int rtspPort = int.parse(address.split("://")[1].split(":")[1].split("/")[0]);

    // 创建一个socket对象
    Socket? socket;

    try {
      // 尝试连接到rtsp服务器
      socket = await Socket.connect(rtspHost, rtspPort);

      // 定义一个rtsp请求的消息
      String message = "OPTIONS $address RTSP/1.0\r\nCSeq: 1\r\nUser-Agent: Dart\r\n\r\n";

      // 发送请求
      socket.write(message);

      // 接收响应
      String response = await utf8.decoder.bind(socket).first;

      // 判断响应是否为200 OK
      if (response.startsWith("RTSP/1.0 200 OK")) {
        // 返回true表示连通
        return true;
      } else {
        // 返回false表示不连通
        return false;
      }
    } catch (e) {
      // 如果发生异常，返回false表示不连通
      return false;
    } finally {
      // 关闭socket
      socket?.destroy();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      color: Color.fromRGBO(98, 178, 252, 1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              child: FractionallySizedBox(
                widthFactor: 0.8, // 设置宽度占父容器宽度的比例（50%）
                child: Column(children: <Widget>[
                  SizedBox(
                    height: 80,
                  ),
                  TextField(
                    style: TextStyle(fontSize: 20.0),
                    controller: cam_source_controller,
                    decoration: InputDecoration(
                      hintText: '摄像头地址',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  TextField(
                    style: TextStyle(fontSize: 20.0),
                    controller: nickname_controller,
                    decoration: InputDecoration(
                      hintText: '别名',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide(color: Colors.transparent),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: isButtonEnabled ? () async {
                setState(() {
                  isButtonEnabled = false; // 禁用按钮
                });
                print(cam_source_controller.text);
                final isAddressValid = validateRTSPAddress(cam_source_controller.text);
                bool isConnected = false;
                if (isAddressValid) {
                  isConnected = await checkRTSPConnectivity(cam_source_controller.text);
                  print('RTSP地址合法性: $isAddressValid');
                  print('RTSP地址连通性: $isConnected');
                } else {
                  print('RTSP地址不合法');
                }
                if(isAddressValid && isConnected)
                {
                  var url = Uri.http(global_detector_server_address, global_url_add_detector);
                  http.post(
                    url,
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                      'Authorization': global_user_info['token'],
                    },
                    body: packet.addDetector(
                      cam_source_controller.text,
                      nickname_controller.text,
                    ),
                  ).then((http.Response response) {
                    final res = json.decode(response.body.toString());
                    print(res);
                    String _content = "";
                    bool isPop = true;
                    switch (res['state']) {
                      case 'detector_cam_source_exist':
                        _content = '这个摄像头已经被绑定';
                        break;
                      case 'detector_add_success':
                        _content = "添加成功";
                        break;
                      default:
                        _content = "未知错误";
                        break;
                    }
                    if (isPop) {
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
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                    // 处理完成后启用按钮
                    setState(() {
                      isButtonEnabled = true;
                    });
                  });
                }else{
                  if(context.mounted) {
                    showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(
                          '提示',
                          style: TextStyle(fontSize: 15),
                        ),
                        content: Text(
                          isAddressValid ? "连接摄像头失败" : "地址不合法",
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
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                  }
                  // 处理完成后启用按钮
                  setState(() {
                    isButtonEnabled = true;
                  });
                }
              } : null, // 如果按钮禁用，则设置onPressed为null，即禁用按钮点击
              child: Container(
                height: 60,
                child: FractionallySizedBox(
                  widthFactor: 0.8,
                  child: Center(
                    child: Text(
                      '添加摄像头',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
