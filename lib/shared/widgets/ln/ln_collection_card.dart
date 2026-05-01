import 'package:flutter/material.dart';
import 'package:linknote/app/theme/app_colors.dart';
import 'package:linknote/app/theme/app_radius.dart';
import 'package:linknote/app/theme/app_spacing.dart';
import 'package:linknote/app/theme/app_text_styles.dart';
import 'package:linknote/features/collection/domain/entity/collection_entity.dart';

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

  @override
  Widget build(BuildContext context) {
    final tone = toneForId(collection.id);
    return Material(
      color: AppColors.bg,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.line),
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
                        color: AppColors.ink,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '링크 ${collection.linkCount}개',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.ink3,
                      ),
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
