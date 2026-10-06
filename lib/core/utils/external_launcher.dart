import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class ExternalLauncher {
  static Future<void> launchMapSearch(String query) async {
    Uri url;
    if (Platform.isAndroid) {
      url = Uri.parse('geo:0,0?q=${Uri.encodeComponent(query)}');
    } else if (Platform.isIOS) {
      url = Uri.parse('maps://?q=${Uri.encodeComponent(query)}');
    } else {
      url = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
      );
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to browser
        final fallbackUrl = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
        );
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Final fallback
      final webUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
      );
      await launchUrl(webUrl, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> launchEmail(
    String email, {
    String? subject,
    String? body,
  }) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters({
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }),
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Silent fail or log
    }
  }

  static Future<void> launchPhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      // Silent fail or log
    }
  }

  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.limanex.vitacase';
  static const String playStoreMarketUri = 'market://details?id=com.limanex.vitacase';

  static Future<bool> openPlayStore({String url = playStoreUrl}) async {
    try {
      final marketUri = Uri.parse(playStoreMarketUri);
      if (await canLaunchUrl(marketUri)) {
        return await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    try {
      final webUri = Uri.parse(url);
      if (await canLaunchUrl(webUri)) {
        return await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Silent fail
    }
    return false;
  }

  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}
