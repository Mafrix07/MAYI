import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/avis_provider.dart';
import '../../../models/avis.dart';
import '../../../widgets/common/glass_card.dart';

class MesAvisProScreen extends StatefulWidget {
  const MesAvisProScreen({super.key});

  @override
  State<MesAvisProScreen> createState() => _MesAvisProScreenState();
}

class _MesAvisProScreenState extends State<MesAvisProScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AvisProvider>().fetchAvis(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Avis Clients',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundMid,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: NatureBackground(
        child: Consumer<AvisProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                  child:
                      CircularProgressIndicator(color: AppColors.secondary));
            }

            if (provider.avis.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.rate_review_outlined,
                        size: 80, color: AppColors.textSecondary),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun avis reçu pour le moment',
                      style: TextStyle(
                          fontSize: 16, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.avis.length,
              itemBuilder: (context, index) {
                final avis = provider.avis[index];
                return _AvisProCard(avis: avis);
              },
            );
          },
        ),
      ),
    );
  }
}

class _AvisProCard extends StatelessWidget {
  final Avis avis;
  const _AvisProCard({required this.avis});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      avis.auteurNom,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textPrimary),
                    ),
                    Text(
                      'Le ${avis.dateCreation.split('T')[0]}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
                RatingBarIndicator(
                  rating: avis.note,
                  itemBuilder: (context, index) =>
                      const Icon(Icons.star, color: AppColors.secondary),
                  itemCount: 5,
                  itemSize: 18.0,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: AppColors.glassBorder),
            const SizedBox(height: 16),
            Text(
              avis.commentaire,
              style: const TextStyle(
                  fontSize: 14, height: 1.6, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          const Text('La réponse aux avis arrive bientôt !'),
                      backgroundColor: AppColors.backgroundCard,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                icon: const Icon(Icons.reply, size: 18),
                label: const Text('Répondre'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
