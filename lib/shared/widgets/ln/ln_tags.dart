import 'package:flutter/widgets.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';

enum LnTagTone { forest, amber, slate, rose, lilac }

extension LnTagToneColors on LnTagTone {
  Color background(BuildContext context) {
    final p = context.palette;
    switch (this) {
      case LnTagTone.forest:
        return p.forestSoft;
      case LnTagTone.amber:
        return p.amberSoft;
      case LnTagTone.slate:
        return p.slateSoft;
      case LnTagTone.rose:
        return p.roseSoft;
      case LnTagTone.lilac:
        return p.lilacSoft;
    }
  }

  Color foreground(BuildContext context) {
    final p = context.palette;
    switch (this) {
      case LnTagTone.forest:
        return p.forestInk;
      case LnTagTone.amber:
        return p.amberInk;
      case LnTagTone.slate:
        return p.slate;
      case LnTagTone.rose:
        return p.rose;
      case LnTagTone.lilac:
        return p.lilac;
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
