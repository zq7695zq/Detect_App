import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Global.dart';
import 'Packet.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController email_controller = new TextEditingController();
  TextEditingController username_controller = new TextEditingController();
  TextEditingController password_controller = new TextEditingController();

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
                    controller: email_controller,
                    decoration: InputDecoration(
                      hintText: '邮箱',
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
                    controller: username_controller,
                    decoration: InputDecoration(
                      hintText: '账户名',
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
                    controller: password_controller,
                    decoration: InputDecoration(
                      hintText: '密码',
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
                    obscureText: true,
                  ),
                ]),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                var url = Uri.http(global_server_address, global_url_register);
                http
                    .post(url,
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: packet.register(email_controller.text,
                            username_controller.text, password_controller.text))
                    .then((http.Response response) {
                      final res = json.decode(response.body.toString());
                      print(res);
                      String _content = "";
                      bool isPop = false;
                      switch(res['state'])
                      {
                        case 'error_user_is_exist':
                          print('账号已经存在');
                          _content = '账号已经存在';
                          break;
                        case 'register_success':
                          print('注册成功');
                          _content ="注册成功";
                          isPop = true;
                          break;
                        default:
                          _content = "未知错误";
                          break;
                      }
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
                                  if(isPop) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
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
