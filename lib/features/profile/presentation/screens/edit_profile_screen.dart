import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/profile_provider.dart';
import '../widgets/bmi_summary_card.dart';
import '../widgets/collapsible_profile_section.dart';
import '../widgets/floating_input_field.dart';
import '../widgets/gender_selector.dart';
import '../widgets/health_condition_chips.dart';
import '../widgets/privacy_toggle_tile.dart';
import '../widgets/save_profile_button.dart';
import '../widgets/security_info_card.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  int expanded = 0;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 140),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const Expanded(
                      child: Text(
                        'Your Health Profile',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const CircleAvatar(radius: 22),
                  ],
                ),

                const SizedBox(height: 28),

                BmiSummaryCard(
                  bmi: profile.bmi,
                  status: profile.bmiStatus,
                ).animate().fadeIn().slideY(begin: .2),

                const SizedBox(height: 24),

                LinearProgressIndicator(
                  value: profile.completion,
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(999),
                ),

                const SizedBox(height: 8),

                Text('${(profile.completion * 100).toInt()}% Completed'),

                const SizedBox(height: 28),

                CollapsibleProfileSection(
                  title: 'Metrics',
                  expanded: expanded == 0,
                  onTap: () {
                    setState(() {
                      expanded = 0;
                    });
                  },
                  child: Column(
                    children: [
                      FloatingInputField(
                        label: 'Height',
                        hint: '170',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          notifier.updateHeight(double.tryParse(value) ?? 170);
                        },
                      ),
                      const SizedBox(height: 14),
                      FloatingInputField(
                        label: 'Weight',
                        hint: '65',
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          notifier.updateWeight(double.tryParse(value) ?? 65);
                        },
                      ),
                    ],
                  ),
                ),

                CollapsibleProfileSection(
                  title: 'Personal',
                  expanded: expanded == 1,
                  onTap: () {
                    setState(() {
                      expanded = 1;
                    });
                  },
                  child: Column(
                    children: [
                      FloatingInputField(
                        label: 'Full Name',
                        hint: 'Sarah Jenkins',
                        onChanged: notifier.updateName,
                      ),
                      const SizedBox(height: 14),
                      GenderSelector(
                        selected: profile.gender,
                        onChanged: notifier.updateGender,
                      ),
                    ],
                  ),
                ),

                CollapsibleProfileSection(
                  title: 'Contact',
                  expanded: expanded == 2,
                  onTap: () {
                    setState(() {
                      expanded = 2;
                    });
                  },
                  child: Column(
                    children: [
                      FloatingInputField(
                        label: 'Email',
                        hint: 'example@email.com',
                        keyboardType: TextInputType.emailAddress,
                        onChanged: notifier.updateEmail,
                      ),
                      const SizedBox(height: 14),
                      FloatingInputField(
                        label: 'Phone',
                        hint: '+1 555 000',
                        keyboardType: TextInputType.phone,
                        onChanged: notifier.updatePhone,
                      ),
                    ],
                  ),
                ),

                CollapsibleProfileSection(
                  title: 'Health Conditions',
                  expanded: expanded == 3,
                  onTap: () {
                    setState(() {
                      expanded = 3;
                    });
                  },
                  child: HealthConditionChips(
                    selected: profile.conditions,
                    onTap: notifier.toggleCondition,
                  ),
                ),

                CollapsibleProfileSection(
                  title: 'Privacy',
                  expanded: expanded == 4,
                  onTap: () {
                    setState(() {
                      expanded = 4;
                    });
                  },
                  child: Column(
                    children: [
                      PrivacyToggleTile(
                        title: 'Hide sensitive notifications',
                        value: profile.privacyMode,
                        onChanged: notifier.togglePrivacy,
                      ),
                      PrivacyToggleTile(
                        title: 'Biometric profile lock',
                        value: profile.biometricLock,
                        onChanged: notifier.toggleBiometric,
                      ),
                      PrivacyToggleTile(
                        title: 'Silent notification mode',
                        value: profile.silentNotifications,
                        onChanged: notifier.toggleSilent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                const SecurityInfoCard(),
              ],
            ),

            Positioned(
              left: 20,
              right: 20,
              bottom: 28,
              child: SafeArea(
                child: SaveProfileButton(
                  onTap: () async {
                    await ref.read(profileProvider.notifier).saveToDatabase();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(context.l10n.profileUpdated)),
                      );
                      context.pop();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
