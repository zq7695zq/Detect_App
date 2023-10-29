import 'package:flutter/material.dart';

class RecordAddDialog extends StatefulWidget {
  const RecordAddDialog({super.key});

  @override
  _RecordAddDialogState createState() => _RecordAddDialogState();
}

class _RecordAddDialogState extends State<RecordAddDialog> {
  final TextEditingController _textEditingController = TextEditingController();

  void _onSaveButtonPressed() {
    // Close the dialog
    Navigator.pop(context, <String, dynamic>{'text' : _textEditingController.text, 'state' : 'success'});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // 背景颜色为白色
      title: Text('设定语音指令', style: TextStyle(color: Colors.black)), // 标题文字颜色为黑色
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 8), // Set the desired vertical padding
            child:
            TextField(
              style: TextStyle(fontSize: 15),
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: '指令提醒内容',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.transparent),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, <String, dynamic>{'state' : 'error'}),
          style: TextButton.styleFrom(
            foregroundColor: Colors.black, // Adjust padding for size
            textStyle: TextStyle(fontSize: 18), // Increase font size
          ),
          child: Text('取消'),
        ),
        ElevatedButton(
          onPressed: _onSaveButtonPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, // Button background color
          ),
          child: Text('保存', style: TextStyle(fontSize: 18)), // Increase font size
        ),
      ],

    );
  }
}
