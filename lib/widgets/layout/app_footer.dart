import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';

// Maps the 3-column footer from Root.tsx
// Columns: Kundservice | Om oss | Följ oss

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.foreground,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xxl,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand column
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.small,
                      ),
                      child: const Center(
                        child: Text('🛒', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'iMat',
                      style:
                          Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: AppColors.primaryForeground,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Din digitala matbutik\nmed fokus på kvalitet.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primaryForeground.withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),

          // Kundservice
          Expanded(
            child: _FooterColumn(
              title: 'Kundservice',
              links: [
                _FooterLink(label: 'Vanliga frågor', onTap: () {}),
                _FooterLink(label: 'Returnera vara', onTap: () {}),
                _FooterLink(
                  label: 'Kontakta oss',
                  onTap: () => context.go('/contact'),
                ),
              ],
            ),
          ),

          // Om oss
          Expanded(
            child: _FooterColumn(
              title: 'Om oss',
              links: [
                _FooterLink(label: 'Vår historia', onTap: () {}),
                _FooterLink(label: 'Hållbarhet', onTap: () {}),
                _FooterLink(label: 'Karriär', onTap: () {}),
              ],
            ),
          ),

          // Följ oss
          Expanded(
            child: _FooterColumn(
              title: 'Följ oss',
              links: [
                _FooterLink(label: 'Instagram', onTap: () {}),
                _FooterLink(label: 'Facebook', onTap: () {}),
                _FooterLink(label: 'TikTok', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<_FooterLink> links;

  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.primaryForeground,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...links,
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primaryForeground.withValues(alpha: 0.7),
              ),
        ),
      ),
    );
  }
}
