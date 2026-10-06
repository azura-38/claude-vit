import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import 'package:vitacase/core/extensions/l10n_extension.dart';
import '../../../../shared/domain/entities/doctor.dart';
import '../../../../shared/providers/doctor_providers.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_routes.dart';

class DoctorsScreen extends ConsumerStatefulWidget {
  const DoctorsScreen({super.key});

  @override
  ConsumerState<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends ConsumerState<DoctorsScreen> {
  String _searchTerm = '';
  String? _selectedCategory;



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final docsAsync = ref.watch(doctorListProvider);
    _selectedCategory ??= context.l10n.all;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context, isDark),
      body: Column(
        children: [
          _buildSearchAndFilter(context, isDark),
          Expanded(
            child: docsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('${context.l10n.error}: $e')),
              data: (contacts) {
                final departments = <String>[
                  context.l10n.all,
                  ...contacts.map((d) => d.department.toString()).toSet(),
                ];
                final filtered = contacts.where((d) {
                  final query = _searchTerm.toLowerCase();
                  final matchesSearch = d.name.toLowerCase().contains(query) ||
                      d.department.toLowerCase().contains(query) ||
                      d.hospital.toLowerCase().contains(query);
                  final matchesCategory = _selectedCategory == context.l10n.all || d.department == _selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                return Column(
                  children: [
                    _buildCategoryChips(departments, isDark),
                    Expanded(
                      child: filtered.isEmpty
                          ? _buildEmptyState(context, isDark)
                          : ListView.builder(
                              padding: const EdgeInsets.all(24).copyWith(bottom: 100),
                              itemCount: filtered.length,
                              itemBuilder: (ctx, idx) => _ContactCard(contact: filtered[idx], index: idx),
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContact(context),
        backgroundColor: const Color(0xFF005DA7),
        elevation: 10,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ).animate().scale(delay: 400.ms),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      title: Text(
        context.l10n.contactsTitle,
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          color: Color(0xFF005DA7),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.blueGrey),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchTerm = v),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          decoration: InputDecoration(
            hintText: context.l10n.contactsSearchHint,
            hintStyle: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w400),
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.blueGrey, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildCategoryChips(List<String> categories, bool isDark) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: 300.ms,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF005DA7) : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cat,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Colors.blueGrey),
                ),
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.contact_phone_outlined, size: 64, color: Colors.blueGrey.withValues(alpha: 0.2)),
          const SizedBox(height: 16),
          Text(
            context.l10n.noContactsFound,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blueGrey),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => setState(() {
              _searchTerm = '';
              _selectedCategory = context.l10n.all;
            }),
            child: Text(context.l10n.clearFilters),
          ),
        ],
      ),
    );
  }

  void _showAddContact(BuildContext context) {
    context.push(AppRoutes.doctorAdd).then((_) => ref.read(doctorListProvider.notifier).refresh());
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.contact, required this.index});

  final Doctor contact;
  final int index;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.02)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              context.goNamed('doctorDetail', pathParameters: {'id': contact.id});
            },
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.medicalBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(Icons.contact_phone_rounded, color: AppColors.medicalBlue, size: 32),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                contact.name,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (contact.isVerified)
                              const Icon(Icons.verified_rounded, color: Color(0xFF14B8A6), size: 16),
                            const SizedBox(width: 8),
                            Consumer(
                              builder: (context, ref, _) => PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textTertiary),
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    context.push(AppRoutes.doctorAdd, extra: contact).then((_) => ref.read(doctorListProvider.notifier).refresh());
                                  } else if (val == 'delete') {
                                    ref.read(doctorListProvider.notifier).deleteDoctor(contact.id);
                                  }
                                },
                                itemBuilder: (ctx) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text(context.l10n.edit),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(context.l10n.delete, style: const TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          contact.department,
                          style: const TextStyle(fontSize: 13, color: AppColors.medicalBlue, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.business_rounded, size: 14, color: Colors.blueGrey),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                contact.hospital,
                                style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.2);
  }
}
