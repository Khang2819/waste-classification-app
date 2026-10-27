// lib/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  static const _primaryGreen = Color(0xFF2E7D32);

  int _selectedPeriod = 0; // 0: Tuần, 1: Tháng, 2: Năm

  // Mock data tạm — thay bằng data thật sau
  final List<_RankEntry> _entries = const [
    _RankEntry(
      name: 'Nguyễn Văn A',
      points: 1240,
      correctRatio: 0.96,
      streak: 21,
    ),
    _RankEntry(
      name: 'Trần Thị B',
      points: 1185,
      correctRatio: 0.94,
      streak: 18,
    ),
    _RankEntry(
      name: 'Lê Hoàng C',
      points: 1102,
      correctRatio: 0.92,
      streak: 15,
    ),
    _RankEntry(name: 'Phạm D', points: 980, correctRatio: 0.90, streak: 12),
    _RankEntry(
      name: 'Bạn',
      points: 945,
      correctRatio: 0.89,
      streak: 10,
      isMe: true,
    ),
    _RankEntry(name: 'Võ E', points: 870, correctRatio: 0.86, streak: 8),
    _RankEntry(name: 'Đặng F', points: 820, correctRatio: 0.84, streak: 7),
  ];

  @override
  Widget build(BuildContext context) {
    final top3 = _entries.take(3).toList();
    final rest = _entries.skip(3).toList();
    final myIndex = _entries.indexWhere((e) => e.isMe);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
        ),
        title: const Text(
          'Bảng xếp hạng',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showRulesSheet,
            icon: const Icon(Icons.info_outline, color: Colors.black54),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const SizedBox(height: 8),
                _buildPodium(top3),
                const SizedBox(height: 20),
                const Text(
                  'Bảng xếp hạng',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Top ${_entries.length} cư dân tích cực',
                  style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < rest.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildRankRow(rank: i + 4, entry: rest[i]),
                  ),
              ],
            ),
          ),
          if (myIndex >= 0) _buildMyRankBar(myIndex + 1),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildPeriodSelector() {
    const labels = ['Tuần', 'Tháng', 'Năm'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedPeriod = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        _selectedPeriod == i
                            ? _primaryGreen
                            : const Color(0xFFF1F4F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color:
                          _selectedPeriod == i ? Colors.white : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildPodium(List<_RankEntry> top3) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 20, 12, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: _buildPodiumItem(top3[1], 2, 118)),
          Expanded(child: _buildPodiumItem(top3[0], 1, 150)),
          Expanded(child: _buildPodiumItem(top3[2], 3, 100)),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(_RankEntry entry, int rank, double height) {
    final medalColor = switch (rank) {
      1 => const Color(0xFFFFD54F),
      2 => const Color(0xFFE0E0E0),
      _ => const Color(0xFFD9A066),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (rank == 1)
          const Icon(
            Icons.workspace_premium,
            color: Color(0xFFFFD54F),
            size: 26,
          ),
        const SizedBox(height: 4),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: medalColor,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: rank == 1 ? 30 : 24,
                backgroundColor: Colors.white,
                child: Text(
                  _initials(entry.name),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: rank == 1 ? 18 : 15,
                    color: _primaryGreen,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -6,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: medalColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          entry.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${_formatPoints(entry.points)} điểm',
          style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11),
        ),
        const SizedBox(height: 10),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          alignment: Alignment.center,
          child: Text(
            '$rank',
            style: TextStyle(
              fontSize: rank == 1 ? 32 : 26,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildRankRow({required int rank, required _RankEntry entry}) {
    final isMe = entry.isMe;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFE8F5E9) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe ? const Color(0xFF66BB6A) : const Color(0xFFE6EAE7),
          width: isMe ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: rank <= 10 ? _primaryGreen : Colors.black45,
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE8F5E9),
            child: Text(
              _initials(entry.name),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _primaryGreen,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isMe ? FontWeight.bold : FontWeight.w600,
                          color: const Color(0xFF263238),
                        ),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Bạn',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Đúng ${(entry.correctRatio * 100).toStringAsFixed(0)}% • '
                  'Chuỗi ${entry.streak} ngày',
                  style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatPoints(entry.points),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen,
                ),
              ),
              const Text(
                'điểm xanh',
                style: TextStyle(fontSize: 10.5, color: Colors.black45),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _buildMyRankBar(int rank) {
    final me = _entries.firstWhere((e) => e.isMe);
    const labels = ['tuần này', 'tháng này', 'năm nay'];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _primaryGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '#$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vị trí của bạn ${labels[_selectedPeriod]}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF263238),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatPoints(me.points)} điểm xanh • '
                    'Đúng ${(me.correctRatio * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () {},
              style: TextButton.styleFrom(foregroundColor: _primaryGreen),
              icon: const Icon(Icons.trending_up, size: 16),
              label: const Text(
                'Tăng hạng',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  void _showRulesSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  'Cách tính điểm',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 12),
                for (final item in const [
                  ('+10 điểm', 'Phân loại đúng được xác nhận'),
                  ('+5 điểm', 'Duy trì chuỗi ngày liên tục'),
                  ('+20 điểm', 'Hoàn thành thử thách tuần'),
                  ('-5 điểm', 'Phân loại sai (có thể sửa trong 1 giờ)'),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.$1,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _primaryGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.$2,
                            style: const TextStyle(
                              fontSize: 13,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  // ---------------------------------------------------------------------------
  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  static String _formatPoints(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ---------------------------------------------------------------------------
// Model tạm
// ---------------------------------------------------------------------------
class _RankEntry {
  const _RankEntry({
    required this.name,
    required this.points,
    required this.correctRatio,
    required this.streak,
    this.isMe = false,
  });

  final String name;
  final int points;
  final double correctRatio;
  final int streak;
  final bool isMe;
}
