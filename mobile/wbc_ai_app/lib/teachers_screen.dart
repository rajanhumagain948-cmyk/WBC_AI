import 'package:flutter/material.dart';
import 'main.dart';
import 'teacher_data.dart';

class TeachersScreen extends StatelessWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // カテゴリの一覧を順番どおりに作る
    final categories = <String>[];
    for (final t in teacherData) {
      if (!categories.contains(t["category"])) {
        categories.add(t["category"]!);
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: wbcGreen,
        title: const Text(
          '教員・職員紹介',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final cat in categories) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Text(
                cat,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: wbcGreen,
                ),
              ),
            ),
            for (final t in teacherData.where((t) => t["category"] == cat))
              Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: wbcGreen.withOpacity(0.1),
                    backgroundImage: (t["photo"] ?? "").isNotEmpty
                        ? AssetImage(t["photo"]!)
                        : null,
                    child: (t["photo"] ?? "").isEmpty
                        ? const Icon(Icons.person, color: wbcGreen)
                        : null,
                  ),
                  title: Text(
                    t["name"] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    [t["title"], t["dept"]]
                        .where((s) => (s ?? "").isNotEmpty)
                        .join("\n"),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}