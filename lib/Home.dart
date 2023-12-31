import 'dart:async';
import 'dart:convert';

import 'package:dondaApp/Detector.dart';
import 'package:dondaApp/Login.dart';
import 'package:dondaApp/addDetector.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:platform_local_notifications/platform_local_notifications.dart';

import 'Global.dart';
import 'Loop.dart';
import 'Packet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool is_refreshing = false;
  event_loop el = event_loop();
  final Stopwatch _stopwatch = Stopwatch();

  Color getColorByState(String state) {
    //global_detectors[pageIndex*4 + index]["state"] == "norm" ? Color.fromRGBO(255,255,255, 1) :Color.fromRGBO(227,60,100, 1)
    switch (state) {
      case 'norm':
        return Color.fromRGBO(255, 255, 255, 1);
      case 'warning':
        return Color.fromRGBO(227, 60, 100, 1);
      case 'death':
        return Colors.grey;
      default:
        return Colors.yellow;
    }
  }

  void refresh()
  {
    {
      if(is_refreshing) return;
      is_refreshing = true;
      // 处理刷新
      var url =
      Uri.http(global_detector_server_address, global_url_detector);
      http
          .post(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': global_user_info['token'],
          },
          body: packet.detector(global_user_info['username']))
          .then((http.Response response) {
            if(response.body.toString().isEmpty)return;
        final res = json.decode(response.body.toString());
        String _content = "";
        switch (res["state"]) {
          case 'detector_get_success':
            setState(() {
              global_detectors = res["detectors"];
              for(int i = 0; i < global_detectors.length; i++) {
                if (global_detectors[i]['image'] != null) {
                  global_detectors[i]['image_'] =
                      MemoryImage(base64Decode(global_detectors[i]['image']));

                } else {
                  global_detectors[i]['image_'] = Image.network(
                          "https://www.itying.com/images/flutter/1.png")
                      .image;
                }
                global_detectors[i]['nickname'] =
                    utf8.decode(base64.decode(global_detectors[i]['nickname']));
              }
            });
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
      url =
        Uri.http(global_detector_server_address, global_url_get_notification);
      for(int i = 0; i < global_detectors.length; i++)
      {
        http
            .post(url,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': global_user_info['token'],
            },
            body: packet.getNotification(global_detectors[i]['cam_source']))
            .then((http.Response response) async {
          if (response.statusCode != 200) {
            return;
          }
          Map<String, dynamic> res = json.decode(response.body.toString());
          print(res);
          if (res['state'] == 1 || res['state'] == "1") {
            if (context.mounted) {
              if ((_stopwatch.isRunning && _stopwatch.elapsed.inSeconds > 15) ||
                  !_stopwatch.isRunning) {
                _stopwatch.reset();
                _stopwatch.start();
                String text = res.containsKey('event_name') && res['event_name'].toString().isNotEmpty ? utf8.decode(base64Decode(res['event_name'])) : res['notification'];
                await PlatformNotifier.I.showPluginNotification(
                    ShowPluginNotificationModel(
                        id: DateTime.now().second,
                        title: "消息提示",
                        body: "检测到异常，状态：$text",
                        payload: "test"),
                    context);
              }
            }
          }

        });
      }
      is_refreshing = false;
    }
  }


  @override
  void initState()
  {
    refresh();
    Timer.periodic(Duration(seconds: 5), (timer) {
      refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Donda'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              iconSize: 40,
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        actions: [
          IconButton(
            iconSize: 40,
            icon: Icon(Icons.search),
            onPressed: () {
              // 处理搜索按钮点击事件
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(global_user_info['username']),
              accountEmail: Text(global_user_info['email']),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('A'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('退出登录'),
              onTap: () {
                // 处理返回主页点击事件
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                color: Color.fromRGBO(54, 207, 201, 1),
                iconSize: 48,
                icon: Icon(Icons.settings),
                onPressed: () {
                  // 处理设置按钮点击事件
                },
              ),
              IconButton(
                color: Color.fromRGBO(54, 207, 201, 1),
                iconSize: 48,
                icon: Icon(Icons.cloud_download),
                onPressed: () {
                  // 处理云按钮点击事件
                },
              ),
              IconButton(
                color: Color.fromRGBO(54, 207, 201, 1),
                iconSize: 48,
                icon: Icon(Icons.refresh),
                onPressed: () {
                  refresh();
                },
              ),
            ],
          ),
          SizedBox(height: 40),
          Expanded(
              child: PageView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: (global_detectors.length / 4).ceil(),
            itemBuilder: (context, pageIndex) {
              return GridView.builder(
                itemCount: global_detectors.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2),
                itemBuilder: (context, index) {
                  return Card(
                    color: Color.fromRGBO(240, 240, 240, 1),
                    child: InkWell(
                      onTap: () {
                        // Do something when the card is tapped
                        print('${'Card '+ global_detectors[pageIndex*4 + index]["nickname"]} tapped');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetectorPage()),
                        );
                        global_current_detector = global_detectors[pageIndex*4 + index];
                      },
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                margin: EdgeInsets.only(top: 10, left: 10),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Color.fromRGBO(34, 199, 169, 1) ,
                                          // color: Color(global_detectors[pageIndex*4 + index]["state"] == "norm" ? 0x22C7A9: 0xE33C64),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: getColorByState(global_detectors[pageIndex*4 + index]["state"]),
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: global_detectors[pageIndex*4 + index]["state"] == "norm" ? Color.fromRGBO(255,255,255, 1) :Color.fromRGBO(227,60,100, 1) ,
                                  width: 4.0,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundImage: global_detectors[pageIndex*4 + index]['image_'],
                                radius: MediaQuery.of(context).size.width * 0.2,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                global_detectors[pageIndex*4 + index]["nickname"],
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          )),
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                // 处理按钮点击事件
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => addDetectorPage()),
                );
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Color(0xFF36CFC9)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
              ),
              child: Text(
                '添加监控区域',
                style: TextStyle(color: Colors.white, fontSize: 30),
              ),
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
