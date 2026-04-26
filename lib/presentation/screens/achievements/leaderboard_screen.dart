import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/repositories/leaderboard_repository_impl.dart';
import '../../../domain/entities/leaderboard_user.dart';
import '../../../core/utils/uid_manager.dart';
import '../../../core/config/app_config.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  List<LeaderboardUser> _topUsers = [];
  String? _myUid;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (AppConfig.isLeaderboardEnabled) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final repo = ref.read(leaderboardRepositoryProvider);
    final uid = await UIDManager.getUID();
    final top = await repo.getTopUsers();
    
    if (mounted) {
      setState(() {
        _myUid = uid;
        _topUsers = top;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!AppConfig.isLeaderboardEnabled) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.leaderboard_rounded, size: 64, color: AppColors.medicalBlue.withValues(alpha: 0.2)),
              const SizedBox(height: 24),
              const Text(
                "Ranking Temporarily Hidden",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              const Text(
                "We are upgrading the leaderboard system to provide a better experience. Check back soon!",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _topUsers.length,
        itemBuilder: (context, index) {
          final user = _topUsers[index];
          final isMe = user.uid == _myUid;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isMe ? AppColors.medicalBlue.withValues(alpha: 0.1) : (isDark ? AppColors.surfaceDark : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: isMe ? Border.all(color: AppColors.medicalBlue, width: 2) : null,
            ),
            child: Row(
              children: [
                _buildRankIcon(index + 1),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMe ? "YOU" : user.displayName,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: isMe ? AppColors.medicalBlue : (isDark ? Colors.white : AppColors.textPrimary),
                        ),
                      ),
                      Text(
                        "Vita Scout",
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${user.xp} XP",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRankIcon(int rank) {
    if (rank == 1) return const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 28);
    if (rank == 2) return const Icon(Icons.emoji_events_rounded, color: Color(0xFFC0C0C0), size: 24);
    if (rank == 3) return const Icon(Icons.emoji_events_rounded, color: Color(0xFFCD7F32), size: 22);
    
    return SizedBox(
      width: 28,
      child: Center(
        child: Text(
          "$rank",
          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.grey),
        ),
      ),
    );
  }
}
