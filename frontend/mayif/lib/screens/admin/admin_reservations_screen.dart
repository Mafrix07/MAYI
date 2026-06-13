import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/theme_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/common/glass_card.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  List<Map<String, dynamic>> _reservations = [];
  bool _isLoading = true;
  String _filterStatut = 'TOUS';

  static const _statuts = [
    'TOUS',
    'EN_ATTENTE',
    'CONFIRMEE',
    'ANNULEE',
    'TERMINEE',
    'ACOMPTE_EN_VERIFICATION',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get('/reservations/');
      if (!mounted) return;
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        List<dynamic> list = data is List ? data : data['results'] ?? [];
        setState(() {
          _reservations = list.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filterStatut == 'TOUS') return _reservations;
    return _reservations
        .where((r) => r['statut'] == _filterStatut)
        .toList();
  }

  Color _statutColor(String statut) {
    switch (statut) {
      case 'CONFIRMEE':
        return Colors.green;
      case 'ANNULEE':
        return Colors.redAccent;
      case 'TERMINEE':
        return Colors.blue;
      case 'ACOMPTE_EN_VERIFICATION':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _statutLabel(String statut) {
    switch (statut) {
      case 'EN_ATTENTE':
        return 'En attente';
      case 'CONFIRMEE':
        return 'Confirmée';
      case 'ANNULEE':
        return 'Annulée';
      case 'TERMINEE':
        return 'Terminée';
      case 'ACOMPTE_EN_VERIFICATION':
        return 'Vérification';
      default:
        return statut;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Réservations (${_reservations.length})',
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold, color: context.primaryText)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: context.primaryText),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _statuts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final s = _statuts[i];
                  final selected = _filterStatut == s;
                  return FilterChip(
                    label: Text(_statutLabel(s),
                        style: TextStyle(
                            color: selected
                                ? Colors.white
                                : context.secondaryText,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    selected: selected,
                    onSelected: (_) => setState(() => _filterStatut = s),
                    backgroundColor: AppColors.glassFill,
                    selectedColor: AppColors.secondary,
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    side: BorderSide(
                        color: selected
                            ? AppColors.secondary
                            : AppColors.glassBorder),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.secondary))
                  : filtered.isEmpty
                      ? Center(
                          child: Text('Aucune réservation',
                              style:
                                  TextStyle(color: context.secondaryText)))
                      : RefreshIndicator(
                          color: AppColors.secondary,
                          backgroundColor: AppColors.backgroundCard,
                          onRefresh: _load,
                          child: ListView.separated(
                            padding:
                                const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) =>
                                _ReservationTile(
                              reservation: filtered[i],
                              statutColor: _statutColor(
                                  filtered[i]['statut'] ?? ''),
                              statutLabel: _statutLabel(
                                  filtered[i]['statut'] ?? ''),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservationTile extends StatelessWidget {
  final Map<String, dynamic> reservation;
  final Color statutColor;
  final String statutLabel;

  const _ReservationTile({
    required this.reservation,
    required this.statutColor,
    required this.statutLabel,
  });

  @override
  Widget build(BuildContext context) {
    final service = reservation['service_details'] as Map<String, dynamic>?;
    final serviceNom = service?['nom'] ?? 'Service #${reservation['service']}';
    final touriste = reservation['touriste'];
    final touristeNom = touriste is Map
        ? '${touriste['first_name'] ?? ''} ${touriste['last_name'] ?? touriste['username'] ?? ''}'.trim()
        : 'Touriste #${reservation['touriste']}';
    final dateStr = (reservation['date_creation'] as String?)?.substring(0, 10) ?? '';

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: statutColor.withValues(alpha: 0.12),
            ),
            child: Icon(Icons.receipt_long_rounded,
                color: statutColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(serviceNom,
                    style: TextStyle(
                        color: context.primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(touristeNom,
                    style: TextStyle(
                        color: context.secondaryText, fontSize: 11)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: statutColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(statutLabel,
                          style: TextStyle(
                              color: statutColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(dateStr,
                        style: TextStyle(
                            color: context.secondaryText, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          Text('${reservation['prix_total'] ?? ''}\nFCFA',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
