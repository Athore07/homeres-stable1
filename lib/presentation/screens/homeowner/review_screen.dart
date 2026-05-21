// lib/presentation/screens/homeowner/review_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/extensions/context_extensions.dart';
import '../../providers/auth/auth_provider.dart';
import '../../providers/homeowner/review_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_textfield.dart';
import '../../widgets/technician/rating_stars.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reviewProvider);
    final notifier = ref.read(reviewProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      if (extra != null) notifier.init(extra);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Rate Service', style: TextStyle(fontWeight: FontWeight.bold))),
      body: state.isSuccess
          ? _SuccessView(onDone: () => context.pop())
          : SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(children: [
              _TechnicianInfo(name: state.technicianName, service: state.serviceName),
              const SizedBox(height: 32),
              _RatingSection(rating: state.rating, onChanged: notifier.setRating),
              const SizedBox(height: 32),
              _FeedbackTags(options: notifier.feedbackOptions, selected: state.feedback, onToggle: notifier.toggleFeedback),
              const SizedBox(height: 32),
              _RecommendSection(recommend: state.wouldRecommend, onChanged: notifier.setRecommend),
              const SizedBox(height: 32),
              _CommentField(comment: state.comment, onChanged: notifier.setComment),
              const SizedBox(height: 32),
              _QualityRatings(labels: notifier.qualityLabels, ratings: state.qualityRatings, onChanged: notifier.setQualityRating),
              const SizedBox(height: 32),
              CustomButton(
                label: 'Submit Review',
                onPressed: state.rating > 0 && !state.isSubmitting ? () => _submit(context, ref, notifier) : null,
                isLoading: state.isSubmitting,
              ),
              if (state.error != null) ...[const SizedBox(height: 16), _ErrorBanner(message: state.error!)],
              const SizedBox(height: 32),
            ])),
    );
  }

  void _submit(BuildContext context, WidgetRef ref, ReviewNotifier notifier) async {
    final user = ref.read(authProvider).user;
    if (user == null) { context.showSnackBar('Please login'); return; }
    final ok = await notifier.submit(user.id, user.name);
    if (ok && context.mounted) context.showSnackBar('Review submitted!');
  }
}

// Technician Info
class _TechnicianInfo extends StatelessWidget {
  final String name, service;
  const _TechnicianInfo({required this.name, required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20)),
      child: Row(children: [
        CircleAvatar(radius: 35, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(service, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600))),
          const SizedBox(height: 8),
          Row(children: [const Icon(Icons.verified, color: AppColors.success, size: 16), const SizedBox(width: 4), Text('Verified Technician', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.success, fontWeight: FontWeight.w600))]),
        ])),
      ]),
    ).animate().fadeIn(duration: 400.ms);
  }
}

// Rating Section
class _RatingSection extends StatelessWidget {
  final double rating;
  final ValueChanged<double> onChanged;
  const _RatingSection({required this.rating, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final labels = ['Poor', 'Fair', 'Good', 'Great', 'Excellent'];
    return Column(children: [
      Text('How was your experience?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 20),
      RatingStars(rating: rating, size: 56, interactive: true, onRatingChanged: onChanged),
      const SizedBox(height: 12),
      Text(rating > 0 ? labels[(rating - 1).toInt()] : 'Tap to rate', style: TextStyle(color: rating > 0 ? AppColors.primary : AppColors.textHint, fontWeight: FontWeight.bold)),
    ]).animate().fadeIn(duration: 400.ms);
  }
}

// Feedback Tags
class _FeedbackTags extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  const _FeedbackTags({required this.options, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('What stood out?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: options.map((o) {
        final isSelected = selected.contains(o);
        return GestureDetector(
          onTap: () => onToggle(o),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.withOpacity(0.2)),
            ),
            child: Text(o, style: TextStyle(color: isSelected ? Colors.white : null, fontWeight: FontWeight.w600)),
          ),
        );
      }).toList()),
    ]).animate().fadeIn(duration: 400.ms);
  }
}

// Recommend Section
class _RecommendSection extends StatelessWidget {
  final bool recommend;
  final ValueChanged<bool> onChanged;
  const _RecommendSection({required this.recommend, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Would you recommend?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _RecOption(value: true, label: 'Yes', icon: Icons.thumb_up, color: AppColors.success, selected: recommend, onTap: () => onChanged(true)),
        const SizedBox(width: 16),
        _RecOption(value: false, label: 'No', icon: Icons.thumb_down, color: AppColors.error, selected: !recommend, onTap: () => onChanged(false)),
      ]),
    ]).animate().fadeIn(duration: 400.ms);
  }
}

class _RecOption extends StatelessWidget {
  final bool value, selected;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _RecOption({required this.value, required this.label, required this.icon, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(color: selected ? color : Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: selected ? color : Colors.grey.withOpacity(0.2), width: selected ? 2 : 1)),
        child: Column(children: [Icon(icon, size: 32, color: selected ? Colors.white : null), const SizedBox(height: 8), Text(label, style: TextStyle(color: selected ? Colors.white : null, fontWeight: FontWeight.bold))]),
      ),
    );
  }
}

// Comment Field
class _CommentField extends StatelessWidget {
  final String comment;
  final ValueChanged<String> onChanged;
  const _CommentField({required this.comment, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Share your experience', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      CustomTextField(controller: TextEditingController(text: comment), label: 'Your Review', hint: 'Tell others about your experience...', maxLines: 4, prefixIcon: Icons.edit_note, onChanged: onChanged),
    ]).animate().fadeIn(duration: 400.ms);
  }
}

// Quality Ratings
class _QualityRatings extends StatelessWidget {
  final List<String> labels;
  final Map<String, double> ratings;
  final Function(String, double) onChanged;
  const _QualityRatings({required this.labels, required this.ratings, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Rate specific aspects', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 12),
      ...labels.map((l) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          Expanded(child: Text(l, style: const TextStyle(fontSize: 13))),
          Row(children: List.generate(5, (i) => GestureDetector(onTap: () => onChanged(l, i + 1.0), child: Icon(i < (ratings[l] ?? 0) ? Icons.star : Icons.star_border, color: i < (ratings[l] ?? 0) ? Colors.amber : Colors.grey[300], size: 22)))),
        ]),
      )),
    ]).animate().fadeIn(duration: 400.ms);
  }
}

// Success View
class _SuccessView extends StatelessWidget {
  final VoidCallback onDone;
  const _SuccessView({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.check_circle, color: AppColors.success, size: 80),
      const SizedBox(height: 24),
      Text('Review Submitted!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const Text('Thank you for your feedback'),
      const SizedBox(height: 32),
      CustomButton(label: 'Done', onPressed: onDone),
    ]));
  }
}

// Error Banner
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.error_outline, color: AppColors.error, size: 18), const SizedBox(width: 8), Expanded(child: Text(message, style: const TextStyle(color: AppColors.error, fontSize: 12)))]));
  }
}