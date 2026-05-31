import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
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
        backgroundColor: AppColors.backgroundMid,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          '${statut == 'CONFIRMEE' ? 'Confirmer' : 'Rejeter'} la réservation',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Voulez-vous vraiment $label cette réservation ?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              statut == 'CONFIRMEE' ? 'Confirmer' : 'Rejeter',
              style: TextStyle(
                  color: statut == 'CONFIRMEE'
                      ? AppColors.primaryLight
                      : Colors.redAccent,
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
        content: Text(statut == 'CONFIRMEE'
            ? 'Réservation confirmée ✅'
            : 'Réservation rejetée'),
        backgroundColor: statut == 'CONFIRMEE'
            ? AppColors.backgroundCard
            : AppColors.backgroundCard,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erreur lors de la mise à jour'),
          backgroundColor: AppColors.backgroundCard,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Réservations reçues'),
        backgroundColor: AppColors.backgroundMid,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          tabs: [
            Tab(
                text:
                    'En attente (${_filtered(['EN_ATTENTE', 'ACOMPTE_EN_VERIFICATION']).length})'),
            Tab(text: 'Confirmées (${_filtered(['CONFIRMEE']).length})'),
            const Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: NatureBackground(
        child: _isLoading
            ? const Center(
                child:
                    CircularProgressIndicator(color: AppColors.secondary))
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off,
                            size: 48, color: AppColors.textSecondary),
                        const SizedBox(height: 12),
                        Text(_error!,
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 12),
                        ElevatedButton(
                            onPressed: _load,
                            child: const Text('Réessayer')),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.secondary,
                    backgroundColor: AppColors.backgroundCard,
                    onRefresh: _load,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _ReservationList(
                          reservations: _filtered(
                              ['EN_ATTENTE', 'ACOMPTE_EN_VERIFICATION']),
                          onConfirmer: (id) =>
                              _changerStatut(id, 'CONFIRMEE'),
                          onRejeter: (id) =>
                              _changerStatut(id, 'ANNULEE'),
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
            Icon(
              showActions
                  ? Icons.hourglass_empty
                  : Icons.check_circle_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              showActions
                  ? 'Aucune réservation en attente'
                  : 'Aucune réservation ici',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
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
      case 'CONFIRMEE':
        return AppColors.primaryLight;
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'ACOMPTE_EN_VERIFICATION':
        return Colors.blue;
      case 'ANNULEE':
        return Colors.redAccent;
      default:
        return AppColors.textSecondary;
    }
  }

  String _statutLabel(String statut) {
    switch (statut) {
      case 'EN_ATTENTE':
        return 'En attente';
      case 'ACOMPTE_EN_VERIFICATION':
        return 'Acompte reçu';
      case 'CONFIRMEE':
        return 'Confirmée';
      case 'ANNULEE':
        return 'Annulée';
      default:
        return statut;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statut = reservation['statut'] ?? '';
    final id = reservation['id'] as int;
    final serviceDetails = reservation['service_details'];
    final serviceTitre =
        serviceDetails?['nom'] ?? 'Service #${reservation['service']}';
    final dateDebut = reservation['date_debut'] ?? '';
    final dateFin = reservation['date_fin'];
    final nombrePersonnes = reservation['nombre_personnes'] ?? 1;
    final montantAcompte = reservation['montant_acompte'] ?? '0';
    final color = _statutColor(statut);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        borderRadius: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête : service + badge statut
            Row(
              children: [
                Expanded(
                  child: Text(
                    serviceTitre,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _statutLabel(statut),
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _InfoRow(Icons.calendar_today,
                dateFin != null ? '$dateDebut → $dateFin' : dateDebut),
            const SizedBox(height: 4),
            _InfoRow(Icons.people_outline,
                '$nombrePersonnes personne${nombrePersonnes > 1 ? 's' : ''}'),
            const SizedBox(height: 4),
            _InfoRow(Icons.payments_outlined,
                '$montantAcompte FCFA (acompte)'),

            if (showActions &&
                (statut == 'EN_ATTENTE' ||
                    statut == 'ACOMPTE_EN_VERIFICATION')) ...[
              const SizedBox(height: 16),
              Divider(
                  height: 1,
                  color: AppColors.glassBorder),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onRejeter?.call(id),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Rejeter'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => onConfirmer?.call(id),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Confirmer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
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
        Icon(icon, size: 14, color: AppColors.secondary),
        const SizedBox(width: 6),
        Text(text,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}
