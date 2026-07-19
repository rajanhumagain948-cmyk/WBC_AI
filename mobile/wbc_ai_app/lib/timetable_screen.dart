import 'package:flutter/material.dart';
import 'main.dart';
import 'timetable_data.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  String _selectedClass = "AI1"; // 初期表示クラス
  String _selectedDay = "月";

  final List<String> _days = ["月", "火", "水", "木", "金"];

  Map<String, dynamic> get _currentClass =>
      timetableData.firstWhere((c) => c["class"] == _selectedClass);

  @override
  void initState() {
    super.initState();
    // 今日の曜日を初期選択(土日は月曜)
    final weekday = DateTime.now().weekday; // 1=月 ... 7=日
    if (weekday >= 1 && weekday <= 5) {
      _selectedDay = _days[weekday - 1];
    }
  }

  void _showClassPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'クラスを選択',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final c in timetableData)
              ListTile(
                title: Text(c["class"]),
                subtitle: Text('担任: ${c["homeroom"]}',
                    style: const TextStyle(fontSize: 12)),
                trailing: _selectedClass == c["class"]
                    ? const Icon(Icons.check, color: wbcGreen)
                    : null,
                onTap: () {
                  setState(() => _selectedClass = c["class"]);
                  Navigator.pop(context);
                },
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _currentClass["schedule"] as Map<String, dynamic>;
    final periods = (schedule[_selectedDay] as List?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: wbcGreen,
        title: const Text('時間割',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          // クラス切替ボタン
          TextButton.icon(
            onPressed: _showClassPicker,
            icon: const Icon(Icons.swap_horiz, color: Colors.white, size: 18),
            label: Text(
              _selectedClass,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 担任表示
          Container(
            width: double.infinity,
            color: wbcGreen.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              '$_selectedClass  担任: ${_currentClass["homeroom"]}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: wbcGreen),
            ),
          ),
          // 曜日タブ
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final day in _days)
                  GestureDetector(
                    onTap: () => setState(() => _selectedDay = day),
                    child: Container(
                      width: 52,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedDay == day
                            ? wbcGreen
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selectedDay == day
                              ? Colors.white
                              : Colors.black54,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 授業リスト
          Expanded(
            child: periods.isEmpty
                ? const Center(
                    child: Text('この日の授業はありません',
                        style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: periods.length,
                    itemBuilder: (context, index) {
                      final p = periods[index];
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: wbcGreen,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${p["period"]}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          title: Text(
                            p["subject"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          subtitle: Text(
                            '🕐 ${p["time"]}   👨‍🏫 ${p["teacher"]}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: wbcTeal.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${p["room"]}',
                              style: const TextStyle(
                                  color: wbcTeal,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
