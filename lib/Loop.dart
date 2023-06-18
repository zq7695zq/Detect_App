import 'package:awesome_notifications/awesome_notifications.dart';

class event_loop
{
  Future<void> loop()
  async {
    await AwesomeNotifications().createNotification(

      content: NotificationContent(

          id: -1, // -1 is replaced by a random number

          channelKey: 'basic_channel',

          title: 'Huston! The eagle has landed!',

          body:

          "A small step for a man, but a giant leap to Flutter's community!",

          bigPicture: 'https://storage.googleapis.com/cms-storage-bucket/d406c736e7c4c57f5f61.png',

          largeIcon: 'https://storage.googleapis.com/cms-storage-bucket/0dbfcc7a59cd1cf16282.png',

          //'asset://assets/images/balloons-in-sky.jpg',

          notificationLayout: NotificationLayout.BigPicture,

          payload: {'notificationId': '1234567890'}),

    );
  }
}