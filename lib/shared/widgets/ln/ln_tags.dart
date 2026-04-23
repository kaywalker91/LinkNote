import 'package:flutter/painting.dart';
import 'package:linknote/app/theme/app_colors.dart';

enum LnTagTone { forest, amber, slate, rose, lilac }

extension LnTagToneColors on LnTagTone {
  Color get background {
    switch (this) {
      case LnTagTone.forest:
        return AppColors.forestSoft;
      case LnTagTone.amber:
        return AppColors.amberSoft;
      case LnTagTone.slate:
        return AppColors.slateSoft;
      case LnTagTone.rose:
        return AppColors.roseSoft;
      case LnTagTone.lilac:
        return AppColors.lilacSoft;
    }
  }

  Color get foreground {
    switch (this) {
      case LnTagTone.forest:
        return AppColors.forestInk;
      case LnTagTone.amber:
        return AppColors.amberInk;
      case LnTagTone.slate:
        return AppColors.slate;
      case LnTagTone.rose:
        return AppColors.rose;
      case LnTagTone.lilac:
        return AppColors.lilac;
    }
  }
}

/// Maps well-known tag names to semantic tones. Unknown → slate (neutral).
const Map<String, LnTagTone> _lnTagLookup = {
  'flutter': LnTagTone.forest,
  'dart': LnTagTone.forest,
  'mobile': LnTagTone.forest,
  'backend': LnTagTone.slate,
  'infra': LnTagTone.slate,
  'devops': LnTagTone.slate,
  'tech': LnTagTone.slate,
  'design': LnTagTone.rose,
  'ux': LnTagTone.rose,
  'ui': LnTagTone.rose,
  'ai': LnTagTone.lilac,
  'ml': LnTagTone.lilac,
  'tool': LnTagTone.lilac,
  'prompt': LnTagTone.lilac,
  'favorite': LnTagTone.amber,
  'memo': LnTagTone.amber,
  'note': LnTagTone.amber,
};

LnTagTone lnTagToneFor(String name) {
  return _lnTagLookup[name.trim().toLowerCase()] ?? LnTagTone.slate;
}
