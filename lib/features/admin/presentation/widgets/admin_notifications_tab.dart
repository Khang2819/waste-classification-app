import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class AdminNotificationsTab extends StatefulWidget {
  const AdminNotificationsTab({super.key});

  @override
  State<AdminNotificationsTab> createState() => _AdminNotificationsTabState();
}

class _AdminNotificationsTabState extends State<AdminNotificationsTab> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String _selectedType = 'general'; // 'general' | 'reward' | 'scan' | 'map'
  bool _sendToAll = true;
  String? _selectedUserId;

  static const List<Map<String, dynamic>> _notifTypes = [
    {
      'value': 'general',
      'label': 'Hệ thống chung',
      'icon': Icons.campaign_outlined,
    },
    {
      'value': 'reward',
      'label': 'Quà tặng / Ưu đãi',
      'icon': Icons.card_giftcard_rounded,
    },
    {
      'value': 'scan',
      'label': 'Chiến dịch Phân loại',
      'icon': Icons.qr_code_scanner_rounded,
    },
    {
      'value': 'map',
      'label': 'Trạm thu gom mới',
      'icon': Icons.location_on_outlined,
    },
  ];

  static const List<Map<String, String>> _quickTemplates = [
    {
      'title': '🌱 Ngày Hội Đổi Rác Lấy Quà Xanh!',
      'body':
          'Mang nhựa tái chế & pin cũ tới các trạm thu gom SmartWaste cuối tuần này để nhận x2 GreenPoints!',
      'type': 'scan',
    },
    {
      'title': '🎁 Kho Voucher Mới Vừa Lên Kệ!',
      'body':
          'Hàng loạt voucher F&B và cây xanh để bàn vừa được bổ sung vào kho quà. Đổi điểm ngay!',
      'type': 'reward',
    },
    {
      'title': '📍 Đã Mở Thêm Điểm Thu Gom Rác Thông Minh',
      'body':
          'Kiểm tra bản đồ SmartWaste để khám phá điểm tập kết rác tái chế & rác nguy hại mới gần bạn.',
      'type': 'map',
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        return ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_outlined,
                        color: Color(0xFF475569),
                        size: 19,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Mẫu Thông Báo Nhanh',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children:
                          _quickTemplates.map((tpl) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ActionChip(
                                backgroundColor: const Color(0xFFF1F5F9),
                                side: BorderSide.none,
                                label: Text(
                                  tpl['title']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _titleController.text = tpl['title']!;
                                    _bodyController.text = tpl['body']!;
                                    _selectedType = tpl['type']!;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Soạn Thông Báo Gửi Người Dùng',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Loại thông báo:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _notifTypes.map((typeObj) {
                          final val = typeObj['value'] as String;
                          final isSelected = _selectedType == val;
                          return ChoiceChip(
                            showCheckmark: false,
                            avatar: Icon(
                              typeObj['icon'] as IconData,
                              size: 16,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : const Color(0xFF475569),
                            ),
                            label: Text(
                              typeObj['label'] as String,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : const Color(0xFF334155),
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: const Color(0xFF1E293B),
                            backgroundColor: const Color(0xFFF1F5F9),
                            side: BorderSide.none,
                            onSelected:
                                (_) => setState(() => _selectedType = val),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Đối tượng nhận:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: const Color(0xFF2E7D32),
                          title: Text(
                            'Tất cả (${state.users.length})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: true,
                          groupValue: _sendToAll,
                          onChanged:
                              (v) => setState(() => _sendToAll = v ?? true),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          activeColor: const Color(0xFF2E7D32),
                          title: const Text(
                            '1 Người dùng',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          value: false,
                          groupValue: _sendToAll,
                          onChanged:
                              (v) => setState(() => _sendToAll = v ?? false),
                        ),
                      ),
                    ],
                  ),
                  if (!_sendToAll) ...[
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedUserId,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: 'Chọn người dùng nhận thông báo',
                        prefixIcon: const Icon(Icons.person_pin_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items:
                          state.users.map((u) {
                            final label =
                                u.fullName.isNotEmpty
                                    ? '${u.fullName} (${u.email})'
                                    : (u.email.isNotEmpty ? u.email : u.id);
                            return DropdownMenuItem<String>(
                              value: u.id,
                              child: Text(
                                label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (val) => setState(() => _selectedUserId = val),
                    ),
                  ],
                  const SizedBox(height: 14),
                  TextField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Tiêu đề thông báo *',
                      hintText: 'Nhập tiêu đề ngắn gọn...',
                      prefixIcon: const Icon(Icons.title_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bodyController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Nội dung chi tiết *',
                      hintText: 'Nhập nội dung thông báo gửi đến người dùng...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed:
                          state.isSubmitting
                              ? null
                              : () => _handleSendNotification(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E293B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon:
                          state.isSubmitting
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.send_rounded, size: 18),
                      label: Text(
                        _sendToAll
                            ? 'Phát Thông Báo Toàn Hệ Thống'
                            : 'Gửi Thông Báo Tới Người Dùng Này',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleSendNotification(BuildContext context) {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ tiêu đề và nội dung thông báo!'),
        ),
      );
      return;
    }

    if (!_sendToAll && (_selectedUserId == null || _selectedUserId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn người dùng nhận thông báo!'),
        ),
      );
      return;
    }

    context.read<AdminCubit>().sendSystemNotification(
      title: title,
      body: body,
      type: _selectedType,
      targetUserId: _sendToAll ? null : _selectedUserId,
    );

    _titleController.clear();
    _bodyController.clear();
  }
}
