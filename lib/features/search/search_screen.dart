// lib/presentation/screens/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../presentation/widgets/technician/technician_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _recentSearches = [
    'Electrician near me',
    'Plumber',
    'AC repair',
    'Emergency service',
  ];
  
  final List<Map<String, dynamic>> _searchResults = [
    {
      'name': 'John Doe',
      'specialty': 'Electrician',
      'rating': 4.8,
      'jobs': 156,
      'distance': '1.2 km',
      'available': true,
    },
    {
      'name': 'Jane Smith',
      'specialty': 'Plumber',
      'rating': 4.6,
      'jobs': 98,
      'distance': '2.5 km',
      'available': false,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search services or technicians...',
            border: InputBorder.none,
          ),
          onChanged: (value) => setState(() {}),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
            ),
        ],
      ),
      body: _searchController.text.isEmpty
          ? _buildSuggestions(context)
          : _buildResults(context),
    );
  }

  Widget _buildSuggestions(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent searches
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Searches', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text('Clear All')),
            ],
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 8),
          ..._recentSearches.map((search) => ListTile(
            leading: const Icon(Icons.history, size: 20),
            title: Text(search),
            trailing: const Icon(Icons.close, size: 16),
            onTap: () {
              _searchController.text = search;
              setState(() {});
            },
            dense: true,
          )),
          const SizedBox(height: 24),
          // Popular services
          Text('Popular Services', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))
            .animate().fadeIn(duration: 400.ms, delay: 200.ms),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Electrical', 'Plumbing', 'AC Service', 'Appliance Repair',
              'Carpentry', 'Painting', 'Emergency', 'Installation',
            ].map((tag) => GestureDetector(
              onTap: () {
                _searchController.text = tag;
                setState(() {});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tag),
              ),
            )).toList(),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildResults(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final tech = _searchResults[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TechnicianCard(
            name: tech['name'],
            specialty: tech['specialty'],
            rating: tech['rating'],
            totalJobs: tech['jobs'],
            distance: tech['distance'],
            isAvailable: tech['available'],
            onTap: () {},
          ),
        ).animate().fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: index * 100),
        );
      },
    );
  }
}