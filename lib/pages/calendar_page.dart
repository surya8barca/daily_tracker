import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../providers/entries_provider.dart';
import '../widgets/custom_app_bar.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EntriesProvider>(context);
    final entries = provider.allEntries;

    final appointments = entries.map((e) {
      return Appointment(
        startTime: DateTime(e.date.year, e.date.month, e.date.day, 9),
        endTime: DateTime(e.date.year, e.date.month, e.date.day, 9, 30),
        subject: '${e.name}: ${e.value}',
        notes: e.notes ?? '',
      );
    }).toList();

    return Scaffold(
      appBar: const CustomAppBar(title: 'Calendar'),
      body: SfCalendar(
        view: CalendarView.month,
        dataSource: _EntriesDataSource(appointments),
        monthViewSettings: const MonthViewSettings(showAgenda: true),
      ),
    );
  }
}

class _EntriesDataSource extends CalendarDataSource {
  _EntriesDataSource(List<Appointment> source) {
    appointments = source;
  }
}
