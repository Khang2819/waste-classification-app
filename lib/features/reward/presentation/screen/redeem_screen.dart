import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_text_field.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../profile/presentation/cubit/profile_state.dart';
import '../../domain/entities/reward_entity.dart';
import '../cubit/reward_cubit.dart';

class RedeemScreen extends StatefulWidget {
  const RedeemScreen({super.key});

  @override
  State<RedeemScreen> createState() => _RedeemScreenState();
}

class _RedeemScreenState extends State<RedeemScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  String _searchQuery = '';
  final List<String> _categories = [
    'Tất cả',
    'Voucher F&B',
    'Quà Tặng Xanh',
    'Thẻ Nạp',
    'Trồng Cây',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RewardCubit>().getReward();
    });
  }

  // Lọc danh sách quà theo từ khóa tìm kiếm và danh mục
  List<RewardEntity> _filterRewards(List<RewardEntity> rewards) {
    final query = _searchQuery.trim().toLowerCase();

    return rewards.where((reward) {
      // 1. Kiểm tra từ khóa tìm kiếm (theo tên hoặc tiêu đề)
      final matchQuery =
          query.isEmpty ||
          reward.title.toLowerCase().contains(query) ||
          reward.name.toLowerCase().contains(query);

      // 2. Kiểm tra danh mục lọc
      final matchCategory =
          _selectedCategory == 'Tất cả' ||
          reward.name.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
          reward.title.toLowerCase().contains(_selectedCategory.toLowerCase());

      return matchQuery && matchCategory;
    }).toList();
  }

  // Widget thanh tìm kiếm: gọn gàng, dễ hiểu
  Widget _buildSearchBar() {
    return CustomTextField(
      controller: _searchController,
      hintText: 'Tìm kiếm voucher, quà tặng...',
      prefixIcon: Icons.search_rounded,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      suffixIcon:
          _searchQuery.isNotEmpty
              ? IconButton(
                icon: const Icon(Icons.clear_rounded, size: 18),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
              : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF66BB6A),
        elevation: 0,
        title: const Text(
          "Đổi Quà Tặng Xanh",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            context.go('/main');
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Stack(
              children: [
                const Icon(
                  Icons.confirmation_number_outlined,
                  size: 26,
                  color: Colors.white,
                ),
                Positioned(
                  top: -2,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '9',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            BlocBuilder<ProfileCubit, ProfileState>(
              builder: (context, state) {
                final points =
                    state is ProfileLoaded ? state.user.greenPoints : 0;

                return Container(
                  padding: EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF66BB6A),
                        Color(0xFF81C784),
                        Color(0xFFA5D6A7),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.white.withValues(alpha: 0.12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  'Điểm khả dụng của bạn',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '$points',
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.eco_rounded,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Điểm Xanh',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF9800),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.confirmation_number_rounded,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Tủ quà",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(color: Colors.white24, height: 1),
                        const SizedBox(height: 10),
                        const Text(
                          'Tích thêm 250 điểm để đạt hạng VIP Gold và nhận voucher 100k!',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      separatorBuilder:
                          (context, index) => const SizedBox(width: 8),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final items = _categories[index];
                        final isSelected = items == _selectedCategory;
                        return FilterChip(
                          label: Text(items),
                          selected: isSelected,
                          labelStyle: TextStyle(
                            color:
                                isSelected
                                    ? Colors.white
                                    : const Color(0xFF2E7D32),
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w600,
                            fontSize: 12.5,
                          ),
                          backgroundColor: Colors.white,
                          selectedColor: const Color(0xFF2E7D32),
                          checkmarkColor: Colors.white,
                          side: BorderSide(
                            color:
                                isSelected
                                    ? const Color(0xFF2E7D32)
                                    : const Color(0xFFC8E6C9),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = items;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.card_giftcard_outlined,
                            color: Color(0xFF2E7D32),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Danh sách quà tặng',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.help_outline_rounded,
                          size: 16,
                          color: Color(0xFF2E7D32),
                        ),
                        label: const Text(
                          'Thể lệ',
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<RewardCubit, RewardState>(
                    builder: (context, state) {
                      if (state is RewardLoading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        );
                      }
                      if (state is RewardError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text(state.error)),
                        );
                      }

                      if (state is RewardLoaded) {
                        final filteredRewards = _filterRewards(state.rewards);

                        if (filteredRewards.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Không tìm thấy quà tặng phù hợp',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredRewards.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 0.72,
                              ),
                          itemBuilder: (context, index) {
                            final reward = filteredRewards[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            reward.name,
                                            style: TextStyle(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            reward.title,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1B5E20),
                                              height: 1.25,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.eco_rounded,
                                                    color: Color(0xFF2E7D32),
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    '${reward.points}',
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      color: Color(0xFF2E7D32),
                                                    ),
                                                  ),
                                                  const Text(
                                                    ' đ',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Color(0xFF2E7D32),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                'Còn ${reward.stock}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.grey.shade500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 32,
                                            child: ElevatedButton(
                                              onPressed: () {},
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF2E7D32,
                                                ),
                                                disabledBackgroundColor:
                                                    Colors.grey.shade300,
                                                foregroundColor: Colors.white,
                                                disabledForegroundColor:
                                                    Colors.grey.shade600,
                                                elevation: 0,
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: Text(
                                                'Đổi ngay',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
