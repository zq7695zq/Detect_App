import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:dondaApp/SignUp.dart';
import 'package:platform_local_notifications/platform_local_notifications.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'Login.dart';

class MyScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await PlatformNotifier.I.init(appName: "dondaApp");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromRGBO(98, 178, 252, 1)),
        useMaterial3: true,
        fontFamily: 'alibaba',
      ),
      home: const MainPage(title: 'Home Page'),
      scrollBehavior: MyScrollBehavior(),
      builder: EasyLoading.init(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key, required this.title});
  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(98, 178, 252, 1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 100),
                child: CircleAvatar(
                  radius: 110, // 尺寸， 宽高一样， 代表的是半径，如果需要一个80x80尺寸的元素，那么配置为40即可
                  backgroundImage: NetworkImage(
                      "https://www.itying.com/images/flutter/1.png"), // 从接口中获取的图片的URL地址
                ),
              ),
              Text(
                '欢迎使用',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontFamily: 'Poppins'
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                        ),
                        backgroundColor: Colors.black),
                    child: Container(
                      width: 170,
                      height: 60,
                      child: Center(
                          child: Text(
                        '登录',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      )),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                    ),
                    child: Container(
                      width: 170,
                      height: 60,
                      child: Center(
                          child: Text(
                        '注册',
                        style: TextStyle(color: Colors.black, fontSize: 22),
                      )),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
