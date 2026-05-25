import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ReservationsRecuesScreen extends StatelessWidget {
  const ReservationsRecuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Réservations reçues'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: AppColors.secondary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            tabs: [Tab(text: 'En attente'), Tab(text: 'Confirmées')],
          ),
        ),
        // TODO Semaine 3 : lister les réservations reçues par le Pro
        body: const TabBarView(
          children: [
            Center(child: Text('Aucune réservation en attente')),
            Center(child: Text('Aucune réservation confirmée')),
          ],
        ),
      ),
    );
  }
}
