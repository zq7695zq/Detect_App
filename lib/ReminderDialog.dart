import 'package:flutter/material.dart';

class ReminderDialog extends StatefulWidget {
  const ReminderDialog({super.key});

  @override
  _ReminderDialogState createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  final TextEditingController _textEditingController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  void _showTimePicker() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null && time != _selectedTime) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  String timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _onSaveButtonPressed() {
    // Implement your logic here to save the selected time and input text
    String inputText = _textEditingController.text;
    // You can use _selectedTime to get the chosen time (hour and minute)
    // Implement the save functionality as per your requirements
    print('Selected Time: ${_selectedTime.format(context)}');
    print('Input Text: $inputText');

    // Close the dialog
    Navigator.pop(context, <String, dynamic>{'time' : timeToString(_selectedTime), 'text' : _textEditingController.text, 'state' : 'success'});
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white, // 背景颜色为白色
      title: Text('提醒设置', style: TextStyle(color: Colors.black)), // 标题文字颜色为黑色
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          Row(
            children: [
              ElevatedButton(
                onPressed: _showTimePicker,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Adjust padding for size
                ),
                child: Text(
                  '选择时间',
                  style: TextStyle(color: Colors.black, fontSize: 18), // Increase font size
                ),
              ),
              SizedBox(width: 16), // Increased spacing between the two components
              Expanded(
                child: Text(
                  '选择的时间: ${_selectedTime.format(context)}',
                  style: TextStyle(fontSize: 18, color: Colors.black), // Increase font size
                ),
              ),
            ],
          ),
          SizedBox(height: 20), // 调整行与输入框之间的间距
          Container(
            padding: EdgeInsets.symmetric(vertical: 8), // Set the desired vertical padding
            child:
            TextField(
              style: TextStyle(fontSize: 15),
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: '别名',
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
