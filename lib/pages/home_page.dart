import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../models/entry.dart';
import '../providers/entries_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/entry_card.dart';
import 'analysis_page.dart';
import 'calendar_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _nameController = TextEditingController(text: 'Water bottles');
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  final _unitController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    _notesController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  /// Full edit dialog: user can change name, value, date, notes, unit
  void _showFullEditDialog(Entry existing) async {
    final entriesProvider =
        Provider.of<EntriesProvider>(context, listen: false);

    _nameController.text = existing.name;
    _valueController.text = existing.value.toString();
    _notesController.text = existing.notes ?? '';
    _unitController.text = existing.unit ?? '';

    DateTime selectedDate = existing.date;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text('Edit entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  readOnly: true,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _valueController,
                  decoration:
                      const InputDecoration(labelText: 'Value (number)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                      labelText: 'Unit (e.g. kg, bottles)'),
                ),
                TextField(
                  controller: _notesController,
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Date: '),
                    TextButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) {
                          setSt(() => selectedDate = d);
                        }
                      },
                      child: Text(DateFormat.yMd().format(selectedDate)),
                    )
                  ],
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final value = int.tryParse(_valueController.text.trim()) ?? 0;
                final notes = _notesController.text.trim();
                final unit = _unitController.text.trim();

                if (name.isEmpty) return;

                final entry = Entry(
                  name: name,
                  value: value,
                  date: selectedDate,
                  notes: notes.isEmpty ? null : notes,
                  unit: unit.isEmpty ? null : unit,
                );

                await entriesProvider.updateEntry(existing.key as int, entry);

                if (context.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            )
          ],
        ),
      ),
    );
  }

  /// Today-only edit: user can ONLY change the count/value (unit stays same)
  void _showTodayCountEditDialog(Entry existing) async {
    final entriesProvider =
        Provider.of<EntriesProvider>(context, listen: false);

    _valueController.text = existing.value.toString();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Edit today's count"),
        content: TextField(
          controller: _valueController,
          decoration:
              const InputDecoration(labelText: 'Value (number) for today'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final value = int.tryParse(_valueController.text.trim()) ?? 0;

              final entry = Entry(
                name: existing.name,
                value: value,
                date: existing.date,
                notes: existing.notes,
                unit: existing.unit,
              );

              await entriesProvider.updateEntry(existing.key as int, entry);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  /// Add today’s data: user enters name, value, unit, notes; date fixed to today
  void _showAddTodayDialog({String? presetName}) async {
    final entriesProvider =
        Provider.of<EntriesProvider>(context, listen: false);

    _nameController.text = presetName ?? 'Water bottles';
    _valueController.clear();
    _notesController.clear();
    _unitController.clear();

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Add today's data"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _valueController,
                decoration: const InputDecoration(labelText: 'Value (number)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _unitController,
                decoration:
                    const InputDecoration(labelText: 'Unit (e.g. kg, bottles)'),
              ),
              TextField(
                controller: _notesController,
                decoration:
                    const InputDecoration(labelText: 'Notes (optional)'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Date: '),
                  Text(
                    DateFormat.yMd().format(todayOnly),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              final value = int.tryParse(_valueController.text.trim()) ?? 0;
              final notes = _notesController.text.trim();
              final unit = _unitController.text.trim();

              if (name.isEmpty) return;

              final already = entriesProvider.entryForDay(name, todayOnly);
              if (already != null) {
                Alert(
                  context: ctx,
                  type: AlertType.info,
                  title: "Already added",
                  desc:
                      "You have already added today's data for \"$name\".\nEdit it instead.",
                  buttons: [
                    DialogButton(
                      child: const Text("OK",
                          style: TextStyle(color: Colors.white)),
                      onPressed: () => Navigator.pop(ctx),
                    )
                  ],
                ).show();
                return;
              }

              final entry = Entry(
                name: name,
                value: value,
                date: todayOnly,
                notes: notes.isEmpty ? null : notes,
                unit: unit.isEmpty ? null : unit,
              );

              await entriesProvider.addEntry(entry);
              if (context.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  /// NEW: Add entry for ANY date for a given metric (name & unit taken from metric)
  void _showAddAnyDateDialog(String metricName, String? unitFromMetric) async {
    final entriesProvider =
        Provider.of<EntriesProvider>(context, listen: false);

    _nameController.text = metricName;
    _unitController.text = unitFromMetric ?? '';
    _valueController.clear();
    _notesController.clear();

    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: const Text("Add entry (any date)"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _valueController,
                  decoration:
                      const InputDecoration(labelText: 'Value (number)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _unitController,
                  decoration: const InputDecoration(
                      labelText: 'Unit (e.g. kg, bottles)'),
                ),
                TextField(
                  controller: _notesController,
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Date: '),
                    TextButton(
                      onPressed: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (d != null) {
                          setSt(() => selectedDate = d);
                        }
                      },
                      child: Text(DateFormat.yMd().format(selectedDate)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final value = int.tryParse(_valueController.text.trim()) ?? 0;
                final notes = _notesController.text.trim();
                final unit = _unitController.text.trim();

                if (name.isEmpty) return;

                // prevent duplicate for same name+date if you want
                final existingForDay =
                    entriesProvider.entryForDay(name, selectedDate);
                if (existingForDay != null) {
                  Alert(
                    context: ctx,
                    type: AlertType.info,
                    title: "Already exists",
                    desc:
                        "An entry for \"$name\" already exists on this date.\nEdit that instead.",
                    buttons: [
                      DialogButton(
                        child: const Text("OK",
                            style: TextStyle(color: Colors.white)),
                        onPressed: () => Navigator.pop(ctx),
                      )
                    ],
                  ).show();
                  return;
                }

                final entry = Entry(
                  name: name,
                  value: value,
                  date: selectedDate,
                  notes: notes.isEmpty ? null : notes,
                  unit: unit.isEmpty ? null : unit,
                );

                await entriesProvider.addEntry(entry);
                if (context.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteTile(String metricName) async {
    final provider = Provider.of<EntriesProvider>(context, listen: false);
    await provider.deleteAllForName(metricName);
  }

  Future<void> _deleteToday(String metricName) async {
    final provider = Provider.of<EntriesProvider>(context, listen: false);
    await provider.deleteTodayForName(metricName);
  }

  @override
  Widget build(BuildContext context) {
    final entriesProvider = Provider.of<EntriesProvider>(context);
    final grouped = entriesProvider.groupedEntries;
    final hasEntries = grouped.isNotEmpty;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Daily Recorder',
        extraActions: [
          IconButton(
            tooltip: 'Calendar',
            icon: const Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CalendarPage(),
                ),
              );
            },
          )
        ],
      ),
      body: hasEntries
          ? ListView(
              padding: const EdgeInsets.all(12),
              children: grouped.entries.map((group) {
                final name = group.key;
                final list = group.value;

                final todayEntry = entriesProvider.entryForDay(name, todayOnly);

                // use latest entry's unit as metric unit
                list.sort((a, b) => b.date.compareTo(a.date));
                final metricUnit = list.first.unit;

                return EntryCard(
                  name: name,
                  entries: list,
                  todayEntryExists: todayEntry != null,
                  onAddToday: () => _showAddTodayDialog(presetName: name),
                  onAddAnyDate: () => _showAddAnyDateDialog(name, metricUnit),
                  onEditAny: (entry) => _showFullEditDialog(entry),
                  onEditToday: todayEntry == null
                      ? null
                      : () => _showTodayCountEditDialog(todayEntry),
                  onDeleteTile: () => _deleteTile(name),
                  onDeleteToday: () => _deleteToday(name),
                  onOpenAnalysis: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnalysisPage(metricName: name),
                      ),
                    );
                  },
                );
              }).toList(),
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No entries yet'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add today\'s data'),
                    onPressed: () => _showAddTodayDialog(),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodayDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
