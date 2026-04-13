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
      context.showErrorSnackBar('잘못된 링크 형식입니다');
      return false;
    }
    final uri = Uri.parse(extracted);

    try
    {
      if (!await canLaunchUrl(uri))
      {
        if (context.mounted)
        {
          context.showErrorSnackBar('링크를 열 수 없습니다');
        }
        return false;
      }

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted)
      {
        context.showErrorSnackBar('링크를 여는 중 오류가 발생했습니다');
      }
      return launched;
    }
    on PlatformException
    {
      if (context.mounted)
      {
        context.showErrorSnackBar('링크를 여는 중 오류가 발생했습니다');
      }
      return false;
    }
  }
}
