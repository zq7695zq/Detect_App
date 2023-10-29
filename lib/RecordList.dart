import 'dart:async';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dondaApp/RecordAddDialog.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:audioplayers/audioplayers.dart';

import 'Global.dart';
import 'Packet.dart';

class RecordListPage extends StatefulWidget {
  const RecordListPage({super.key});

  @override
  State<RecordListPage> createState() => _RecordListPageState();

}
final player = AudioPlayer();

class _RecordListPageState extends State<RecordListPage> {
  PlayerState _state = PlayerState.completed;
  late StreamSubscription _playerStateSubscription;
  @override
  void initState(){
    super.initState();
    _playerStateSubscription = player.onPlayerStateChanged.listen((s) {
      setState(() {
        _state = s;
      });
    });
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _state == PlayerState.completed ? Text("待选择录音") : Text("播放录音中···"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: global_records.length,
        itemBuilder: (context, index) {
          var file_name = global_records[index];
          return Dismissible(
            key: Key(file_name),
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.0),
              color: Colors.blueAccent,
              child: Icon(Icons.add_circle_sharp, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) async {
              Map<String, dynamic> ret = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return RecordAddDialog();
                },
              );
              if(ret['state'] == 'success'){
                _addVoice(file_name, ret['text']);
              }
            },
            child: ListTile(
              textColor: global_records_loaded.containsKey(file_name) ? Colors.green : null,  // 如果已加载，背景为绿色
              title: Text(p.basename(file_name)),
              onTap: () {
                if(global_records_loaded.containsKey(file_name)){
                  player.play(global_records_loaded[file_name]["wav"]);
                }else{
                  _loadWavFile(file_name);
                }
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _loadWavFile(String fileName) async {
    var url = Uri.http(global_detector_server_address, global_url_get_wav);
    try {
      final http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': global_user_info['token'],
          'Accept-Encoding': 'gzip',
        },
        body: packet.getWav(global_current_detector['cam_source'], fileName),
      );

      if (response.statusCode == 200) {
        // 解压从服务器接收到的gzip内容
        List<int> decompressedData = GZipDecoder().decodeBytes(response.bodyBytes);
        BytesSource source = BytesSource(Uint8List.fromList(decompressedData));
        await player.play(source);
        setState(() {
          // 更新global_records_loaded
          global_records_loaded[fileName] = {
            'is_loaded': true,
            'wav': source,
          };
        });
      } else {
        setState(() {
          global_records.remove(fileName);
        });
        print('Failed to load wav file: $fileName');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  Future<void> _addVoice(String fileName, String text) async {
    var url = Uri.http(global_detector_server_address, global_url_add_voice);
    http
        .post(url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': global_user_info['token'],
        },
        body: packet.addVoice(global_current_detector['cam_source'], fileName, text))
        .then((http.Response response) async {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              '提示',
              style: TextStyle(fontSize: 15),
            ),
            content: Text(
              response.statusCode == 200 ? "添加成功" : "添加失败",
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
    });
  }
}
