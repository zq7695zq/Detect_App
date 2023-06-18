import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Global.dart';
import 'Home.dart';
import 'Packet.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController username_controller = new TextEditingController();
  TextEditingController password_controller = new TextEditingController();

  bool password_obscure = true;

  Future<void> _readFromStorage() async{
    username_controller.text = await global_storage.read(key: global_storage_label_username) ?? '';
    password_controller.text = await global_storage.read(key: global_storage_label_password) ?? '';
  }

  @override
  Widget build(BuildContext context) {

    _readFromStorage();
    return Scaffold(
        body: Container(
      color: Color.fromRGBO(98, 178, 252, 1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 100),
              child: Image(
                image: AssetImage('assets/images/login.png'),
                width: 250,
                height: 250,
              ),
            ),
            Text(
              '欢迎回来',
              style: TextStyle(
                  color: Color.fromRGBO(70, 68, 68, 1), fontSize: 32, fontFamily: 'Poppins', fontWeight: FontWeight.bold, ),
            ),
            Container(
              child:
              FractionallySizedBox(
                widthFactor: 0.8, // 设置宽度占父容器宽度的比例（50%）
                child:  Column(children: <Widget>[
                  TextField(
                    controller: username_controller,
                    decoration: InputDecoration(
                      hintText: '账号',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.person, color: Colors.blue),
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    controller: password_controller,
                    decoration: InputDecoration(
                      hintText: '密码',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.lock, color: Colors.blue),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.visibility),
                        onPressed: () {
                          setState(() {
                            password_obscure = !password_obscure;
                          });
                        },
                        color: Colors.blue,
                      ),
                    ),
                    obscureText: password_obscure,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        onPressed: () {

                        },
                        child: Text(
                          '忘记密码?',
                          style: TextStyle(color: Colors.black, fontSize: 15),
                        ),
                      ),
                    ],
                  ),

                ]),
              ),

            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              onPressed: () {
                var url = Uri.http(global_server_address, global_url_login);
                
                print(packet.login(username_controller.text, password_controller.text));
                http.post(url,
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: packet.login(username_controller.text, password_controller.text))
                    .then((http.Response response){
                      final res = json.decode(response.body.toString());
                      String _content = "";
                      switch(res['state'])
                      {
                        case 'login_success':
                          print('登录成功');
                          global_storage.write(key: global_storage_label_username, value: username_controller.text);
                          global_storage.write(key: global_storage_label_password, value: password_controller.text);
                          global_user_info['email'] = res['user']['email'];
                          global_user_info['username'] = username_controller.text;
                          global_user_info['token'] = res['token'];
                          global_detector_server_address = res['server']['server_ip'] + ":" + res['server']['server_port'];
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                          break;
                        case 'login_fail_user_is_not_exist':
                          print('用户不存在');
                          _content = "用户不存在";
                          break;
                        case 'login_fail_password_wrong':
                          print('密码错误');
                          _content = "密码错误";
                          break;
                      }
                      if(_content != "") {
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
                  child:Center(
                    child: Text(
                      '登录',
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
