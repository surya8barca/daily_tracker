import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Entry extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int value;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String? notes;

  @HiveField(4)
  String? unit; // e.g. "kg", "bottles", etc.

  Entry({
    required this.name,
    required this.value,
    required this.date,
    this.notes,
    this.unit,
  });
}

// Manual adapter so no build_runner needed
class EntryAdapter extends TypeAdapter<Entry> {
  @override
  final int typeId = 0;

  @override
  Entry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return Entry(
      name: fields[0] as String,
      value: fields[1] as int,
      date: fields[2] as DateTime,
      notes: fields[3] as String?,
      unit: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Entry obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.value)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.notes)
      ..writeByte(4)
      ..write(obj.unit);
  }
}
