import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/domain/entities/user.dart';
import '../cubit/admin_cubit.dart';

class AdminQrScannerModal extends StatefulWidget {
  final AdminCubit adminCubit;
  final List<User> users;

  const AdminQrScannerModal({
    super.key,
    required this.adminCubit,
    required this.users,
  });

  static Future<void> show(
    BuildContext context, {
    required AdminCubit adminCubit,
    required List<User> users,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AdminQrScannerModal(adminCubit: adminCubit, users: users),
    );
  }

  @override
  State<AdminQrScannerModal> createState() => _AdminQrScannerModalState();
}

class _AdminQrScannerModalState extends State<AdminQrScannerModal> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  bool _isCameraReady = false;
  bool _isFlashOn = false;
  bool _isDecodingQr = false;
  String? _scanError;

  User? _matchedUser;
  final TextEditingController _qrInputCtrl = TextEditingController();
  final TextEditingController _gpCtrl = TextEditingController(text: '50');
  final TextEditingController _xpCtrl = TextEditingController(text: '100');
  final TextEditingController _noteCtrl = TextEditingController(
    text: 'Thưởng nộp rác phân loại tại Trạm Thu Gom SmartWaste',
  );
  int _selectedPresetIndex = 1; // Mặc định +50 GP

  static const List<Map<String, dynamic>> _rewardPresets = [
    {'label': '0.5 kg rác (+25 GP)', 'gp': 25, 'xp': 50},
    {'label': '1.0 kg rác (+50 GP)', 'gp': 50, 'xp': 100},
    {'label': '2.0 kg rác (+100 GP)', 'gp': 100, 'xp': 200},
    {'label': 'Rác điện tử/Pin (+150 GP)', 'gp': 150, 'xp': 300},
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera({int index = 0}) async {
    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameras.isEmpty) return;

      _cameraIndex = index.clamp(0, _cameras.length - 1);
      await _cameraController?.dispose();

      final controller = CameraController(
        _cameras[_cameraIndex],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _cameraController = controller;
      await controller.initialize();
      if (mounted) {
        setState(() {
          _isCameraReady = true;
          _isFlashOn = false;
        });
      }
    } catch (e) {
      debugPrint('Lỗi khởi tạo camera quét QR: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      _isFlashOn = !_isFlashOn;
      await _cameraController!.setFlashMode(
        _isFlashOn ? FlashMode.torch : FlashMode.off,
      );
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;
    await _initCamera(index: (_cameraIndex + 1) % _cameras.length);
  }

  Future<void> _captureAndDecodeQr() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isDecodingQr) {
      return;
    }
    try {
      setState(() {
        _isDecodingQr = true;
        _scanError = null;
      });
      final xfile = await _cameraController!.takePicture();
      await _decodeQrFromFile(File(xfile.path));
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDecodingQr = false;
          _scanError = 'Không thể chụp khung hình QR: $e';
        });
      }
    }
  }

  Future<void> _pickQrFromGallery() async {
    if (_isDecodingQr) return;
    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      if (xfile == null) return;
      setState(() {
        _isDecodingQr = true;
        _scanError = null;
      });
      await _decodeQrFromFile(File(xfile.path));
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDecodingQr = false;
          _scanError = 'Lỗi chọn ảnh QR: $e';
        });
      }
    }
  }

  Future<void> _decodeQrFromFile(File imageFile) async {
    try {
      final apiKey = (dotenv.env['GEMINI_API_KEY'] ?? '').trim();
      if (apiKey.isEmpty) {
        throw Exception('Chưa cấu hình GEMINI_API_KEY trong .env');
      }

      final bytes = await imageFile.readAsBytes();
      const prompt =
          'Hãy đọc mã QR trong hình ảnh này. Mã QR của ứng dụng có định dạng SMARTWASTE_USER:<uid> hoặc chuỗi ID người dùng. '
          'Chỉ trả về ĐÚNG chuỗi nội dung bên trong mã QR (ví dụ: SMARTWASTE_USER:abc123xyz), nếu không thấy mã QR hãy trả về NONE.';

      final content = [
        Content.multi([TextPart(prompt), DataPart('image/jpeg', bytes)]),
      ];

      String? decodedText;
      for (final modelName in ['gemini-3.5-flash-lite', 'gemini-2.5-flash']) {
        try {
          final model = GenerativeModel(model: modelName, apiKey: apiKey);
          final response = await model.generateContent(content);
          if (response.text != null && response.text!.trim().isNotEmpty) {
            decodedText = response.text!.trim();
            break;
          }
        } catch (_) {}
      }

      if (!mounted) return;

      if (decodedText == null ||
          decodedText.toUpperCase() == 'NONE' ||
          decodedText.isEmpty) {
        setState(() {
          _isDecodingQr = false;
          _scanError =
              'Không nhận diện được mã QR trong khung hình. Hãy đưa mã QR lại gần hoặc chọn cư dân bên dưới.';
        });
        return;
      }

      // Trích xuất chuỗi SMARTWASTE_USER:<uid> hoặc uid
      final cleaned =
          decodedText
              .replaceAll('`', '')
              .replaceAll('"', '')
              .replaceAll("'", '')
              .split('\n')
              .first
              .trim();

      _matchUserByQrOrId(cleaned);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDecodingQr = false;
          _scanError = 'Lỗi giải mã QR: $e';
        });
      }
    }
  }

  void _matchUserByQrOrId(String rawInput) {
    final cleanId =
        rawInput.startsWith('SMARTWASTE_USER:')
            ? rawInput.replaceFirst('SMARTWASTE_USER:', '').trim()
            : rawInput.trim();

    User? found;
    for (final u in widget.users) {
      if (u.id == cleanId || u.email.toLowerCase() == cleanId.toLowerCase()) {
        found = u;
        break;
      }
    }

    setState(() {
      _isDecodingQr = false;
      _qrInputCtrl.text =
          found != null ? 'SMARTWASTE_USER:${found.id}' : rawInput;
      _matchedUser = found;
      _scanError =
          found == null
              ? 'Đã đọc mã "$cleanId" nhưng không tìm thấy người dùng khớp trong hệ thống.'
              : null;
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _qrInputCtrl.dispose();
    _gpCtrl.dispose();
    _xpCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.92,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        child: Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: const Row(
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Color(0xFF1E293B),
                  size: 22,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Trạm Quét Mã QR Cộng Điểm',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
              ),
            ],
          ),
          body: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Khung Camera Quét QR Trực Tiếp (Bọc RepaintBoundary chống lag)
                RepaintBoundary(
                  child: Container(
                    height: 230,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (_isCameraReady &&
                            _cameraController != null &&
                            _cameraController!.value.isInitialized)
                          FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width:
                                  _cameraController!
                                      .value
                                      .previewSize
                                      ?.height ??
                                  1,
                              height:
                                  _cameraController!.value.previewSize?.width ??
                                  1,
                              child: CameraPreview(_cameraController!),
                            ),
                          )
                        else
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),

                        // Khung ngắm QR ở giữa
                        Center(
                          child: Container(
                            width: 155,
                            height: 155,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:
                                    _matchedUser != null
                                        ? const Color(0xFF4ADE80)
                                        : Colors.white,
                                width: 2.5,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),

                        // Nút điều khiển trên Camera (Flash, Đổi cam, Chọn ảnh QR)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Row(
                            children: [
                              _buildCamIconBtn(
                                icon:
                                    _isFlashOn
                                        ? Icons.flash_on_rounded
                                        : Icons.flash_off_rounded,
                                onTap: _toggleFlash,
                              ),
                              const SizedBox(width: 8),
                              _buildCamIconBtn(
                                icon: Icons.cameraswitch_rounded,
                                onTap: _switchCamera,
                              ),
                            ],
                          ),
                        ),

                        // Thanh nút bấm Quét QR hoặc Chọn ảnh từ Thư viện
                        Positioned(
                          bottom: 10,
                          left: 12,
                          right: 12,
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      _isDecodingQr
                                          ? null
                                          : _captureAndDecodeQr,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D32),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon:
                                      _isDecodingQr
                                          ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                          : const Icon(
                                            Icons.center_focus_strong_rounded,
                                            size: 18,
                                          ),
                                  label: Text(
                                    _isDecodingQr
                                        ? 'Đang đọc mã QR...'
                                        : 'Chụp & Đọc Mã QR',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed:
                                    _isDecodingQr ? null : _pickQrFromGallery,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(
                                    alpha: 0.9,
                                  ),
                                  foregroundColor: const Color(0xFF1E293B),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.photo_library_outlined,
                                  size: 18,
                                ),
                                label: const Text(
                                  'Ảnh QR',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_scanError != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFFDC2626),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _scanError!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // 2. Chọn nhanh cư dân (nếu không cần gõ tay)
                const Text(
                  'Hoặc chạm chọn nhanh cư dân tại trạm:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.users.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final u = widget.users[index];
                      final isSelected = _matchedUser?.id == u.id;
                      final name =
                          u.fullName.isNotEmpty
                              ? u.fullName
                              : (u.email.isNotEmpty ? u.email : u.id);
                      return ChoiceChip(
                        showCheckmark: false,
                        avatar: CircleAvatar(
                          backgroundColor:
                              isSelected
                                  ? Colors.white24
                                  : const Color(0xFFE2E8F0),
                          child: Text(
                            name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected
                                      ? Colors.white
                                      : const Color(0xFF1E293B),
                            ),
                          ),
                        ),
                        label: Text(
                          name,
                          style: TextStyle(
                            fontSize: 12,
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
                        onSelected: (_) {
                          setState(() {
                            _matchedUser = u;
                            _qrInputCtrl.text = 'SMARTWASTE_USER:${u.id}';
                            _scanError = null;
                          });
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // 3. Thẻ thông tin người dùng đã nhận diện từ QR
                if (_matchedUser != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: const Color(0xFFDCFCE7),
                          backgroundImage:
                              (_matchedUser!.avatar != null &&
                                      _matchedUser!.avatar!.isNotEmpty)
                                  ? CachedNetworkImageProvider(
                                    _matchedUser!.avatar!,
                                  )
                                  : null,
                          child:
                              (_matchedUser!.avatar == null ||
                                      _matchedUser!.avatar!.isEmpty)
                                  ? const Icon(
                                    Icons.person_rounded,
                                    color: Color(0xFF15803D),
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.verified_rounded,
                                    color: Color(0xFF16A34A),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      _matchedUser!.fullName.isNotEmpty
                                          ? _matchedUser!.fullName
                                          : _matchedUser!.email,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Hiện có: ${_matchedUser!.greenPoints} GP • ${_matchedUser!.totalXP} XP',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF15803D),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // 4. Chọn nhanh mức thưởng theo khối lượng rác nộp
                const Text(
                  'Chọn nhanh định mức thưởng rác nộp:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(_rewardPresets.length, (i) {
                    final preset = _rewardPresets[i];
                    final isSelected = _selectedPresetIndex == i;
                    return ChoiceChip(
                      showCheckmark: false,
                      label: Text(
                        preset['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              isSelected
                                  ? Colors.white
                                  : const Color(0xFF334155),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF2E7D32),
                      backgroundColor: const Color(0xFFF1F5F9),
                      side: BorderSide.none,
                      onSelected: (_) {
                        setState(() {
                          _selectedPresetIndex = i;
                          _gpCtrl.text = '${preset['gp']}';
                          _xpCtrl.text = '${preset['xp']}';
                        });
                      },
                    );
                  }),
                ),

                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _gpCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Điểm Xanh (+GP)',
                          prefixIcon: const Icon(Icons.eco_outlined, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _xpCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Kinh nghiệm (+XP)',
                          prefixIcon: const Icon(Icons.bolt_rounded, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nội dung thông báo gửi cư dân',
                    prefixIcon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _submitReward,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(
                    _matchedUser != null
                        ? 'Cộng Điểm Cho ${_matchedUser!.fullName.isNotEmpty ? _matchedUser!.fullName : "Cư Dân"}'
                        : 'Xác Nhận Cộng Điểm',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCamIconBtn({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  void _submitReward() {
    final targetId = _matchedUser?.id ?? _qrInputCtrl.text.trim();
    if (targetId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng quét mã QR bằng Camera hoặc chọn cư dân bên dưới!',
          ),
        ),
      );
      return;
    }

    final gp = (int.tryParse(_gpCtrl.text.trim()) ?? 50).abs();
    final xp = (int.tryParse(_xpCtrl.text.trim()) ?? 100).abs();

    Navigator.pop(context);
    widget.adminCubit.adjustUserPointsAndXp(
      userIdOrQr: targetId,
      greenPointsDelta: gp,
      xpDelta: xp,
      reason: _noteCtrl.text.trim(),
      notificationType: 'scan',
      incrementScanCount: true,
    );
  }
}
