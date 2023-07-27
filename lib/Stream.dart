import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'FullScreenScreenshot.dart';
import 'Global.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'ReminderDialog.dart';


class Stream extends StatefulWidget {
  const Stream({super.key});

  @override
  State<Stream> createState() => _StreamPageState();
}
class _StreamPageState extends State<Stream> {
  late final player = Player();
  late final controller = VideoController(player);
  late Uint8List? screenshot;
  late Timer _timer;


  @override
  void initState() {
    const timeInterval = Duration(seconds: 5);
    var url = Uri.http(
        global_detector_server_address
        , global_url_open_video
        , {"cam_source": global_current_detector['cam_source']});
    http.get(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': global_user_info['token'],
        });
    _timer = Timer.periodic(timeInterval , (timer){
      var url = Uri.http(
          global_detector_server_address
          , global_url_keep_video
          , {"cam_source": global_current_detector['cam_source']});
      http.get(url,
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': global_user_info['token'],
          });
    });
    player.open(Media(global_current_detector['cam_source'] + "_stream_from_server"));

  }

  @override
  void dispose() {
    _timer.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('监控画面'),
      ),
      body:
      // Wrap [Video] widget with [MaterialDesktopVideoControlsTheme].
      MaterialDesktopVideoControlsTheme(
        normal: MaterialDesktopVideoControlsThemeData(
          // Modify theme options:
          seekBarThumbColor: Colors.blue,
          seekBarPositionColor: Colors.blue,
          toggleFullscreenOnDoublePress: false,
          // Modify bottom button bar:
          bottomButtonBar: [
            Spacer(),
            MaterialDesktopPlayOrPauseButton(),
            MaterialDesktopCustomButton(
              onPressed: () async {
                controller.player.pause();
                screenshot = await player.screenshot();
                // Show the screenshot in fullscreen mode
                if(screenshot == null)
                {
                  controller.player.play();
                }else
                {
                  Map<String, dynamic> ret = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ReminderDialog();
                    },
                  );
                  if(ret['state'] == 'success')
                  {
                    var result = await Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenScreenshot(screenshot)));
                    if(result != null)
                    {
                      sendScreenshotAndResult(screenshot!, result, global_current_detector['cam_source'], ret['time'], ret['text']);
                    }
                  }

                }
              },
              icon: Icon(Icons.add_alert),
            ),
            MaterialDesktopCustomButton(
              onPressed: () async {
                controller.player.pause();
                screenshot = await player.screenshot();
              },
              icon: Icon(Icons.security),
            ),
            Spacer(),
          ],
        ),
        fullscreen: const MaterialDesktopVideoControlsThemeData(),
        child: Scaffold(
          body: Video(
            controller: controller,
          ),
        ),
      ),
    );
  }

  void sendScreenshotAndResult(Uint8List frame, List<Offset> rect, String camSource, String selectTime, String reminderName) async {
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
    Uri url =  Uri.http(global_detector_server_address, global_url_add_video_reminder);

    try {
      // Send the POST request to the FastAPI endpoint
      http.Response response = await http.post(url,
          headers: {'Content-Type': 'application/json',
            'Authorization': global_user_info['token'],},
          body: jsonPayload);

      if (response.statusCode == 200) {
        print('Data sent successfully.');
        player.seek(player.state.buffer);
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

}
