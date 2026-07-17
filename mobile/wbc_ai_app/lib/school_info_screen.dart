import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart';

class SchoolInfoScreen extends StatelessWidget {
  const SchoolInfoScreen({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F5),
      appBar: AppBar(
        backgroundColor: wbcGreen,
        title: const Text('学校情報',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 学校名カード
          Card(
            elevation: 0,
            color: wbcGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset('assets/images/logo.png'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '早稲田文理専門学校',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const Text(
                    'Waseda-Bunri College of Arts & Sciences',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 連絡先
          _infoTile(
            icon: Icons.location_on,
            title: '住所',
            subtitle: '〒171-0033\n東京都豊島区高田2-6-7',
            onTap: () => _open(
                'https://www.google.com/maps/search/?api=1&query=東京都豊島区高田2-6-7'),
          ),
          _infoTile(
            icon: Icons.phone,
            title: '電話',
            subtitle: '03-5960-2611(受付 9:00〜16:30)',
            onTap: () => _open('tel:0359602611'),
          ),
          _infoTile(
            icon: Icons.email,
            title: 'メール',
            subtitle: 'info@wbc.ac.jp',
            onTap: () => _open('mailto:info@wbc.ac.jp'),
          ),
          _infoTile(
            icon: Icons.language,
            title: '公式サイト',
            subtitle: 'www.wbc.ac.jp',
            onTap: () => _open('https://www.wbc.ac.jp/'),
          ),

          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '🚉 アクセス',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: wbcGreen),
            ),
          ),
          const SizedBox(height: 8),
          _accessTile('都電荒川線「学習院下駅」', '徒歩約1分'),
          _accessTile('東京メトロ副都心線「雑司が谷駅」2番出口', '徒歩約6分'),
          _accessTile('東京メトロ東西線「高田馬場駅」7番出口', '徒歩約10分'),
          _accessTile('JR山手線「高田馬場駅」早稲田口', '徒歩約13分'),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: wbcGreen.withOpacity(0.1),
          child: Icon(icon, color: wbcGreen),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.open_in_new, size: 18, color: wbcTeal),
        onTap: onTap,
      ),
    );
  }

  Widget _accessTile(String station, String time) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.train, color: wbcTeal),
        title: Text(station, style: const TextStyle(fontSize: 14)),
        trailing: Text(time,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: wbcGreen)),
      ),
    );
  }
}