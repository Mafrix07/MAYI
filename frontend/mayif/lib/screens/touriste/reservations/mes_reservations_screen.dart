import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../services/reservation_service.dart';

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
      appBar: AppBar(
        title: const Text('Mes Réservations'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'En attente'),
            Tab(text: 'Confirmées'),
            Tab(text: 'Annulées'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
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
    );
  }

  Future<void> _annuler(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Annuler la réservation'),
        content: const Text('Voulez-vous vraiment annuler cette réservation ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Oui', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final success = await ReservationService.annuler(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Réservation annulée'),
              backgroundColor: Colors.orange),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Aucune réservation',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reservations.length,
      itemBuilder: (context, i) {
        final r = reservations[i];
        return _ReservationCard(reservation: r, onAnnuler: onAnnuler);
      },
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final dynamic reservation;
  final Function(int)? onAnnuler;

  const _ReservationCard({required this.reservation, required this.onAnnuler});

  Color _statutColor(String statut) {
    switch (statut) {
      case 'CONFIRMEE': return Colors.green;
      case 'EN_ATTENTE': return Colors.orange;
      case 'ANNULEE': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statut = reservation['statut'] ?? '';
    final id = reservation['id'];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    reservation['service_titre'] ?? 'Service #${reservation['service']}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statutColor(statut).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(statut,
                      style: TextStyle(
                          color: _statutColor(statut),
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.calendar_today, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(reservation['date_debut'] ?? '',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              if (reservation['date_fin'] != null) ...[
                const Text(' → ', style: TextStyle(color: AppColors.textSecondary)),
                Text(reservation['date_fin'],
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ]
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.payments_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('${reservation['montant_acompte'] ?? ''} FCFA',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ]),
            if (statut == 'EN_ATTENTE' && onAnnuler != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => onAnnuler!(id),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
                  label: const Text('Annuler', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
