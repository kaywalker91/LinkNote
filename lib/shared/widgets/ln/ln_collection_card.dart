import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_radius.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/app/theme/app_text_styles.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';
import 'package:linknote/shared/extensions/context_extensions.dart';

enum LnCollectionTone { forest, lilac, slate, amber }

extension LnCollectionToneX on LnCollectionTone {
  List<Color> get gradient {
    switch (this) {
      case LnCollectionTone.forest:
        return const [Color(0xFF4E9C7B), Color(0xFF1F6E53)];
      case LnCollectionTone.lilac:
        return const [Color(0xFFA595C9), Color(0xFF4F4370)];
      case LnCollectionTone.slate:
        return const [Color(0xFF526578), Color(0xFF2E3A47)];
      case LnCollectionTone.amber:
        return const [Color(0xFFE0A25A), Color(0xFF8F5B1F)];
    }
  }
}

class LnCollectionCard extends StatelessWidget {
  const LnCollectionCard({
    required this.collection,
    super.key,
    this.onTap,
    this.onLongPress,
  });

  final CollectionEntity collection;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  static LnCollectionTone toneForId(String id) {
    final hash = id.codeUnits.fold<int>(
      0,
      (acc, c) => (acc * 31 + c) & 0x7fffffff,
    );
    const values = LnCollectionTone.values;
    return values[hash % values.length];
  }

  // Visual indicator only — NOT access control. A Lock pill does not gate
  // entry; real enforcement (backend RLS) is a separate track. These pills
  // surface the collection's own visibility/lock state, mirroring the parent
  // pills on LnLinkCard.
  List<Widget> _visibilityPills(BuildContext context) {
    final palette = context.palette;
    return [
      if (collection.visibility == CollectionVisibility.public)
        _pill(
          icon: Icons.public,
          bg: palette.forestSoft,
          fg: palette.forestInk,
          label: 'Public',
        ),
      if (collection.lockedAt != null)
        _pill(
          icon: Icons.lock_outline,
          bg: palette.slateSoft,
          fg: palette.slate,
          label: 'Locked',
        ),
    ];
  }

  Widget _pill({
    required IconData icon,
    required Color bg,
    required Color fg,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Tooltip(
        message: label,
        child: Semantics(
          label: label,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 12, color: fg),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final tone = toneForId(collection.id);
    return Material(
      color: palette.bg,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: palette.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(tone: tone),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm + 2,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      style: AppTextStyles.titleM.copyWith(
                        color: palette.ink,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _CountRow(
                      label: '링크 ${collection.linkCount}개',
                      pills: _visibilityPills(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Link-count caption with optional trailing visibility/lock pills. When there
/// are no pills the bare [Text] is rendered (identical to the pre-pill layout),
/// keeping the no-pill golden byte-stable.
class _CountRow extends StatelessWidget {
  const _CountRow({required this.label, required this.pills});

  final String label;
  final List<Widget> pills;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final text = Text(
      label,
      style: AppTextStyles.caption.copyWith(color: palette.ink3),
    );
    if (pills.isEmpty) return text;
    return Row(
      children: [
        text,
        const Spacer(),
        ...pills,
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.tone});

  final LnCollectionTone tone;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: tone.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.sm + 2),
            child: Icon(
              Icons.folder_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
