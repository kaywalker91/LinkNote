// dart format off
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';
import 'package:linknote/shared/utils/url_sanitizer.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class UrlLauncherHelper
{
  static Future<bool> launch(BuildContext context, String url) async
  {
    final extracted = UrlSanitizer.extract(url);
    if (extracted == null)
    {
      context.showErrorSnackBar('Invalid link format');
      return false;
    }
    final uri = Uri.parse(extracted);

    try
    {
      if (!await canLaunchUrl(uri))
      {
        if (context.mounted)
        {
          context.showErrorSnackBar('Cannot open link');
        }
        return false;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted)
      {
        context.showErrorSnackBar('Failed to open link');
      }
      return launched;
    }
    on PlatformException
    {
      if (context.mounted)
      {
        context.showErrorSnackBar('Failed to open link');
      }
      return false;
    }
  }
}
