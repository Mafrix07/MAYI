import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/service_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/theme_colors.dart';
import '../../widgets/home/service_card.dart';
import '../../widgets/common/glass_card.dart';
import '../services/service_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  final String? initialCategory;
  const SearchScreen({super.key, this.initialCategory});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late String _selectedCategory;
  
  // Tâche 1: Filtres prix
  double _prixMin = 0;
  double _prixMax = 200000;

  // Tâche 2: Suggestions autocomplete
  bool _showSuggestions = false;
  List<String> _suggestions = [];

  final List<Map<String, String>> _categories = [
    {'label': 'Tous', 'value': 'TOUT'},
    {'label': 'Hôtels', 'value': 'HEBERGEMENT'},
    {'label': 'Restaurants', 'value': 'SNACK'},
    {'label': 'Activités', 'value': 'ACTIVITE'},
    {'label': 'Transports', 'value': 'TRANSPORT'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'TOUT';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performSearch();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Tâche 2: Cacher suggestions si le texte change
    if (_showSuggestions) setState(() => _showSuggestions = false);

    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch();
      _updateSuggestions(query);
    });
  }

  void _updateSuggestions(String text) {
    if (text.length >= 2) {
      final sp = context.read<ServiceProvider>();
      final titres = sp.services
          .where((s) => s.titre.toLowerCase().contains(text.toLowerCase()))
          .map((s) => s.titre)
          .take(5)
          .toList();
      setState(() {
        _suggestions = titres;
        _showSuggestions = titres.isNotEmpty;
      });
    } else {
      setState(() => _showSuggestions = false);
    }
  }

  void _performSearch() {
    context.read<ServiceProvider>().fetchServices(
      search: _searchController.text,
      typeService: _selectedCategory,
      prixMin: _prixMin,
      prixMax: _prixMax,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NatureBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Rechercher', 
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: context.primaryText)),
          backgroundColor: Colors.transparent,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Tâche 2: Suggestions autocomplete wrap
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GlassCard(
                    borderRadius: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: TextStyle(color: context.primaryText),
                      decoration: InputDecoration(
                        hintText: 'Hôtel, restaurant...',
                        hintStyle: TextStyle(color: context.hintText),
                        border: InputBorder.none,
                        filled: false,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        icon: const Icon(Icons.search, color: AppColors.secondary),
                      ),
                    ),
                  ),
                  if (_showSuggestions) ...[
                    const SizedBox(height: 8),
                    GlassCard(
                      borderRadius: 18,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: _suggestions.map((s) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.search_rounded, color: AppColors.secondary, size: 16),
                          title: Text(s, style: TextStyle(color: context.primaryText, fontSize: 13)),
                          onTap: () {
                            _searchController.text = s;
                            setState(() => _showSuggestions = false);
                            _performSearch();
                          },
                        )).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Categories Chips
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['value'];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(cat['label']!),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() => _selectedCategory = cat['value']!);
                        _performSearch();
                      },
                      selectedColor: AppColors.secondary,
                      backgroundColor: AppColors.secondary.withValues(alpha: 0.06),
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.background : context.secondaryText,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      checkmarkColor: AppColors.background,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: isSelected ? AppColors.secondary : AppColors.glassBorder),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Tâche 1: Filtres prix
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: GlassCard(
                borderRadius: 18,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Prix (FCFA)', style: TextStyle(color: context.secondaryText, fontSize: 13, fontWeight: FontWeight.bold)),
                        Text('${_prixMin.toInt()} — ${_prixMax.toInt()}', style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    RangeSlider(
                      values: RangeValues(_prixMin, _prixMax),
                      min: 0,
                      max: 200000,
                      divisions: 20,
                      activeColor: AppColors.secondary,
                      inactiveColor: context.hintText.withValues(alpha: 0.3),
                      onChanged: (vals) => setState(() {
                        _prixMin = vals.start;
                        _prixMax = vals.end;
                      }),
                      onChangeEnd: (_) => _performSearch(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Results
            Expanded(
              child: Consumer<ServiceProvider>(
                builder: (context, sp, _) {
                  if (sp.isLoading && sp.services.isEmpty) {
                    return _SearchShimmer();
                  }
                  if (sp.hasError) {
                    return _ErrorState(onRetry: _performSearch);
                  }
                  if (sp.services.isEmpty) {
                    return _EmptyState(query: _searchController.text);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                    itemCount: sp.services.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ServiceCard(
                          service: sp.services[index],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ServiceDetailScreen(service: sp.services[index]),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, _) => Shimmer.fromColors(
        baseColor: Colors.white10,
        highlightColor: Colors.white24,
        child: Container(
          height: 180,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text('Erreur de connexion', style: TextStyle(fontSize: 18, color: context.secondaryText)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.background),
            child: const Text('Réessayer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            query.isEmpty 
              ? 'Aucun service disponible' 
              : 'Aucun résultat pour "$query"',
            style: TextStyle(fontSize: 16, color: context.secondaryText),
          ),
        ],
      ),
    );
  }
}
