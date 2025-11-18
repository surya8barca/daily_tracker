import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../models/entry.dart';

class EntryCard extends StatelessWidget {
  final String name;
  final List<Entry> entries;

  final bool todayEntryExists;

  final VoidCallback onAddToday;
  final VoidCallback onAddAnyDate; // NEW
  final void Function(Entry entry) onEditAny;
  final VoidCallback? onEditToday;

  final VoidCallback onDeleteTile;
  final VoidCallback onDeleteToday;

  final VoidCallback onOpenAnalysis;

  const EntryCard({
    super.key,
    required this.name,
    required this.entries,
    required this.todayEntryExists,
    required this.onAddToday,
    required this.onAddAnyDate,
    required this.onEditAny,
    required this.onEditToday,
    required this.onDeleteTile,
    required this.onDeleteToday,
    required this.onOpenAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final sorted = [...entries]..sort((a, b) => b.date.compareTo(a.date));
    final latest = sorted.first;
    final latestDateStr = DateFormat.yMMMd().format(latest.date);
    final unit = latest.unit ?? '';

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    Entry? todayEntry;
    for (final e in entries) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      if (d == todayOnly) {
        todayEntry = e;
        break;
      }
    }

    final latestValueText =
        unit.isEmpty ? '${latest.value}' : '${latest.value} $unit';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top row: Name + delete tile + Analysis
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Delete this metric (tile)',
                  icon: const Icon(Icons.delete_forever),
                  onPressed: () => _confirmDeleteTile(context),
                ),
                TextButton.icon(
                  onPressed: onOpenAnalysis,
                  icon: const Icon(Icons.show_chart),
                  label: const Text("Analysis"),
                )
              ],
            ),
            const SizedBox(height: 4),
            // latest value + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Latest: $latestValueText",
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  latestDateStr,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // today + any-date actions row
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (!todayEntryExists)
                  ElevatedButton.icon(
                    onPressed: onAddToday,
                    icon: const Icon(Icons.add),
                    label: const Text("Add today's data"),
                  )
                else ...[
                  if (todayEntry != null && onEditToday != null)
                    TextButton.icon(
                      onPressed: onEditToday,
                      icon: const Icon(Icons.edit_calendar),
                      label: const Text("Edit today's count"),
                    ),
                  TextButton.icon(
                    onPressed: () => _confirmDeleteToday(context),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text("Delete today's entry"),
                  ),
                ],
                // NEW: add any-date button
                OutlinedButton.icon(
                  onPressed: onAddAnyDate,
                  icon: const Icon(Icons.date_range),
                  label: const Text("Add entry (any date)"),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // actions row for latest entry (info, edit)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => onEditAny(latest),
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit entry"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTile(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Delete tile?",
      desc: "This will delete ALL entries for \"$name\".\nAre you sure?",
      buttons: [
        DialogButton(
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          onPressed: () => Navigator.pop(context),
        ),
        DialogButton(
          child: const Text("Delete", style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.pop(context);
            onDeleteTile();
          },
        ),
      ],
    ).show();
  }

  void _confirmDeleteToday(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Delete today's entry?",
      desc: "This will delete ONLY today's entry for \"$name\".\nAre you sure?",
      buttons: [
        DialogButton(
          child: const Text("Cancel", style: TextStyle(color: Colors.white)),
          onPressed: () => Navigator.pop(context),
        ),
        DialogButton(
          child: const Text("Delete", style: TextStyle(color: Colors.white)),
          onPressed: () {
            Navigator.pop(context);
            onDeleteToday();
          },
        ),
      ],
    ).show();
  }
}
