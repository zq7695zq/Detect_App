import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dondaApp/RecordPopupDialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:platform_local_notifications/platform_local_notifications.dart';
import 'package:record/record.dart';
import 'package:path/path.dart' as p;

import 'FullScreenScreenshot.dart';
import 'Global.dart';
import 'Packet.dart';
import 'RecordList.dart';
import 'ReminderDialog.dart';

class Stream extends StatefulWidget {
  const Stream({super.key});

  @override
  State<Stream> createState() => _StreamPageState();
}

class _StreamPageState extends State<Stream> {
  late final Player player = Player();
  late final VideoController controller = VideoController(
    player,
    configuration: const VideoControllerConfiguration(
      // NOTE:
      androidAttachSurfaceAfterVideoParameters: false,
    ),
  );
  late Uint8List? screenshot;
  late Timer _timer_keep_stream;

  bool is_checking_recording = false;
  bool is_recording = false;
  late OverlayEntry _overlayEntry;

  late Record record = Record();
  late Timer _timer_check_recording;

  @override
  void initState() {
    var url = Uri.http(global_detector_server_address, global_url_open_video,
        {"cam_source": global_current_detector['cam_source']});
    http.get(url, headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': global_user_info['token'],
    }).then((http.Response response) async {
      final res = json.decode(response.body.toString());
      print(res);
      if (res['success'] == true && res['address'].toString().isNotEmpty) {
        print("尝试打开rtsp流：$res['address']");
        player.open(Media(res['address']));
        _timer_check_recording = Timer.periodic(Duration(seconds: 2), (timer) {
          checkRecording();
        });
        _timer_keep_stream = Timer.periodic(Duration(seconds: 10), (timer) {
          var url = Uri.http(
              global_detector_server_address,
              global_url_keep_video,
              {"cam_source": global_current_detector['cam_source']});
          http.get(url, headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': global_user_info['token'],
          });
        });
      }
    });
    _overlayEntry = _createOverlayEntry();
  }

  @override
  void dispose() {
    if (_timer_keep_stream != null) {
      _timer_keep_stream.cancel();
    }
    if (_timer_check_recording != null) {
      _timer_check_recording.cancel();
    }
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('监控画面'),
      ),
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 9.0 / 16.0,
            // Use [Video] widget to display video output.
            child: Video(controller: controller),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(54, 207, 201, 1)),
            onPressed: () async {
              // controller.player.pause();
              screenshot = await player.screenshot();
              // Show the screenshot in fullscreen mode
              if (screenshot == null) {
                controller.player.play();
              } else {
                Map<String, dynamic> ret = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ReminderDialog();
                  },
                );
                if (ret['state'] == 'success') {
                  var result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              FullScreenScreenshot(screenshot)));
                  if (result != null) {
                    sendScreenshotAndResult(
                        screenshot!,
                        result,
                        global_current_detector['cam_source'],
                        ret['time'],
                        ret['text']);
                  }
                }
              }
            },
            child: Container(
              height: 50,
              child: FractionallySizedBox(
                widthFactor: 0.8, // 设置宽度占父容器宽度的比例（50%）
                child: Center(
                  child: Text(
                    '添加吃药提醒',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () {
              sendGetRecordsAndShow();
            },
            child: Container(
              height: 50,
              child: FractionallySizedBox(
                widthFactor: 0.8, // 设置宽度占父容器宽度的比例（50%）
                child: Center(
                  child: Text(
                    '录音选择',
                    style: TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void sendGetRecordsAndShow(){
    //cam2events
    var url =
    Uri.http(global_detector_server_address, global_url_get_records);
    http
        .post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': global_user_info['token'],
        },
        body: packet.getRecords(global_current_detector['cam_source']))
        .then((http.Response response) {
      final res = json.decode(response.body.toString());
      if(res["state"]){
        global_records = res['list'];
        global_records.sort((a, b) {
          double aValue = double.parse(p.basenameWithoutExtension(a).split('_')[2]);
          double bValue = double.parse(p.basenameWithoutExtension(b).split('_')[2]);
          if (aValue < bValue) {
            return 1;
          } else if (aValue > bValue) {
            return -1;
          } else {
            return 0;
          }
        });
        print(global_records);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecordListPage()),
        );
      }else{
        print(res);
      }
    });
  }
  void sendScreenshotAndResult(Uint8List frame, List<Offset> rect,
      String camSource, String selectTime, String reminderName) async {
    // Convert Uint8List to base64-encoded string
    String frameBase64 = base64Encode(frame);

    // Convert List<Offset> to List<int> for the result
    List<int> retRect = calculateBoundingBox(rect);

    // Create a JSON payload with the screenshot and result
    Map<String, dynamic> payload = {
      'frame': frameBase64,
      'rect': retRect,
      'cam_source': camSource,
      'select_time': selectTime,
      'reminder_name': reminderName,
      'reminder_type': 1,
    };

    // Convert the payload to a JSON-encoded string
    String jsonPayload = jsonEncode(payload);

    print(jsonPayload);
    // Replace 'your-fastapi-endpoint' with the actual URL of your FastAPI endpoint
    Uri url =
        Uri.http(global_detector_server_address, global_url_add_video_reminder);

    try {
      // Send the POST request to the FastAPI endpoint
      http.Response response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': global_user_info['token'],
          },
          body: jsonPayload);

      if (response.statusCode == 200) {
        print('Data sent successfully.');
        // TODO SEEK有问题？
        //player.seek(player.state.buffer);
      } else {
        print('Failed to send data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data: $e');
    }
  }

  List<int> calculateBoundingBox(List<Offset> rect) {
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    // Find the minimum and maximum X and Y coordinates
    for (var point in rect) {
      minX = min(minX, point.dx);
      minY = min(minY, point.dy);
      maxX = max(maxX, point.dx);
      maxY = max(maxY, point.dy);
    }

    // Calculate the width and height of the bounding rectangle
    double width = maxX - minX;
    double height = maxY - minY;

    return [minX.toInt(), minY.toInt(), width.toInt(), height.toInt()];
  }

  void checkRecording() {
    if (is_checking_recording || is_recording) return;
    print('checkRecording');
    is_checking_recording = true;
    var url = Uri.http(global_detector_server_address, global_url_is_recording);
    for (int i = 0; i < global_detectors.length; i++) {
      http
          .post(url,
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
                'Authorization': global_user_info['token'],
              },
              body: packet.isRecording(global_detectors[i]['cam_source']))
          .then((http.Response response) async {
        if (response.body.toString().isEmpty) return;

        Map<String, dynamic> res = json.decode(response.body.toString());
        print(res);
        if (res.containsKey("state") && res['state'] == true) {
          is_recording = true;
          // 十秒后才能继续测试
          Future.delayed(Duration(seconds: 15), () {
            is_recording = false;
          });
          // _showOverlay();
          var outPutFileName = await getTempFilename();
          if (!await record.hasPermission()) {
            return;
          }
          await record.start(path: outPutFileName, encoder: AudioEncoder.wav);
          Future.delayed(Duration(seconds: 4), () async {
            // _hideOverlay(); // 加载完成后隐藏Overlay
            await record.stop();
            await record.dispose();
            record = Record();
            String ret =
                await uploadVoice(outPutFileName, global_url_detect_record, {});
            print(ret);
            Map<String, dynamic> detect_res = json.decode(ret);
            if (detect_res.containsKey("state") &&
                detect_res['state'] == true) {
              await PlatformNotifier.I.showPluginNotification(
                  ShowPluginNotificationModel(
                      id: DateTime.now().second,
                      title: "消息提示",
                      body: "接收到语音指令：" + detect_res['name'],
                      payload: "test"),
                  context);
            }
          });
        }
      });
    }
    is_checking_recording = false;
  }

  // 创建OverlayEntry
  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: CircularProgressIndicator(),
          ),
          Text(
            '录音中，等待说出指令····',
            style: TextStyle(fontSize: 18.0),
          ),
        ],
      ),
    );
  }
}
