
import 'package:url_launcher/url_launcher.dart';

class LauncherUtility{

  static Future<void> makeCall(String phoneNo) async {
    await launchUrl(Uri.parse("tel :$phoneNo"));
  }
}