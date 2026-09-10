import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/scan_waste.dart';
import 'scan_state.dart';

class ScanCubit extends Cubit<ScanState> {
  final ScanWaste scanWasteUseCase;

  ScanCubit({required this.scanWasteUseCase}) : super(ScanInitial());

  Future<void> scanImage(String imagePath) async {
    emit(const ScanLoading(message: 'Đang phân tích hình ảnh...'));
    try {
      final result = await scanWasteUseCase(imagePath);
      emit(ScanSuccess(result));
    } catch (e) {
      final errorMsg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
      emit(ScanError(errorMsg));
    }
  }

  void reset() {
    emit(ScanInitial());
  }
}
