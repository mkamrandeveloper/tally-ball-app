import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class TallyHistoryScreen extends StatefulWidget {
  const TallyHistoryScreen({super.key});

  @override
  State<TallyHistoryScreen> createState() => _TallyHistoryScreenState();
}

class _TallyHistoryScreenState extends State<TallyHistoryScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        title: const Text('HISTORY'),
        titleTextStyle: TallyTextStyles.heading2(context).copyWith(color: context.colors.precisionBlue),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: user == null
          ? const Center(child: Text('Please log in to view history'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _dbService.getGameSessionsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: context.colors.precisionBlue));
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 64, color: context.colors.textTertiary),
                        const SizedBox(height: 16),
                        Text('No matches found yet', style: TallyTextStyles.bodyLarge(context)),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: docs.length + 1, // +1 for the header
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text('RECENT MATCHES', style: TallyTextStyles.label(context).copyWith(letterSpacing: 2)),
                      );
                    }
                    
                    final data = docs[index - 1].data();
                    final timestamp = data['timestamp'] as Timestamp?;
                    final dateStr = timestamp != null 
                        ? DateFormat('MMM dd, yyyy - HH:mm').format(timestamp.toDate())
                        : 'Unknown Date';
                    
                    final String mode = data['mode'] ?? 'practice';
                    final int score = data['score'] ?? 0;
                    final bool isMatch = mode == 'match' || mode == 'versus';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildHistoryCard(
                        context: context,
                        title: mode.toUpperCase(),
                        date: dateStr.toUpperCase(),
                        score: score.toString(),
                        isMatch: isMatch,
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildHistoryCard({
    required BuildContext context,
    required String title,
    required String date,
    required String score,
    bool isMatch = false,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TallyTextStyles.heading3(context)),
              const SizedBox(height: 4),
              Text(date, style: TallyTextStyles.bodySmall(context)),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score,
                style: TallyTextStyles.heading3(context).copyWith(
                  color: isMatch ? context.colors.optimisticYellow : context.colors.precisionBlue,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'PTS',
                style: TallyTextStyles.label(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

