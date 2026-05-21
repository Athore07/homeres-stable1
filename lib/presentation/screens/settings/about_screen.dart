// lib/presentation/screens/settings/about_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appVersion = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
          _buildNumber = packageInfo.buildNumber;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(slivers: [
        // Hero Header
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark ? [const Color(0xFF1E293B), const Color(0xFF0F172A)] : [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(children: [
              // Logo
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))]),
                child: const Icon(Icons.home_repair_service_rounded, size: 46, color: AppColors.primary),
              ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.3, 0.3), curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text('HOMERES', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 6)),
              const SizedBox(height: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: const Text('Home Repair Experts', style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 2))),
            ]).animate().fadeIn(duration: 400.ms, delay: 200.ms),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Version Card
              _VersionCard(version: _appVersion, buildNumber: _buildNumber).animate().fadeIn(duration: 400.ms).slideY(begin: 10),

              const SizedBox(height: 20),

              // Mission Statement
              _SectionCard(
                icon: Icons.rocket_launch_rounded,
                iconColor: AppColors.primary,
                title: 'Our Mission',
                body: 'We\'re on a mission to revolutionize home repairs by making it effortless to find trusted, verified technicians. No more guesswork, no more unreliable handymen — just quality service at your fingertips.',
              ).animate().fadeIn(duration: 400.ms, delay: 100.ms),

              const SizedBox(height: 12),

              // Why Choose HOMERES
              _SectionCard(
                icon: Icons.verified_user_rounded,
                iconColor: AppColors.success,
                title: 'Why Choose HOMERES?',
                body: 'Every technician on our platform undergoes rigorous background checks and skill verification. We don\'t just connect you with anyone — we connect you with the best. Real ratings from real customers ensure transparency and trust.',
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

              const SizedBox(height: 12),

              // How It Works
              _SectionCard(
                icon: Icons.bolt_rounded,
                iconColor: AppColors.accent,
                title: 'How It Works',
                body: 'Browse services → Pick a verified pro → Schedule at your convenience → Track them in real-time → Rate your experience. It\'s that simple. Your satisfaction is guaranteed, or we\'ll make it right.',
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

              const SizedBox(height: 12),

              // Community Impact
              _SectionCard(
                icon: Icons.favorite_rounded,
                iconColor: AppColors.error,
                title: 'Community First',
                body: 'HOMERES isn\'t just an app — it\'s a community. We empower skilled local technicians with tools to grow their business while giving homeowners peace of mind. Together, we\'re building trust, one repair at a time.',
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

              const SizedBox(height: 20),

              // Contact Section
              _ContactCard(
                onEmail: () async {
                  final uri = Uri.parse('mailto:support@homeres.com');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
                onCall: () async {
                  final uri = Uri.parse('tel:+255123456789');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
                onWebsite: () async {
                  final uri = Uri.parse('https://homeres.com');
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

              const SizedBox(height: 20),

              // Copyright
              Center(
                child: Column(children: [
                  Text('© 2024 HOMERES. All rights reserved.', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                  const SizedBox(height: 4),
                  Text('Made with ❤️ in Tanzania', style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                ]),
              ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

              const SizedBox(height: 20),
            ]),
          ),
        ),
      ]),
    );
  }
}

// Version Card
class _VersionCard extends StatelessWidget {
  final String version;
  final String buildNumber;
  const _VersionCard({required this.version, required this.buildNumber});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.05), AppColors.primary.withOpacity(0.02)]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.info_outline, color: AppColors.primary, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('App Version', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text('Version $version (Build $buildNumber)', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        ])),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Text('Up to date', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600))),
      ]),
    );
  }
}

// Section Card
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  const _SectionCard({required this.icon, required this.iconColor, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.08))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: iconColor, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 6),
          Text(body, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5)),
        ])),
      ]),
    );
  }
}

// Contact Card
class _ContactCard extends StatelessWidget {
  final VoidCallback onEmail, onCall, onWebsite;
  const _ContactCard({required this.onEmail, required this.onCall, required this.onWebsite});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.withOpacity(0.08))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Get in Touch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 4),
        Text('We\'d love to hear from you!', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        const SizedBox(height: 16),
        _ContactTile(icon: Icons.email_rounded, label: 'support@homeres.com', onTap: onEmail),
        _ContactTile(icon: Icons.phone_rounded, label: '+255 123 456 789', onTap: onCall),
        _ContactTile(icon: Icons.language_rounded, label: 'www.homeres.com', onTap: onWebsite),
      ]),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ContactTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ]),
      ),
    );
  }
}