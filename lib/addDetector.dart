import 'dart:convert';
import 'dart:developer';

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
              onPressed: () {
                var url = Uri.http(global_detector_server_address, global_url_add_detector);
                http
                    .post(url,
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                          'Authorization' : global_user_info['token'],
                        },
                        body: packet.addDetector(cam_source_controller.text,
                            nickname_controller.text))
                    .then((http.Response response) {
                      final res = json.decode(response.body.toString());
                      print(res);
                      String _content = "";
                      bool isPop = true;
                      switch(res['state'])
                      {
                        case 'detector_cam_source_exist':
                          _content = '这个摄像头已经被绑定';
                          break;
                        case 'detector_add_success':
                          _content ="添加成功";
                          break;
                        default:
                          _content = "未知错误";
                          break;
                      }
                      if(isPop) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('提示',
                                style: TextStyle(fontSize: 15),),
                              content: Text(_content,
                                style: TextStyle(fontSize: 25),),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('确定',
                                    style: TextStyle(fontSize: 20),),
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
                    }
                );
              },
              child: Container(
                height: 60,
                child: FractionallySizedBox(
                  widthFactor: 0.8, // 设置宽度占父容器宽度的比例（50%）
                  child: Center(
                    child: Text(
                      '注册账号',
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
