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
            seedColor: const Color.fromRGBO(54, 207, 201, 1)),
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
        decoration: BoxDecoration(
          image: DecorationImage(
            image:  AssetImage('assets/images/welcome.png'), // Replace with your image path
            fit: BoxFit.cover,
            opacity: 0.6,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: const [
                  CircleAvatar(
                    backgroundColor: Color.fromRGBO(255, 255, 255, 0),
                    radius: 65, // 尺寸， 宽高一样， 代表的是半径，如果需要一个80x80尺寸的元素，那么配置为40即可
                    backgroundImage: AssetImage('assets/images/app_logo.png'), // 从接口中获取的图片的URL地址
                  ),
                  Text(
                    '动达家居',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 36,
                        fontFamily: '微软雅黑'
                    ),
                  ),
                  Text(
                    '您最好的私人管家',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'PingFangSC'
                    ),
                  ),
                ],
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
                        backgroundColor: Color.fromRGBO(54, 207, 201, 1)),
                    child: Container(
                      width: 150,
                      height: 40,
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
                      width: 150,
                      height: 40,
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
