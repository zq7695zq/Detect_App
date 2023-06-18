import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'Global.dart';

class ImagesPopup extends StatefulWidget {
  @override
  _ImagesPopupState createState() => _ImagesPopupState();
}

class _ImagesPopupState extends State<ImagesPopup> with SingleTickerProviderStateMixin {

  late final List<String>? base64Images;
  late final List<Image>? images;
  late final Timer timer;
  int _index = 0;
  late bool _disposed;

  @override
  void initState() {

    super.initState();
    _disposed = false;
    this.base64Images = global_event_frames[global_current_event_name];
    images = [];
    for(var b in this.base64Images!)
    {
      images?.add(Image.memory(
        base64Decode(b),
        key: UniqueKey(), // Use a unique key associated with the image data
      ));
    }
    Future.delayed(Duration(milliseconds: 200), () {
      _updateImage(images!.length, Duration(milliseconds: 40));
    });
  }

  _updateImage(int count, Duration millisecond) {
    Future.delayed(millisecond, () {
      if (_disposed) return;
      setState(() {
        _index = images!.length - count--;
      });
      if (count < 1) {
        count = images!.length;
      }
      _updateImage(count, millisecond);
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: IndexedStack(
        index: _index,
        children: this.images!,
      ),
    );
  }


}
