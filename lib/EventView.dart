import 'dart:convert';
import 'dart:async';

import 'package:archive/archive.dart';
import 'package:dondaApp/ImagesPopUp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
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
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("事件列表", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: ListView.builder(
          itemCount: global_events.length,
          padding: EdgeInsets.all(8.0),
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
                  deleteCard(index, context);
                },
                child: EventCard(
                  dateTime: DateFormat('yyyy-MM-dd HH:mm:ss').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          (double.parse(global_events[index]['time']) * 1000)
                              .toInt())),
                  imageLoaded: global_events[index]['cover'],
                  eventName: utf8
                      .decode(base64Decode(global_events[index]['event_name'])),
                  index: index,
                ));
          }),
    );
  }

  void deleteCard(index, context){
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
        setState(() {
          global_events.removeAt(index);
        });
      }
    });
  }
}



class EventCard extends StatelessWidget {
  final String dateTime;
  final Image imageLoaded;
  final String eventName;
  final int index;

  EventCard(
      {required this.dateTime,
      required this.imageLoaded,
      required this.eventName,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 10),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: 200,
              child: ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: imageLoaded,
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            title: Text(dateTime),
            subtitle: Text(eventName),
            trailing: Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              EasyLoading.show(
                  status: 'loading...', maskType: EasyLoadingMaskType.black);
              var url = Uri.http(
                  global_detector_server_address, global_url_get_event_frames);
              http
                  .post(url,
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                        'Authorization': global_user_info['token'],
                        'Accept-Encoding': 'gzip', // 告诉服务器客户端接受gzip压缩内容
                      },
                      body: packet.getEventFrames(global_events[index]['name']))
                  .then((http.Response response) {
                print("global_url_get_event_frames");
                List<int> decompressedData =
                    GZipDecoder().decodeBytes(response.bodyBytes);
                String responseBody = utf8.decode(decompressedData);
                Map<String, dynamic> res = json.decode(responseBody);
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
        ],
      ),
    );
  }
}
