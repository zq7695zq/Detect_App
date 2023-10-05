import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path;
import 'package:record/record.dart';

import 'Global.dart';

class RecordPopupDialog extends StatefulWidget {
  const RecordPopupDialog({super.key});

  @override
  _RecordPopupDialogState createState() => _RecordPopupDialogState();
}

class _RecordPopupDialogState extends State<RecordPopupDialog> {
  bool recordingStarted = false;
  bool recordingFinished = false;

  bool countdownStarted = false;
  bool countdownFinished = false;

  int countdownSeconds = 3;
  int recordingSeconds = 3;

  String outPutFileName = "";

  bool isRecord = true;

  late Widget _new_body = _buildButtonsForRecordingNotStarted();

  final record = Record();

  void startCountdown() {
    setState(() {
      _new_body = _buildCountdown();
      countdownSeconds = 3;
    });
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdownSeconds > 1) {
        setState(() {
          countdownSeconds--;
          _new_body = _buildCountdown();
        });
      } else {
        timer.cancel();
        stopCounting();
        startRecording();
      }
    });
  }

  void startRecording() async {
    if (await record.hasPermission()) {
      setState(() {
        _new_body = _buildRecording();
      });
      recordingStarted = true;
      recordingSeconds = 3;
      outPutFileName = await getTempFilename();
      await record.start(path: outPutFileName, encoder: AudioEncoder.wav);
      Timer.periodic(Duration(seconds: 1), (timer) async {
        if (recordingSeconds > 1) {
          setState(() {
            recordingSeconds--;
            _new_body = _buildRecording();
          });
        } else {
          timer.cancel();
          stopRecording();
        }
      });
    } else {
      print('Permission to record audio denied.');
    }
  }

  void stopRecording() async {
    await record.stop();
    setState(() {
      _new_body = _buildButtonsForRecordingFinished();
      recordingStarted = false;
      recordingFinished = true;
    });
  }

  void stopCounting() async {
    setState(() {
      countdownStarted = false;
      countdownFinished = true;
    });
  }

  void resetCounting() {
    setState(() {
      countdownStarted = false;
      countdownFinished = false;
      recordingStarted = false;
      recordingFinished = false;
      countdownSeconds = 3;
      recordingSeconds = 3;
      outPutFileName = "";
      _new_body = _buildButtonsForRecordingNotStarted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        width: 250,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('录制语音指令',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            _new_body,
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsForRecordingNotStarted() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            isRecord = true;
            startCountdown(); // Start the countdown
          },
          child: Text('开始收音'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            isRecord = false;
            startCountdown(); // Start the countdown
          },
          child: Text('测试指令功能'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('取消'),
        ),
      ],
    );
  }

  Widget _buildCountdown() {
    return Text(
      '倒计时 $countdownSeconds 秒',
      style: TextStyle(fontSize: 18),
    );
  }

  Widget _buildRecording() {
    return Text(
      '录制中倒计时 $recordingSeconds 秒',
      style: TextStyle(fontSize: 18),
    );
  }

  Widget _buildButtonsForRecordingFinished() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('回放功能尚未实现')),
            );
          },
          child: Text('回放'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            resetCounting();
          },
          child: Text('重新录制'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(content: Text('确认使用功能尚未实现')),
            // );
            if (outPutFileName != "") {
              if (isRecord) {
                uploadVoice(outPutFileName, global_url_upload_record,
                    {'name': outPutFileName});
              } else {
                uploadVoice(outPutFileName, global_url_detect_record, {});
              }
              Navigator.pop(context);
            }
          },
          child: Text('确认使用'),
        ),
      ],
    );
  }
}

void showRecordPopupDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return RecordPopupDialog();
    },
  );
}

/// 获取临时目录文件
Future<Directory> getTemporaryDirectory() async {
  final dir = await path.getTemporaryDirectory();
  return dir;
}

///获取一个临时文件名
Future<String> getTempFilename({String? filename, String? extension}) async {
  String tempFilename;
  if (filename == null || filename.isEmpty) {
    final dir = await getTemporaryDirectory();
    var name = "recording_${DateTime.now().millisecondsSinceEpoch}.wav";
    if (extension != null) {
      tempFilename = p.join(dir.path, '$name.$extension');
    } else {
      tempFilename = p.join(dir.path, name);
    }
  } else {
    final dir = await getTemporaryDirectory();
    if (extension != null) {
      tempFilename = p.join(dir.path, '$filename.$extension');
    } else {
      tempFilename = p.join(dir.path, filename);
    }
  }

  return tempFilename;
}

Future<String> uploadVoice(
    String filePath, String UrlPath, Map<String, String> addHeaders) async {
  // Replace this URL with the actual FastAPI endpoint URL
  Uri url = Uri.http(global_detector_server_address, UrlPath);

  // Open the file using File class
  File file = File(filePath);

  // Get the file name from the path using the basename method from path package
  String fileName = p.basename(file.path);

  // Create a multipart request
  var request = http.MultipartRequest('POST', url);
  request.headers.addAll({
    'Content-Type': 'application/json',
    'Authorization': global_user_info['token'],
    'Cam-Source': global_current_detector['cam_source']
  });
  request.headers.addAll(addHeaders);
  // Add the file to the request
  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      file.path,
      filename: fileName,
    ),
  );
  // Send the request
  var response = await request.send();

  // Check if the request was successful (status code 200-299)
  if (response.statusCode >= 200 && response.statusCode < 300) {
    print('File uploaded successfully');
    String content = await response.stream.transform(utf8.decoder).join();
    return content;
  } else {
    print('File upload failed with status: ${response.statusCode}');
    return "";
  }
}
