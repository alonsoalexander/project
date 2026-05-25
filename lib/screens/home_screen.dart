import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';



import '../theme/app_theme.dart';


// Maps Home.tsx — hero section + Veckans klipp grid

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  static const _weeklyDeals = [
    (id: 2,  name: 'Äpplen',  price: 25, salePrice: 19, image: '🍎', unit: 'kg'),
    (id: 7,  name: 'Mjölk',   price: 14, salePrice: 10, image: '🥛', unit: 'l'),
    (id: 6,  name: 'Bröd',    price: 32, salePrice: 25, image: '🍞', unit: 'st'),
    (id: 1,  name: 'Bananer', price: 18, salePrice: 14, image: '🍌', unit: 'kg'),
    (id: 15, name: 'Ägg',     price: 38, salePrice: 29, image: '🥚', unit: 'förp'),
    (id: 20, name: 'Juice',   price: 24, salePrice: 18, image: '🧃', unit: 'l'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Hero section ──────────────────────────────────────────────────────
        _HeroSection(),

        // ── Veckans klipp ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // Gradient header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF16A34A), Color(0xFFDC2626)],
                    ),
                  ),
                  child: Text(
                    'Veckans klipp',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),

                // Deal cards grid
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: LayoutBuilder(builder: (context, constraints) {
                    final crossAxisCount =
                        constraints.maxWidth > 800 ? 6 : constraints.maxWidth > 500 ? 3 : 2;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: AppSpacing.md,
                        mainAxisSpacing: AppSpacing.md,
                        childAspectRatio: 0.65,
                      ),
                      itemCount: _weeklyDeals.length,
                      itemBuilder: (context, index) {
                        final deal = _weeklyDeals[index];
                        return _DealCard(deal: deal);
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background gradient (replacing the hero image)
          Image.asset(
            'assets/feature-image.png',
            fit: BoxFit.cover,
            //errorBuilder: (_, __, ___) => _fallbackGradient(),
          ),

          // Dark overlay (matches bg-black/50 in React)
          Container(color: Colors.black.withValues(alpha: 0.4)),

          // Content card (matches the white/95 card in React)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxxl,
                  vertical: AppSpacing.xxl,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Välkommen till iMat',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: AppColors.foreground,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Handla färska varor direkt hem till dig.\nEnkel betalning, snabb leverans.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.foreground.withValues(alpha: 0.8),
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/products'),
                      icon: const Icon(Icons.arrow_forward, size: 22),
                      label: const Text(
                        'Börja handla',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xxl,
                          vertical: AppSpacing.lg,
                        ),
                        elevation: 8,
                        shadowColor: Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DealCard extends StatelessWidget {
  final ({int id, String name, int price, int salePrice, String image, String unit}) deal;

  const _DealCard({required this.deal});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/products'),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kampanj badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Kampanj',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Emoji
              Center(
                child: Text(deal.image,
                    style: const TextStyle(fontSize: 44)),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Name
              Text(
                deal.name,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),

              // Prices
              Text(
                '${deal.price} kr/${deal.unit}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.mutedForeground,
                    ),
              ),
              Text(
                '${deal.salePrice} kr/${deal.unit}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDC2626),
                    ),
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/products'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    minimumSize: const Size(0, 32),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: const Text('Handla'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
