import 'package:flutter/foundation.dart';
import '../models/entry.dart';
import '../services/entries_service.dart';

class EntriesProvider extends ChangeNotifier {
  final EntriesService _service = EntriesService();

  List<Entry> get allEntries => _service.getAll();

  Map<String, List<Entry>> get groupedEntries => _service.groupedByName();

  List<Entry> entriesForName(String name) => _service.getByName(name);

  Entry? entryForDay(String name, DateTime date) =>
      _service.entryForDay(name, date);

  int? keyForEntry(Entry entry) => _service.keyForEntry(entry);

  Future<void> addEntry(Entry entry) async {
    await _service.addEntry(entry);
    notifyListeners();
  }

  Future<void> updateEntry(int key, Entry entry) async {
    await _service.updateEntry(key, entry);
    notifyListeners();
  }

  Future<void> deleteEntryObject(Entry entry) async {
    await _service.deleteEntryByObject(entry);
    notifyListeners();
  }

  Future<void> deleteAllForName(String name) async {
    await _service.deleteAllForName(name);
    notifyListeners();
  }

  // delete only today's entry for a metric
  Future<void> deleteTodayForName(String name) async {
    await _service.deleteTodayForName(name);
    notifyListeners();
  }
}
