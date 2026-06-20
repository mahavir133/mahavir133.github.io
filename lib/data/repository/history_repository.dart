import '../../core/db/local_db_service.dart';
import '../../domain/entity/history_item.dart';

class HistoryRepository {
  final LocalDbService _dbService;

  HistoryRepository(this._dbService);

  List<HistoryItem> getHistory() {
    final box = _dbService.historyBox;
    final items = box.values.map((v) {
      // Cast to map safely
      final map = Map<String, dynamic>.from(v as Map);
      return HistoryItem.fromMap(map);
    }).toList();
    items.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return items;
  }

  Future<void> saveItem(HistoryItem item) async {
    await _dbService.historyBox.put(item.id, item.toMap());
  }

  Future<void> deleteItem(String id) async {
    await _dbService.historyBox.delete(id);
  }

  Future<void> clearAll() async {
    await _dbService.historyBox.clear();
  }

  Future<void> toggleBookmark(String id) async {
    final box = _dbService.historyBox;
    final data = box.get(id);
    if (data != null) {
      final item = HistoryItem.fromMap(Map<String, dynamic>.from(data as Map));
      final updated = item.copyWith(isBookmarked: !item.isBookmarked);
      await box.put(id, updated.toMap());
    }
  }

  Future<void> updateItem(HistoryItem item) async {
    await _dbService.historyBox.put(item.id, item.toMap());
  }
}
