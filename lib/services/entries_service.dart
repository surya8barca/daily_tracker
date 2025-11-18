import 'package:hive/hive.dart';
import '../models/entry.dart';

class EntriesService {
  static const String boxName = 'entriesBox';

  Box<Entry> get _box => Hive.box<Entry>(boxName);

  List<Entry> getAll() {
    final list = _box.values.toList();
    list.sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  List<Entry> getByName(String name) {
    return getAll().where((e) => e.name == name).toList();
  }

  Map<String, List<Entry>> groupedByName() {
    final map = <String, List<Entry>>{};
    for (final e in getAll()) {
      map.putIfAbsent(e.name, () => []).add(e);
    }
    return map;
  }

  Future<void> addEntry(Entry entry) async {
    await _box.add(entry);
  }

  Future<void> updateEntry(int key, Entry entry) async {
    await _box.put(key, entry);
  }

  Future<void> deleteEntryByObject(Entry entry) async {
    await entry.delete();
  }

  Future<void> deleteAllForName(String name) async {
    // collect keys to delete first (can't modify box while iterating values)
    final keysToDelete = _box.keys.where((k) {
      final e = _box.get(k);
      return e != null && e.name == name;
    }).toList();

    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }

  // 🔹 delete only today's entry for a metric name
  Future<void> deleteTodayForName(String name) async {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    final keysToDelete = _box.keys.where((k) {
      final e = _box.get(k);
      if (e == null) return false;
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return e.name == name && d == todayOnly;
    }).toList();

    for (final key in keysToDelete) {
      await _box.delete(key);
    }
  }

  // find entry by exact day (name + date's day)
  Entry? entryForDay(String name, DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    try {
      return _box.values.firstWhere(
        (e) =>
            e.name == name &&
            DateTime(e.date.year, e.date.month, e.date.day) == day,
      );
    } catch (_) {
      return null;
    }
  }

  // Hive key for entry
  int? keyForEntry(Entry entry) {
    return entry.key as int?;
  }
}
