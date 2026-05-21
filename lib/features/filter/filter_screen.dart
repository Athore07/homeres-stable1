// lib/presentation/screens/filter/filter_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../presentation/widgets/common/custom_button.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  double _maxDistance = 10.0;
  double _minRating = 3.0;
  RangeValues _priceRange = const RangeValues(20, 100);
  bool _availableOnly = true;
  bool _verifiedOnly = true;
  String _sortBy = 'rating';
  List<String> _selectedServices = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sort By
            _buildSectionTitle(context, 'Sort By').animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 12),
            _buildSortOptions(context).animate().fadeIn(duration: 400.ms, delay: 100.ms),
            const SizedBox(height: 24),
            
            // Distance
            _buildSectionTitle(context, 'Maximum Distance').animate().fadeIn(duration: 400.ms, delay: 200.ms),
            const SizedBox(height: 12),
            _buildDistanceSlider(context).animate().fadeIn(duration: 400.ms, delay: 300.ms),
            const SizedBox(height: 24),
            
            // Rating
            _buildSectionTitle(context, 'Minimum Rating').animate().fadeIn(duration: 400.ms, delay: 400.ms),
            const SizedBox(height: 12),
            _buildRatingFilter(context).animate().fadeIn(duration: 400.ms, delay: 500.ms),
            const SizedBox(height: 24),
            
            // Price Range
            _buildSectionTitle(context, 'Price Range (\$/hr)').animate().fadeIn(duration: 400.ms, delay: 600.ms),
            const SizedBox(height: 12),
            _buildPriceRange(context).animate().fadeIn(duration: 400.ms, delay: 700.ms),
            const SizedBox(height: 24),
            
            // Services
            _buildSectionTitle(context, 'Services').animate().fadeIn(duration: 400.ms, delay: 800.ms),
            const SizedBox(height: 12),
            _buildServicesFilter(context).animate().fadeIn(duration: 400.ms, delay: 900.ms),
            const SizedBox(height: 24),
            
            // Switches
            _buildSwitchOption(context, 'Available Now', _availableOnly, (value) {
              setState(() => _availableOnly = value);
            }).animate().fadeIn(duration: 400.ms, delay: 1000.ms),
            const SizedBox(height: 8),
            _buildSwitchOption(context, 'Verified Only', _verifiedOnly, (value) {
              setState(() => _verifiedOnly = value);
            }).animate().fadeIn(duration: 400.ms, delay: 1100.ms),
            const SizedBox(height: 32),
            
            // Apply button
            CustomButton(
              label: 'Apply Filters',
              onPressed: () {
                context.pop({
                  'sortBy': _sortBy,
                  'maxDistance': _maxDistance,
                  'minRating': _minRating,
                  'priceRange': _priceRange,
                  'availableOnly': _availableOnly,
                  'verifiedOnly': _verifiedOnly,
                  'services': _selectedServices,
                });
              },
            ).animate().fadeIn(duration: 400.ms, delay: 1200.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSortOptions(BuildContext context) {
    final options = [
      {'value': 'rating', 'label': 'Highest Rated'},
      {'value': 'distance', 'label': 'Nearest'},
      {'value': 'price_low', 'label': 'Price: Low to High'},
      {'value': 'price_high', 'label': 'Price: High to Low'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = _sortBy == option['value'];
        return GestureDetector(
          onTap: () => setState(() => _sortBy = option['value']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Text(
              option['label']!,
              style: TextStyle(
                color: isSelected ? Colors.white : null,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDistanceSlider(BuildContext context) {
    return Column(
      children: [
        Slider(
          value: _maxDistance,
          min: 1,
          max: 50,
          divisions: 49,
          activeColor: AppColors.primary,
          label: '${_maxDistance.toInt()} km',
          onChanged: (value) => setState(() => _maxDistance = value),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('1 km', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
            Text('${_maxDistance.toInt()} km',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const Text('50 km', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingFilter(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final starValue = (index + 1).toDouble();
        final filled = starValue <= _minRating;
        return GestureDetector(
          onTap: () => setState(() => _minRating = starValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              filled ? Icons.star : Icons.star_border,
              color: filled ? AppColors.accent : AppColors.divider,
              size: 36,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPriceRange(BuildContext context) {
    return RangeSlider(
      values: _priceRange,
      min: 10,
      max: 200,
      divisions: 19,
      activeColor: AppColors.primary,
      labels: RangeLabels(
        '\$${_priceRange.start.toInt()}',
        '\$${_priceRange.end.toInt()}',
      ),
      onChanged: (values) => setState(() => _priceRange = values),
    );
  }

  Widget _buildServicesFilter(BuildContext context) {
    final services = [
      'Electrical Repair', 'Plumbing', 'Appliance Repair',
      'AC Service', 'Carpentry', 'Painting',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: services.map((service) {
        final isSelected = _selectedServices.contains(service);
        return FilterChip(
          label: Text(service),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              selected
                  ? _selectedServices.add(service)
                  : _selectedServices.remove(service);
            });
          },
          selectedColor: AppColors.primary.withOpacity(0.2),
          checkmarkColor: AppColors.primary,
        );
      }).toList(),
    );
  }

  Widget _buildSwitchOption(BuildContext context, String title, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _maxDistance = 10.0;
      _minRating = 3.0;
      _priceRange = const RangeValues(20, 100);
      _availableOnly = true;
      _verifiedOnly = true;
      _sortBy = 'rating';
      _selectedServices = [];
    });
  }
}