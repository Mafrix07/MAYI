import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/theme_colors.dart';
import '../../services/api_service.dart';
import '../../widgets/common/glass_card.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _filterRole = 'TOUS';

  static const _roles = ['TOUS', 'TOURISTE', 'PROFESSIONNEL', 'SUPPORT', 'ADMIN'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final endpoint = _filterRole == 'TOUS'
          ? '/admin/users/'
          : '/admin/users/?role=$_filterRole';
      final res = await ApiService.get(endpoint);
      if (!mounted) return;
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;
        setState(() {
          _users = list.cast<Map<String, dynamic>>();
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _toggle(Map<String, dynamic> user) async {
    final res = await ApiService.patch('/admin/users/${user['id']}/toggle/', {});
    if (!mounted) return;
    if (res.statusCode == 200) {
      final updated = jsonDecode(res.body);
      setState(() {
        final idx = _users.indexWhere((u) => u['id'] == user['id']);
        if (idx != -1) _users[idx]['is_active'] = updated['is_active'];
      });
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'ADMIN':
        return Colors.redAccent;
      case 'SUPPORT':
        return Colors.orange;
      case 'PROFESSIONNEL':
        return AppColors.secondary;
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Utilisateurs',
              style: GoogleFonts.playfairDisplay(
                  fontWeight: FontWeight.bold, color: context.primaryText)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: context.primaryText),
        ),
        body: Column(
          children: [
            // Filter chips
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _roles.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final r = _roles[i];
                  final selected = _filterRole == r;
                  return FilterChip(
                    label: Text(r,
                        style: TextStyle(
                            color: selected ? Colors.white : context.secondaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _filterRole = r);
                      _load();
                    },
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
                      child: CircularProgressIndicator(color: AppColors.secondary))
                  : _users.isEmpty
                      ? Center(
                          child: Text('Aucun utilisateur',
                              style: TextStyle(color: context.secondaryText)))
                      : RefreshIndicator(
                          color: AppColors.secondary,
                          backgroundColor: AppColors.backgroundCard,
                          onRefresh: _load,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                            itemCount: _users.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) =>
                                _UserTile(user: _users[i],
                                    roleColor: _roleColor(_users[i]['role'] ?? ''),
                                    onToggle: () => _toggle(_users[i])),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final Color roleColor;
  final VoidCallback onToggle;

  const _UserTile(
      {required this.user, required this.roleColor, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isActive = user['is_active'] == true;
    final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    final displayName = name.isNotEmpty ? name : user['username'] ?? '';

    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: roleColor.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                displayName.isNotEmpty
                    ? displayName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName,
                    style: TextStyle(
                        color: context.primaryText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Text(user['email'] ?? '',
                    style:
                        TextStyle(color: context.secondaryText, fontSize: 11)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(user['role'] ?? '',
                      style: TextStyle(
                          color: roleColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Switch(
                value: isActive,
                onChanged: (_) => onToggle(),
                activeColor: AppColors.secondary,
                inactiveThumbColor: Colors.grey,
              ),
              Text(isActive ? 'Actif' : 'Inactif',
                  style: TextStyle(
                      fontSize: 10,
                      color: isActive
                          ? AppColors.secondary
                          : context.secondaryText)),
            ],
          ),
        ],
      ),
    );
  }
}
