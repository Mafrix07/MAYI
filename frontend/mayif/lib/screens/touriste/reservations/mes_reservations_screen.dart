import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/reservation_service.dart';
import '../../../widgets/common/glass_card.dart';
import 'package:google_fonts/google_fonts.dart';

class MesReservationsScreen extends StatefulWidget {
  const MesReservationsScreen({super.key});

  @override
  State<MesReservationsScreen> createState() => _MesReservationsScreenState();
}

class _MesReservationsScreenState extends State<MesReservationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoading = true);
    final data = await ReservationService.getMesReservations();
    setState(() {
      _reservations = data;
      _isLoading = false;
    });
  }

  List<dynamic> _filtered(String statut) =>
      _reservations.where((r) => r['statut'] == statut).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Mes Réservations',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.backgroundMid,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'En attente'),
            Tab(text: 'Confirmées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: NatureBackground(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.secondary))
            : RefreshIndicator(
                color: AppColors.secondary,
                backgroundColor: AppColors.backgroundCard,
                onRefresh: _loadReservations,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _ReservationList(
                        reservations: _filtered('EN_ATTENTE'),
                        onAnnuler: _annuler),
                    _ReservationList(
                        reservations: _filtered('CONFIRMEE'),
                        onAnnuler: _annuler),
                    _ReservationList(
                        reservations: _filtered('ANNULEE'),
                        onAnnuler: null),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _annuler(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Annuler la réservation',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Voulez-vous vraiment annuler cette réservation ?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non',
                  style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Oui',
                  style: TextStyle(
                      color: Colors.redAccent, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ReservationService.annuler(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: const Text('Réservation annulée'),
              backgroundColor: AppColors.backgroundCard,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12))),
        );
        _loadReservations();
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _ReservationList extends StatelessWidget {
  final List<dynamic> reservations;
  final Function(int)? onAnnuler;

  const _ReservationList(
      {required this.reservations, required this.onAnnuler});

  @override
  Widget build(BuildContext context) {
    if (reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 80, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text('Aucune réservation ici',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: reservations.length,
      itemBuilder: (context, i) {
        final r = reservations[i];
        return _ReservationTicket(reservation: r, onAnnuler: onAnnuler);
      },
    );
  }
}

class _ReservationTicket extends StatelessWidget {
  final dynamic reservation;
  final Function(int)? onAnnuler;

  const _ReservationTicket(
      {required this.reservation, required this.onAnnuler});

  Color _statutColor(String statut) {
    switch (statut) {
      case 'CONFIRMEE':
        return AppColors.primaryLight;
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'ANNULEE':
        return Colors.redAccent;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statut = reservation['statut'] ?? '';
    final id = reservation['id'];
    final color = _statutColor(statut);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: GlassCard(
        borderRadius: 24,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Partie Haute (Header Ticket)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        shape: BoxShape.circle),
                    child: Icon(Icons.confirmation_number_outlined,
                        color: color, size: 24),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation['service_titre'] ??
                              'Service #${reservation['service']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.textPrimary),
                        ),
                        Text('Réf: #MAYI-$id',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  _StatusBadge(statut: statut, color: color),
                ],
              ),
            ),

            // Ligne de découpe (Ticket style)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: List.generate(
                  30,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 1,
                      color: index.isEven
                          ? AppColors.glassBorder
                          : Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),

            // Partie Basse (Infos)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoItem(
                          label: 'DATE DÉBUT',
                          value: reservation['date_debut'] ?? ''),
                      _InfoItem(
                          label: 'DATE FIN',
                          value: reservation['date_fin'] ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('TOTAL PAYÉ',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            '${reservation['montant_acompte'] ?? ''} FCFA',
                            style: const TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      if (statut == 'EN_ATTENTE' && onAnnuler != null)
                        OutlinedButton(
                          onPressed: () => onAnnuler!(id),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Annuler',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String statut;
  final Color color;
  const _StatusBadge({required this.statut, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Text(
        statut.replaceAll('_', ' '),
        style: const TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;
  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimary)),
      ],
    );
  }
}
