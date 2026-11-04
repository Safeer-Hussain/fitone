import '../entities/run_record.dart';

abstract class RunningRepository {
  Future<List<RunRecord>> getRunHistory();
  Future<void> saveRunRecord(RunRecord run);
  Future<RunRecord?> getRunById(String id);
}
