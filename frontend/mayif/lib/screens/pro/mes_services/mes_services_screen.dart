import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class MesServicesScreen extends StatelessWidget {
  const MesServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Services'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      // TODO Semaine 3 : liste + créer + modifier services
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.store_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Gestion des services',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Disponible en Semaine 3',
                style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter un service',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
