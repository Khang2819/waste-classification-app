import '../../domain/entities/scan_entities.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/scan_remote_data_sources.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ScanRemoteDataSource remoteDataSource;

  ScanRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ScanEntities> scanWaste(String imagePath) async {
    return await remoteDataSource.scanWaste(imagePath);
  }
}
