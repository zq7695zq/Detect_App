import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:dondaApp/ImagesPopUp.dart';
import 'package:intl/intl.dart';
import 'Global.dart';
import 'Packet.dart';

class EventViewPage extends StatefulWidget {
  const EventViewPage({super.key});

  @override
  State<EventViewPage> createState() => _EventViewPageState();
}

class _EventViewPageState extends State<EventViewPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("事件列表"),
      ),
      body: ListView.builder(
        itemCount: global_events.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(global_events[index]['name']),
            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 20.0),
              color: Colors.red,
              child: Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setState(() {
                bool removed = false;
                var url = Uri.http(global_detector_server_address, global_url_del_event);
                http
                    .post(url,
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                          'Authorization': global_user_info['token'],
                        },
                        body: packet.delEvent(global_events[index]['name'],
                            global_current_detector['cam_source']))
                    .then((http.Response response) {
                  final res = json.decode(response.body.toString());
                  if (res['state'] != "del_event_success") {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(
                            '提示',
                            style: TextStyle(fontSize: 15),
                          ),
                          content: Text(
                            "未知错误",
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
                  } else {
                    removed = true;
                  }
                });
                global_events.removeAt(index);
              });
            },
            child: ListTile(
              leading: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(
                  DateTime.fromMillisecondsSinceEpoch(
                      (double.parse(global_events[index]['time']) * 1000)
                          .toInt()))),
              title: Text(utf8.decode(base64Decode(global_events[index]['event_name']))),
              onTap: () {
                EasyLoading.show(status: 'loading...', maskType: EasyLoadingMaskType.black);
                var url = Uri.http(
                    global_detector_server_address, global_url_get_event_frames);
                http
                    .post(url,
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                          'Authorization': global_user_info['token'],
                        },
                        body:
                            packet.getEventFrames(global_events[index]['name']))
                    .then((http.Response response) {
                      print("global_url_get_event_frames");
                  Map<String, dynamic> res =
                      json.decode(response.body.toString());
                  global_current_event_uuid = global_events[index]['name'];
                  global_event_frames[global_current_event_uuid] =
                      res['events'].cast<String>();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Dialog(
                        child: ImagesPopup(),
                      );
                    },
                  );
                  EasyLoading.dismiss();
                });
              },
            ),
          );
        },
      ),
    );
  }
}
