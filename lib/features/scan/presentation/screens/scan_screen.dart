import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/scan_cubit.dart';
import '../cubit/scan_state.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;
  bool _isCameraInitializing = false;
  bool _isVisible = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
      if (isCurrent) {
        _isVisible = true;
        _initCameraSafely();
      }
    });
  }

  Future<void> _initCameraSafely({int cameraIndex = 0}) async {
    if (_isCameraInitializing || !_isVisible) return;
    _isCameraInitializing = true;

    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameras.isEmpty)
        throw Exception('Không tìm thấy camera trên thiết bị');

      _selectedCameraIndex = cameraIndex.clamp(0, _cameras.length - 1);
      final camera = _cameras[_selectedCameraIndex];

      // Hủy camera cũ trước khi khởi tạo camera mới
      await _cameraController?.dispose();

      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _cameraController = controller;
      await controller.initialize();
      try {
        await controller.setFocusMode(FocusMode.auto);
      } catch (_) {}

      _isFlashOn = false;
      if (mounted) setState(() {});
    } catch (e, st) {
      debugPrint('Lỗi init camera: $e\n$st');
    } finally {
      _isCameraInitializing = false;
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
    } catch (e) {
      debugPrint('Lỗi bật/tắt đèn flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _isCameraInitializing) return;
    final nextIndex = (_selectedCameraIndex + 1) % _cameras.length;
    await _initCameraSafely(cameraIndex: nextIndex);
  }

  Future<void> _disposeCamera() async {
    try {
      await _cameraController?.dispose();
    } catch (e) {
      debugPrint('Lỗi dispose camera: $e');
    } finally {
      _cameraController = null;
      if (mounted) setState(() {});
    }
  }

  Future<void> takePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final file = await _cameraController!.takePicture();
      debugPrint("Ảnh chụp: ${file.path}");
      if (mounted) {
        context.read<ScanCubit>().scanImage(file.path);
      }
    } catch (e) {
      debugPrint('Lỗi chụp ảnh: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể chụp ảnh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      if (_isVisible) _initCameraSafely(cameraIndex: _selectedCameraIndex);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScanCubit, ScanState>(
      listener: (context, state) {
        if (state is ScanSuccess) {
          // Điều hướng sang màn hình kết quả và chuyển dữ liệu ScanEntities
          context.push('/result', extra: state.result).then((_) {
            // Khi quay trở lại màn hình quét, reset trạng thái Cubit
            if (context.mounted) {
              context.read<ScanCubit>().reset();
            }
          });
        } else if (state is ScanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ScanLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7F5),
          appBar: AppBar(
            title: const Text(
              "Phân loại rác thải",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            backgroundColor: const Color(0xFFF4F7F5),
            elevation: 0,
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.black,
                      ),
                      child:
                          _cameraController != null &&
                                  _cameraController!.value.isInitialized
                              ? Stack(
                                fit: StackFit.expand,
                                alignment: Alignment.center,
                                children: [
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
                                          _cameraController!
                                              .value
                                              .previewSize
                                              ?.width ??
                                          1,
                                      child: CameraPreview(_cameraController!),
                                    ),
                                  ),
                                  // Khung ngắm quét mục tiêu
                                  Center(
                                    child: Container(
                                      width: 240,
                                      height: 240,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                  ),
                                  // Hướng dẫn nhỏ trên camera
                                  Positioned(
                                    bottom: 20,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(
                                          alpha: 0.6,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        "Đưa rác thải vào giữa khung hình",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              : const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 24,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        /// Nút Flash
                        buildCameraButton(
                          icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                          iconColor:
                              _isFlashOn ? Colors.amberAccent : Colors.white,
                          onTap: isLoading ? () {} : _toggleFlash,
                        ),

                        /// Nút chụp ảnh
                        GestureDetector(
                          onTap: isLoading ? null : takePhoto,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isLoading
                                        ? Colors.grey
                                        : const Color(0xFF2E7D32),
                                width: 4,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      isLoading
                                          ? Colors.grey
                                          : const Color(0xFF2E7D32),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                        ),

                        /// Nút chuyển đổi camera trước/sau
                        buildCameraButton(
                          icon: Icons.cameraswitch,
                          onTap: isLoading ? () {} : _switchCamera,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Overlay trạng thái khi đang quét AI
              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.65),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(
                            color: Color(0xFF2E7D32),
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            "AI đang nhận diện rác...",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message ?? "Vui lòng đợi trong giây lát",
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

Widget buildCameraButton({
  required IconData icon,
  required VoidCallback onTap,
  Color iconColor = Colors.white,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withValues(alpha: 0.4),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    ),
  );
}
