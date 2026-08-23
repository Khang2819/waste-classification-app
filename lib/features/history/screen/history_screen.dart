import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedCategoryTab = 0;
  int _selectedTimeFilter = 0;
  @override
  Widget build(BuildContext context) {
    final categories = [
      {'title': 'Tất cả', 'icon': Icons.grid_view_rounded},
      {'title': 'Quét AI', 'icon': Icons.center_focus_strong_rounded},
      {'title': 'Giao nộp trạm', 'icon': Icons.local_shipping_rounded},
      {'title': 'Tích & Đổi điểm', 'icon': Icons.card_giftcard_rounded},
    ];
    final times = ['Tất cả thời gian', 'Hôm nay', '7 ngày qua', '30 ngày qua'];
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F5),
        elevation: 0,
        title: const Text(
          "Nhật ký phân loại 🌿",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B5E20),
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1B5E20),
                  Color(0xFF2E7D32),
                  Color(0xFF388E3C),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Thành Tích Phân Loại Xanh",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.recycling_rounded,
                            color: const Color(0xFFC8E6C9),
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "6 lượt",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "đã phân loại racs",
                            style: const TextStyle(
                              color: Color(0xFFE8F5E9),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 35, color: Colors.white24),
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.recycling_rounded,
                            color: const Color(0xFFC8E6C9),
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "6 lượt",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "đã phân loại racs",
                            style: const TextStyle(
                              color: Color(0xFFE8F5E9),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 35, color: Colors.white24),
                    Expanded(
                      child: Column(
                        children: [
                          Icon(
                            Icons.recycling_rounded,
                            color: const Color(0xFFC8E6C9),
                            size: 22,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "6 lượt",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "đã phân loại racs",
                            style: const TextStyle(
                              color: Color(0xFFE8F5E9),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 40,
            child: ListView.builder(
              itemCount: categories.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryTab == index;
                final item = categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    showCheckmark: false,
                    avatar: Icon(
                      item['icon'] as IconData,
                      size: 16,
                      color:
                          isSelected ? Colors.white : const Color(0xFF2E7D32),
                    ),
                    label: Text(
                      item['title'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF2E7D32),
                    backgroundColor: Colors.white,
                    elevation: isSelected ? 2 : 0,
                    side: BorderSide(
                      color:
                          isSelected
                              ? const Color(0xFF2E7D32)
                              : Colors.grey.shade300,
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedCategoryTab = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: Colors.grey,
                size: 15,
              ),
              const SizedBox(height: 4, width: 4),
              const Text(
                "Thời gian:",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(times.length, (index) {
                      final isSelected = _selectedTimeFilter == index;
                      return InkWell(
                        onTap:
                            () => setState(() => _selectedTimeFilter = index),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? const Color(0xFFE8F5E9)
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? const Color(0xFF2E7D32)
                                      : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            times[index],
                            style: TextStyle(
                              fontSize: 11,
                              color:
                                  isSelected ? Color(0xFF1B5E20) : Colors.grey,
                              fontWeight:
                                  isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.center_focus_strong_rounded,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Chai nhựa PET 500ml (x4)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF1B5E20).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Rác tái chế",
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Quét tự động qua AI Camera",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: const [
                          Icon(Icons.access_time, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            "20:45",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.scale, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            "0.18 kg",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "+ 40 điểm",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF1B5E20).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 6, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 10),
                          Text(
                            "Hoàn thành",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.center_focus_strong_rounded,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Chai nhựa PET 500ml (x4)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF1B5E20).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Rác tái chế",
                              style: TextStyle(
                                color: Color(0xFF1B5E20),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Quét tự động qua AI Camera",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: const [
                          Icon(Icons.access_time, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            "20:45",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.scale, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            "0.18 kg",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "+ 40 điểm",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF1B5E20).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 6, color: Color(0xFF2E7D32)),
                          const SizedBox(width: 10),
                          Text(
                            "Hoàn thành",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
