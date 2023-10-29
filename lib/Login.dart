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
      color: Color.fromRGBO(255, 255, 255, 1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 30),
              child: Image(
                image: AssetImage('assets/images/logo2.jpg'),
                width: 320,
                height: 320,
              ),
            ),
            Text(
              '关爱老人健康',
              style: TextStyle(
                  color: Color.fromRGBO(70, 68, 68, 1), fontSize: 24, fontFamily: '微软雅黑', fontWeight: FontWeight.w700, ),
            ),
            Text(
              '让老人时刻不孤单',
              style: TextStyle(
                color: Color.fromRGBO(217, 217, 217, 1), fontSize: 14, fontFamily: '微软雅黑', fontWeight: FontWeight.w700, ),
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
                      prefixIcon: Icon(Icons.person, color: Color.fromRGBO(54, 207, 201, 1)),
                    ),
                  ),
                  SizedBox(height: 20,),
                  TextField(
                    controller: password_controller,
                    decoration: InputDecoration(
                      hintText: '密码',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.lock, color: Color.fromRGBO(54, 207, 201, 1)),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.visibility),
                        onPressed: () {
                          setState(() {
                            password_obscure = !password_obscure;
                          });
                        },
                        color: Color.fromRGBO(54, 207, 201, 1),
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
              style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(54, 207, 201, 1)),
              onPressed: () {
                var url = Uri.http(global_server_address, global_url_login);
                http.post(url,
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: packet.login(username_controller.text, password_controller.text))
                    .then((http.Response response){
                      if (response.statusCode != 200) {
                        return;
                      }
                      final res = json.decode(response.body.toString());
                      String _content = "";
                      bool isSuccess = false;
                      switch(res['state'])
                      {
                        case 'login_success':
                          print('登录成功');
                          isSuccess = true;
                          global_storage.write(key: global_storage_label_username, value: username_controller.text);
                          global_storage.write(key: global_storage_label_password, value: password_controller.text);
                          global_user_info['email'] = res['user']['email'];
                          global_user_info['username'] = username_controller.text;
                          global_user_info['token'] = res['token'];
                          global_detector_server_address =  res['server']['server_port'].toString().isEmpty ? res['server']['server_ip'] : res['server']['server_ip'] + ":" + res['server']['server_port'];
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
                      if(!isSuccess) {
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
                  height: 40,
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
