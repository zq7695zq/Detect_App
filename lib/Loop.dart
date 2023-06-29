import 'package:flutter/cupertino.dart';
import 'package:platform_local_notifications/platform_local_notifications.dart';

class event_loop
{
  Future<void> loop(BuildContext context)
  async {
    bool? isAccepted = await PlatformNotifier.I.requestPermissions();
    print("isAccepted $isAccepted");
    if (context.mounted) {
      await PlatformNotifier.I.showPluginNotification(
        ShowPluginNotificationModel(
            id: DateTime.now().second,
            title: "title",
            body: "检测到异常！！！！！",
            payload: "test"), context);
    }
  }
}