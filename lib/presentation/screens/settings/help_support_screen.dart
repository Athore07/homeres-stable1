// lib/presentation/screens/settings/help_support_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../widgets/common/custom_textfield.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  
  final List<Map<String, dynamic>> _faqCategories = [
    {'name': 'All', 'icon': Icons.all_inclusive},
    {'name': 'Booking', 'icon': Icons.calendar_today},
    {'name': 'Payment', 'icon': Icons.payment},
    {'name': 'Account', 'icon': Icons.person},
    {'name': 'Technical', 'icon': Icons.build},
  ];

  final Map<String, List<Map<String, String>>> _faqs = {
    'Booking': [
      {'q': 'How do I book a technician?', 'a': 'Browse services from the home screen, select a service, choose a technician, pick date and time, describe your problem, and confirm booking.'},
      {'q': 'Can I cancel a booking?', 'a': 'Yes, you can cancel up to 2 hours before the scheduled time without any charges. Go to Booking History, select the booking, and tap Cancel.'},
      {'q': 'How do I reschedule?', 'a': 'Go to Booking History, select the booking you want to reschedule, and tap Reschedule. Choose a new date and time.'},
      {'q': 'What if the technician is late?', 'a': 'You can track the technician in real-time. If they are more than 30 minutes late, contact our support team for assistance.'},
    ],
    'Payment': [
      {'q': 'What payment methods are accepted?', 'a': 'We accept credit/debit cards, mobile money (M-Pesa, Airtel Money), and bank transfers.'},
      {'q': 'How is pricing determined?', 'a': 'Pricing is based on the service type, technician rates, and whether it is an emergency service. You will see the total before confirming.'},
      {'q': 'When am I charged?', 'a': 'Payment is processed after the service is completed and you confirm satisfaction with the work done.'},
      {'q': 'How do refunds work?', 'a': 'If you are not satisfied, contact support within 24 hours. Refunds are processed within 3-5 business days.'},
    ],
    'Account': [
      {'q': 'How do I change my password?', 'a': 'Go to Settings > Change Password. Enter your current password and new password.'},
      {'q': 'How do I update my profile?', 'a': 'Go to Settings > Profile to update your name, phone number, address, and profile picture.'},
      {'q': 'How do I delete my account?', 'a': 'Go to Settings > Profile, scroll to Danger Zone, and tap Delete Account. Note that this is permanent.'},
    ],
    'Technical': [
      {'q': 'The app is not loading properly', 'a': 'Try closing and reopening the app. Check your internet connection. If the problem persists, clear app cache in settings.'},
      {'q': 'How do I enable notifications?', 'a': 'Go to Settings > Notifications to manage your notification preferences.'},
      {'q': 'How accurate is the GPS tracking?', 'a': 'GPS tracking is accurate within 10-20 meters. Make sure location services are enabled on your device.'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomTextField(
              controller: _searchController,
              label: 'Search',
              hint: 'Search for help topics...',
              prefixIcon: Icons.search,
            ),
          ).animate().fadeIn(duration: 400.ms),
          
          // Category tabs
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _faqCategories.map((category) {
                final isSelected = _selectedCategory == category['name'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category['icon'] as IconData,
                          size: 16,
                          color: isSelected ? Colors.white : null,
                        ),
                        const SizedBox(width: 4),
                        Text(category['name']!),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = category['name']!);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
          
          const SizedBox(height: 8),
          
          // FAQ List
          Expanded(
            child: _buildFaqList(context),
          ),
        ],
      ),
      // Floating support button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showContactOptions(context),
        icon: const Icon(Icons.headset_mic),
        label: const Text('Contact Support'),
      ).animate().fadeIn(duration: 400.ms).scale(
        begin: const Offset(0.5, 0.5),
        curve: Curves.elasticOut,
      ),
    );
  }

  Widget _buildFaqList(BuildContext context) {
    List<Map<String, String>> allFaqs = [];
    
    if (_selectedCategory == 'All') {
      _faqs.forEach((category, faqs) {
        allFaqs.addAll(faqs);
      });
    } else if (_faqs.containsKey(_selectedCategory)) {
      allFaqs = _faqs[_selectedCategory]!;
    }
    
    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      allFaqs = allFaqs.where((faq) {
        return faq['q']!.toLowerCase().contains(query) ||
               faq['a']!.toLowerCase().contains(query);
      }).toList();
    }
    
    if (allFaqs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: allFaqs.length,
      itemBuilder: (context, index) {
        final faq = allFaqs[index];
        return _buildFaqTile(context, faq, index);
      },
    );
  }

  Widget _buildFaqTile(BuildContext context, Map<String, String> faq, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.help_outline, color: AppColors.primary, size: 20),
        ),
        title: Text(
          faq['q']!,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Text(
            faq['a']!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_up_outlined, size: 16),
                label: const Text('Helpful'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.thumb_down_outlined, size: 16),
                label: const Text('Not helpful'),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(
      duration: 400.ms,
      delay: Duration(milliseconds: 200 + (index * 100)),
    );
  }

  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Contact Support',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose how you would like to reach us',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            _buildContactOption(
              context,
              icon: Icons.chat_bubble,
              title: 'Live Chat',
              subtitle: 'Chat with our support team in real-time',
              color: AppColors.success,
              onTap: () {
                Navigator.pop(context);
                // Navigate to chat
              },
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              context,
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'support@homeres.com',
              color: AppColors.primary,
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri.parse('mailto:support@homeres.com?subject=HOMERES Support');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              context,
              icon: Icons.phone,
              title: 'Call Us',
              subtitle: '+255 712 345 678',
              color: AppColors.info,
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri.parse('tel:+255712345678');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildContactOption(
              context,
              icon: Icons.message,
              title: 'WhatsApp',
              subtitle: '+255 712 345 678',
              color: AppColors.success,
              onTap: () async {
                Navigator.pop(context);
                final uri = Uri.parse('https://wa.me/255712345678');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}