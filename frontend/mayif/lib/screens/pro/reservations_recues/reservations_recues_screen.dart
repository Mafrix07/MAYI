import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/theme_colors.dart';
import '../../../services/reservation_service.dart';
import '../../../widgets/common/glass_card.dart';

class ReservationsRecuesScreen extends StatefulWidget {
  const ReservationsRecuesScreen({super.key});

  @override
  State<ReservationsRecuesScreen> createState() =>
      _ReservationsRecuesScreenState();
}

class _ReservationsRecuesScreenState extends State<ReservationsRecuesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _reservations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await ReservationService.getReservationsRecues();
      if (!mounted) return;
      setState(() {
        _reservations = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erreur réseau';
        _isLoading = false;
      });
    }
  }

  List<dynamic> _filtered(List<String> statuts) =>
      _reservations.where((r) => statuts.contains(r['statut'])).toList();

  Future<void> _changerStatut(int id, String statut) async {
    final label = statut == 'CONFIRMEE' ? 'confirmer' : 'rejeter';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          '${statut == 'CONFIRMEE' ? 'Confirmer' : 'Rejeter'} la réservation',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Voulez-vous vraiment $label cette réservation ?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              statut == 'CONFIRMEE' ? 'Confirmer' : 'Rejeter',
              style: TextStyle(
                  color: statut == 'CONFIRMEE' ? AppColors.primaryLight : Colors.redAccent,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final success = await ReservationService.changerStatut(id, statut);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(statut == 'CONFIRMEE' ? 'Réservation confirmée ✅' : 'Réservation rejetée'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ));
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Erreur lors de la mise à jour'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Réservations Reçues', 
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: context.primaryText)),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.secondary,
            indicatorWeight: 3,
            labelColor: AppColors.secondary,
            unselectedLabelColor: context.hintText,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: const [
              Tab(text: 'À traiter'),
              Tab(text: 'Confirmées'),
              Tab(text: 'Annulées'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.secondary))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 48, color: Colors.white24),
                        const SizedBox(height: 12),
                        Text(_error!, style: TextStyle(color: context.secondaryText)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: _load,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            child: const Text('Réessayer')),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.secondary,
                    onRefresh: _load,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _ReservationList(
                          reservations: _filtered(['EN_ATTENTE', 'ACOMPTE_EN_VERIFICATION']),
                          onConfirmer: (id) => _changerStatut(id, 'CONFIRMEE'),
                          onRejeter: (id) => _changerStatut(id, 'ANNULEE'),
                          showActions: true,
                        ),
                        _ReservationList(
                          reservations: _filtered(['CONFIRMEE']),
                          showActions: false,
                        ),
                        _ReservationList(
                          reservations: _filtered(['ANNULEE']),
                          showActions: false,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

class _ReservationList extends StatelessWidget {
  final List<dynamic> reservations;
  final Function(int)? onConfirmer;
  final Function(int)? onRejeter;
  final bool showActions;

  const _ReservationList({
    required this.reservations,
    this.onConfirmer,
    this.onRejeter,
    required this.showActions,
  });

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 64, color: Colors.white10),
            const SizedBox(height: 16),
            Text('Aucune réservation trouvée', style: TextStyle(color: context.secondaryText, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reservations.length,
      itemBuilder: (context, i) => _ReservationCard(
        reservation: reservations[i],
        onConfirmer: onConfirmer,
        onRejeter: onRejeter,
        showActions: showActions,
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final dynamic reservation;
  final Function(int)? onConfirmer;
  final Function(int)? onRejeter;
  final bool showActions;

  const _ReservationCard({
    required this.reservation,
    this.onConfirmer,
    this.onRejeter,
    required this.showActions,
  });

  Color _statutColor(String statut) {
    switch (statut) {
      case 'CONFIRMEE': return AppColors.primaryLight;
      case 'EN_ATTENTE': return Colors.orange;
      case 'ACOMPTE_EN_VERIFICATION': return Colors.blueAccent;
      case 'ANNULEE': return Colors.redAccent;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statut = reservation['statut'] ?? '';
    final id = reservation['id'] as int;
    final serviceDetails = reservation['service_details'];
    final serviceTitre = serviceDetails?['nom'] ?? 'Service #${reservation['service']}';
    final dateDebut = reservation['date_debut'] ?? '';
    final dateFin = reservation['date_fin'];
    final nombrePersonnes = reservation['nombre_personnes'] ?? 1;
    final montantAcompte = reservation['montant_acompte'] ?? '0';
    final color = _statutColor(statut);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        borderRadius: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(serviceTitre, 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: context.primaryText)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    statut.replaceAll('_', ' '),
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _InfoRow(Icons.calendar_today_rounded, dateFin != null ? '$dateDebut → $dateFin' : dateDebut),
            const SizedBox(height: 8),
            _InfoRow(Icons.person_outline_rounded, '$nombrePersonnes voyageur${nombrePersonnes > 1 ? 's' : ''}'),
            const SizedBox(height: 8),
            _InfoRow(Icons.payments_outlined, '$montantAcompte FCFA (Acompte)'),

            if (showActions && (statut == 'EN_ATTENTE' || statut == 'ACOMPTE_EN_VERIFICATION')) ...[
              const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: AppColors.glassBorder)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onRejeter?.call(id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Rejeter', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => onConfirmer?.call(id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Confirmer', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.secondary),
        const SizedBox(width: 10),
        Text(text, style: TextStyle(color: context.secondaryText, fontSize: 14)),
      ],
    );
  }
}
