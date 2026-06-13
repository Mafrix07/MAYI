import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/theme_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/common/glass_card.dart';

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  bool _signaledOnly = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final endpoint =
          _signaledOnly ? '/admin/reviews/?signale=true' : '/admin/reviews/';
      final res = await ApiService.get(endpoint);
      if (!mounted) return;
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        setState(() {
          _reviews = list.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _delete(Map<String, dynamic> review) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Supprimer l\'avis',
            style: TextStyle(color: context.primaryText)),
        content: Text(
            'Supprimer l\'avis de ${review['auteur']} sur "${review['service_nom']}" ?',
            style: TextStyle(color: context.secondaryText)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Annuler',
                  style: const TextStyle(color: AppColors.secondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
    if (confirmed != true) return;
    final res = await ApiService.delete('/admin/reviews/${review['id']}/');
    if (!mounted) return;
    if (res.statusCode == 204) {
      setState(() => _reviews.removeWhere((r) => r['id'] == review['id']));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Avis supprimé'),
            backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Avis (${_reviews.length})',
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold, color: context.primaryText)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: context.primaryText),
          actions: [
            Row(
              children: [
                Text('Signalés uniquement',
                    style:
                        TextStyle(color: context.secondaryText, fontSize: 12)),
                Switch(
                  value: _signaledOnly,
                  onChanged: (v) {
                    setState(() => _signaledOnly = v);
                    _load();
                  },
                  activeColor: AppColors.secondary,
                ),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.secondary))
            : _reviews.isEmpty
                ? Center(
                    child: Text('Aucun avis',
                        style: TextStyle(color: context.secondaryText)))
                : RefreshIndicator(
                    color: AppColors.secondary,
                    backgroundColor: AppColors.backgroundCard,
                    onRefresh: _load,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                      itemCount: _reviews.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _ReviewTile(
                          review: _reviews[i],
                          onDelete: () => _delete(_reviews[i])),
                    ),
                  ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Map<String, dynamic> review;
  final VoidCallback onDelete;

  const _ReviewTile({required this.review, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isSignaled = review['est_signale'] == true;
    final note = review['note'] as int? ?? 0;

    return GlassCard(
      borderRadius: 16,
      borderColor: isSignaled
          ? Colors.redAccent.withValues(alpha: 0.4)
          : null,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(review['auteur'] ?? '',
                            style: TextStyle(
                                color: context.primaryText,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                        const SizedBox(width: 8),
                        if (isSignaled)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('SIGNALÉ',
                                style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('Sur : ${review['service_nom'] ?? ''}',
                        style: TextStyle(
                            color: context.secondaryText, fontSize: 11)),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < note ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.secondary,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          if ((review['commentaire'] as String?)?.isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(review['commentaire'] ?? '',
                style: TextStyle(color: context.primaryText, fontSize: 13),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.redAccent, size: 18),
                label: const Text('Supprimer',
                    style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
