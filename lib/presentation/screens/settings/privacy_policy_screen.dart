// lib/presentation/screens/settings/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Privacy Policy', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Last updated: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}'),
            const SizedBox(height: 24),
            _buildSection(context, '1. Information We Collect',
              'We collect information you provide when using our services, including your name, email, phone number, location, and service preferences.'),
            _buildSection(context, '2. How We Use Your Information',
              'Your information is used to connect you with technicians, process bookings, improve our services, and send relevant notifications.'),
            _buildSection(context, '3. Data Security',
              'We implement industry-standard security measures to protect your personal information. All data is encrypted in transit and at rest.'),
            _buildSection(context, '4. Data Sharing',
              'We share necessary information with technicians to fulfill service requests. We do not sell your personal information to third parties.'),
            _buildSection(context, '5. Your Rights',
              'You can access, update, or delete your information at any time through your profile settings. Contact support for additional assistance.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}

// lib/presentation/screens/settings/terms_conditions_screen.dart
class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Terms & Conditions', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Last updated: ${DateFormat('MMMM d, yyyy').format(DateTime.now())}'),
            const SizedBox(height: 24),
            _buildSection(context, '1. Acceptance of Terms',
              'By using HOMERES, you agree to these terms. If you disagree, please discontinue use of the app.'),
            _buildSection(context, '2. Service Description',
              'HOMERES is a platform connecting homeowners with verified repair technicians. We facilitate bookings but are not responsible for the actual service delivery.'),
            _buildSection(context, '3. User Responsibilities',
              'Users must provide accurate information, treat technicians with respect, and make timely payments for services rendered.'),
            _buildSection(context, '4. Technician Requirements',
              'Technicians must provide valid certifications, maintain professional conduct, and deliver quality services as described.'),
            _buildSection(context, '5. Cancellation Policy',
              'Bookings can be cancelled up to 2 hours before the scheduled time without penalty. Late cancellations may incur charges.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(content, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6)),
        ],
      ),
    );
  }
}