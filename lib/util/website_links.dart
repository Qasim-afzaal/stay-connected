import 'package:url_launcher/url_launcher.dart';

const String kStayConnectedWebsiteUrl = 'https://www.staying-connected.net';
const String kStayConnectedTipsPageUrl =
    'https://www.staying-connected.net/tips-and-tricks';

/// Opens the URL in the browser / default handler when the user taps a link.
Future<void> launchWebsiteUrl(String url) async {
  final uri = Uri.parse(url);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
