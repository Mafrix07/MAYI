import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/home/service_card.dart';
import '../../widgets/common/glass_card.dart';
import '../services/service_detail_screen.dart';

class FavorisScreen extends StatefulWidget {
  const FavorisScreen({super.key});

  @override
  State<FavorisScreen> createState() => _FavorisScreenState();
}

class _FavorisScreenState extends State<FavorisScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NatureBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    Text(
                      'Mes Favoris',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text('❤️', style: TextStyle(fontSize: 22)),
                  ],
                ),
              ),

              // Liste
              Expanded(
                child: Consumer<FavoriteProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading && provider.favorites.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.secondary),
                      );
                    }

                    if (provider.favorites.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('🤍', style: TextStyle(fontSize: 64)),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucun favori pour le moment',
                              style: TextStyle(
                                  fontSize: 18, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Explorez et ajoutez vos services préférés',
                              style: TextStyle(color: AppColors.textHint, fontSize: 13),
                            ),
                            const SizedBox(height: 28),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pushNamed(context, '/search'),
                                icon: const Icon(Icons.explore_outlined,
                                    color: AppColors.background),
                                label: const Text('Explorer les services',
                                    style: TextStyle(color: AppColors.background)),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      color: AppColors.secondary,
                      backgroundColor: AppColors.backgroundCard,
                      onRefresh: () => provider.loadFavorites(),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                        itemCount: provider.favorites.length,
                        itemBuilder: (context, index) {
                          return SizedBox(
                            height: 200,
                            child: ServiceCard(
                              service: provider.favorites[index],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ServiceDetailScreen(
                                      service: provider.favorites[index]),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
