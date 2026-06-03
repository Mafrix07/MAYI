import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/theme_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/avis_provider.dart';
import '../common/custom_button.dart';

class AvisBottomSheet extends StatefulWidget {
  final int serviceId;

  const AvisBottomSheet({super.key, required this.serviceId});

  @override
  State<AvisBottomSheet> createState() => _AvisBottomSheetState();
}

class _AvisBottomSheetState extends State<AvisBottomSheet> {
  double _note = 3.0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final avisProvider = context.read<AvisProvider>();

    if (!auth.isAuthenticated) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Veuillez vous connecter pour laisser un avis.')),
      );
      return;
    }

    final success = await avisProvider.posterAvis(
      serviceId: widget.serviceId,
      note: _note,
      commentaire: _commentController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Avis publié ! Merci.'), backgroundColor: Colors.green),
      );
      navigator.pop();
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(avisProvider.errorMessage ?? 'Une erreur est survenue.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Votre avis compte ! 🌟',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Comment s\'est passée votre expérience ?',
            style: TextStyle(color: context.secondaryText),
          ),
          const SizedBox(height: 24),
          RatingBar.builder(
            initialRating: 3,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: AppColors.secondary,
            ),
            onRatingUpdate: (rating) {
              setState(() => _note = rating);
            },
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Écrivez votre commentaire ici...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          Consumer<AvisProvider>(
            builder: (context, provider, _) => CustomButton(
              text: 'Publier mon avis',
              isLoading: provider.isLoading,
              onPressed: () => _submit(context),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
