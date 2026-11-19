import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

const Color _schoolLifeGreen = Color(0xFF3A9E48);
const String _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);
const String _delayFormUrl = 'https://forms.office.com/r/Gjnya3nHwH';
const List<String> _weekdays = ['月', '火', '水', '木', '金', '土', '日'];

DateTime _dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

String _apiDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _formatDate(DateTime value) {
  return '${value.year}年${value.month}月${value.day}日';
}

String _formatEventDateRange(_CalendarEvent event) {
  final start = event.startDate;
  final end = event.endDate;

  if (start.year == end.year &&
      start.month == end.month &&
      start.day == end.day) {
    return '${start.month}月${start.day}日';
  }

  if (start.year == end.year && start.month == end.month) {
    return '${start.month}月${start.day}日〜${end.day}日';
  }

  if (start.year == end.year) {
    return '${start.month}月${start.day}日〜${end.month}月${end.day}日';
  }

  return '${start.year}年${start.month}月${start.day}日〜'
      '${end.year}年${end.month}月${end.day}日';
}

String _errorText(Object error) =>
    error.toString().replaceFirst('Exception: ', '');

class SchoolLifeScreen extends StatelessWidget {
  const SchoolLifeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7F5),
        appBar: AppBar(
          backgroundColor: _schoolLifeGreen,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            '学校生活',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.access_time), text: '遅延手続き'),
              Tab(icon: Icon(Icons.calendar_today_outlined), text: '年間予定'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_DelayProcedureTab(), _AnnualScheduleTab()],
        ),
      ),
    );
  }
}

class _DelayProcedureTab extends StatelessWidget {
  const _DelayProcedureTab();

  Future<void> _openForms(BuildContext context) async {
    try {
      final opened = await launchUrl(
        Uri.parse(_delayFormUrl),
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Formsを開けませんでした。')));
      }
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Formsを開けませんでした。')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '電車の遅れで遅刻するとき',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text('当日は、次の2つの手続きをしてください。'),
                        const SizedBox(height: 20),
                        const _ProcedureStep(
                          number: '1',
                          title: '9:00までに先生へ連絡',
                          description: '担当の先生へLINEまたはTeamsで連絡してください。',
                        ),
                        const _ProcedureStep(
                          number: '2',
                          title: 'Formsに記入',
                          description: '下のボタンからFormsを開いて記入してください。',
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () => _openForms(context),
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('電車遅延Formsを開く'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _schoolLifeGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: const Color(0xFFFFF4E5),
                  elevation: 0,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF8A5A00)),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '遅延証明書は受け取って保管してください。受付への提出は不要です。',
                            style: TextStyle(height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProcedureStep extends StatelessWidget {
  const _ProcedureStep({
    required this.number,
    required this.title,
    required this.description,
  });

  final String number;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _schoolLifeGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: _schoolLifeGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarEvent {
  const _CalendarEvent({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.title,
    required this.details,
  });

  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final String title;
  final String details;

  factory _CalendarEvent.fromJson(Map<String, dynamic> json) {
    return _CalendarEvent(
      id: (json['id'] as num).toInt(),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      title: json['title'] as String,
      details: (json['details'] as String?) ?? '',
    );
  }

  bool occursOn(DateTime value) {
    final day = _dateOnly(value);
    return !day.isBefore(_dateOnly(startDate)) &&
        !day.isAfter(_dateOnly(endDate));
  }

  bool overlapsMonth(int year, int month) {
    final monthStart = DateTime(year, month, 1);
    final nextMonth = DateTime(year, month + 1, 1);
    return !endDate.isBefore(monthStart) && startDate.isBefore(nextMonth);
  }
}

class _EventDraft {
  const _EventDraft({
    required this.startDate,
    required this.endDate,
    required this.title,
    required this.details,
  });

  final DateTime startDate;
  final DateTime endDate;
  final String title;
  final String details;
}

class _CalendarApi {
  static Uri _uri(String path, {Map<String, String>? query}) {
    final base = _apiBaseUrl.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$base/calendar$path').replace(queryParameters: query);
  }

  static Map<String, String> _headers({String? token, bool json = false}) {
    return {
      'Accept': 'application/json',
      if (json) 'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static void _checkResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    var message = 'サーバーエラー (${response.statusCode})';
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is Map && decoded['detail'] != null) {
        message = decoded['detail'].toString();
      }
    } catch (_) {
      // エラー本文がJSONでない場合は、上の既定メッセージを使います。
    }

    throw Exception(message);
  }

  static Future<List<_CalendarEvent>> fetchEvents(int year) async {
    final response = await http
        .get(_uri('/events', query: {'year': '$year'}), headers: _headers())
        .timeout(const Duration(seconds: 15));

    _checkResponse(response);

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    return decoded
        .map(
          (item) =>
              _CalendarEvent.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  static Future<String> login(String password) async {
    final response = await http
        .post(
          _uri('/admin/login'),
          headers: _headers(json: true),
          body: jsonEncode({'password': password}),
        )
        .timeout(const Duration(seconds: 15));

    _checkResponse(response);

    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final token = decoded['access_token'];

    if (token is! String) {
      throw Exception('ログイン応答を確認できませんでした。');
    }

    return token;
  }

  static Future<void> saveEvent({
    required String token,
    required int? id,
    required _EventDraft draft,
  }) async {
    final body = jsonEncode({
      'start_date': _apiDate(draft.startDate),
      'end_date': _apiDate(draft.endDate),
      'title': draft.title,
      'details': draft.details,
    });

    final uri = id == null ? _uri('/events') : _uri('/events/$id');

    final response = id == null
        ? await http
              .post(
                uri,
                headers: _headers(token: token, json: true),
                body: body,
              )
              .timeout(const Duration(seconds: 15))
        : await http
              .put(
                uri,
                headers: _headers(token: token, json: true),
                body: body,
              )
              .timeout(const Duration(seconds: 15));

    _checkResponse(response);
  }

  static Future<void> deleteEvent({
    required String token,
    required int id,
  }) async {
    final response = await http
        .delete(_uri('/events/$id'), headers: _headers(token: token))
        .timeout(const Duration(seconds: 15));

    _checkResponse(response);
  }
}

class _AnnualScheduleTab extends StatefulWidget {
  const _AnnualScheduleTab();

  @override
  State<_AnnualScheduleTab> createState() => _AnnualScheduleTabState();
}

class _AnnualScheduleTabState extends State<_AnnualScheduleTab> {
  late int _year;
  late int _month;
  DateTime? _selectedDate;

  List<_CalendarEvent> _events = [];
  bool _loading = true;
  bool _saving = false;
  bool _adminBusy = false;
  String? _loadError;
  String? _adminToken;
  int _loadRequest = 0;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _year = today.year;
    _month = today.month;
    _loadEvents();
  }

  List<_CalendarEvent> get _monthEvents {
    final result =
        _events.where((event) => event.overlapsMonth(_year, _month)).toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));
    return result;
  }

  List<_CalendarEvent> get _visibleEvents {
    final selectedDate = _selectedDate;
    if (selectedDate == null) return _monthEvents;

    return _monthEvents.where((event) => event.occursOn(selectedDate)).toList();
  }

  Future<void> _loadEvents({int? year}) async {
    final targetYear = year ?? _year;
    final request = ++_loadRequest;

    setState(() {
      _loading = true;
      _loadError = null;
    });

    try {
      final events = await _CalendarApi.fetchEvents(targetYear);
      if (!mounted || request != _loadRequest) return;

      setState(() {
        _events = events;
        _loading = false;
        _loadError = null;
      });
    } catch (error) {
      if (!mounted || request != _loadRequest) return;

      setState(() {
        _loading = false;
        _loadError = _errorText(error);
      });
    }
  }

  void _changeMonth(int difference) {
    final next = DateTime(_year, _month + difference, 1);
    if (next.year < 1900 || next.year > 2100) return;

    final yearChanged = next.year != _year;

    setState(() {
      _year = next.year;
      _month = next.month;
      _selectedDate = null;
      if (yearChanged) _events = [];
    });

    if (yearChanged) {
      _loadEvents(year: next.year);
    }
  }

  void _goToToday() {
    final today = _dateOnly(DateTime.now());
    final yearChanged = today.year != _year;

    setState(() {
      _year = today.year;
      _month = today.month;
      _selectedDate = today;
      if (yearChanged) _events = [];
    });

    _loadEvents(year: today.year);
  }

  void _showSnack(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildMonthNavigation() {
    return Row(
      children: [
        IconButton(
          tooltip: '前の月',
          onPressed: _year == 1900 && _month == 1
              ? null
              : () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            '$_year年$_month月',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          tooltip: '今日へ戻る',
          onPressed: _goToToday,
          icon: const Icon(Icons.today),
        ),
        IconButton(
          tooltip: '次の月',
          onPressed: _year == 2100 && _month == 12
              ? null
              : () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right),
        ),
        IconButton(
          tooltip: '予定を再読込',
          onPressed: _loading ? null : () => _loadEvents(),
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }

  Widget _buildAdminControls() {
    if (_adminToken == null) {
      return Align(
        alignment: Alignment.centerRight,
        child: OutlinedButton.icon(
          onPressed: _adminBusy ? null : _login,
          icon: const Icon(Icons.admin_panel_settings_outlined),
          label: Text(_adminBusy ? '確認中…' : '管理者ログイン'),
        ),
      );
    }

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        const Chip(
          avatar: Icon(Icons.admin_panel_settings, size: 18),
          label: Text('管理者'),
        ),
        OutlinedButton.icon(
          onPressed: _saving ? null : () => setState(() => _adminToken = null),
          icon: const Icon(Icons.logout),
          label: const Text('ログアウト'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : () => _showEventEditor(),
          icon: const Icon(Icons.add),
          label: const Text('予定を追加'),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    final firstWeekday = DateTime(_year, _month, 1).weekday;
    final daysInMonth = DateTime(_year, _month + 1, 0).day;
    final leadingEmptyDays = firstWeekday - 1;
    final cellCount = ((leadingEmptyDays + daysInMonth + 6) ~/ 7) * 7;

    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                for (var index = 0; index < _weekdays.length; index++)
                  Expanded(
                    child: Center(
                      child: Text(
                        _weekdays[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: index == 5
                              ? Colors.blue.shade700
                              : index == 6
                              ? Colors.red.shade700
                              : Colors.black54,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cellCount,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: 44,
              ),
              itemBuilder: (context, index) {
                final dayNumber = index - leadingEmptyDays + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox.shrink();
                }

                final date = DateTime(_year, _month, dayNumber);
                final selected =
                    _selectedDate != null && _dateOnly(_selectedDate!) == date;
                final isToday = _dateOnly(DateTime.now()) == date;
                final hasEvent = _events.any((event) => event.occursOn(date));

                final dayColor = selected
                    ? Colors.white
                    : date.weekday == 7
                    ? Colors.red.shade700
                    : date.weekday == 6
                    ? Colors.blue.shade700
                    : Colors.black87;

                return Padding(
                  padding: const EdgeInsets.all(1),
                  child: Material(
                    color: selected ? _schoolLifeGreen : Colors.transparent,
                    shape: CircleBorder(
                      side: BorderSide(
                        color: isToday ? _schoolLifeGreen : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => setState(() => _selectedDate = date),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              color: dayColor,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: hasEvent
                                  ? selected
                                        ? Colors.white
                                        : _schoolLifeGreen
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(_CalendarEvent event) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatEventDateRange(event),
                    style: const TextStyle(
                      color: _schoolLifeGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (event.details.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(event.details, style: const TextStyle(height: 1.4)),
                  ],
                ],
              ),
            ),
            if (_adminToken != null)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: '予定を編集',
                    onPressed: _saving
                        ? null
                        : () => _showEventEditor(event: event),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: '予定を削除',
                    onPressed: _saving ? null : () => _deleteEvent(event),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgenda() {
    final events = _visibleEvents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _selectedDate == null
                    ? 'この月の予定'
                    : '${_selectedDate!.month}月${_selectedDate!.day}日の予定',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (_selectedDate != null)
              TextButton(
                onPressed: () => setState(() => _selectedDate = null),
                child: const Text('月全体'),
              ),
          ],
        ),
        if (_loading && _events.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_loadError != null && _events.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('予定を表示できません。サーバーの起動を確認してください。'),
          )
        else if (events.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              _selectedDate == null ? 'この月の予定はありません。' : 'この日の予定はありません。',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          )
        else
          for (final event in events) _buildEventCard(event),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMonthNavigation(),
                _buildAdminControls(),
                if (_loading) const LinearProgressIndicator(),
                if (_loadError != null)
                  Card(
                    color: const Color(0xFFFFF4E5),
                    child: ListTile(
                      title: const Text('予定を読み込めませんでした'),
                      subtitle: Text(_loadError!),
                      trailing: IconButton(
                        tooltip: '再試行',
                        onPressed: _loading ? null : () => _loadEvents(),
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                _buildCalendar(),
                const SizedBox(height: 12),
                _buildAgenda(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _login() async {
    final passwordController = TextEditingController();

    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('管理者ログイン'),
          content: TextField(
            controller: passwordController,
            autofocus: true,
            obscureText: true,
            decoration: const InputDecoration(labelText: '管理者パスワード'),
            onSubmitted: (value) => Navigator.of(dialogContext).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(passwordController.text),
              child: const Text('ログイン'),
            ),
          ],
        );
      },
    );

    passwordController.dispose();

    if (!mounted || password == null || password.isEmpty) return;

    setState(() => _adminBusy = true);

    try {
      final token = await _CalendarApi.login(password);
      if (!mounted) return;

      setState(() => _adminToken = token);
      _showSnack('管理者としてログインしました。');
    } catch (error) {
      _showSnack('ログインできませんでした：${_errorText(error)}');
    } finally {
      if (mounted) setState(() => _adminBusy = false);
    }
  }

  Future<void> _showEventEditor({_CalendarEvent? event}) async {
    if (_adminToken == null) return;

    final titleController = TextEditingController(text: event?.title ?? '');
    final detailsController = TextEditingController(text: event?.details ?? '');
    final formKey = GlobalKey<FormState>();

    var startDate = event?.startDate ?? DateTime(_year, _month, 1);
    var endDate = event?.endDate ?? startDate;

    final draft = await showDialog<_EventDraft>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> chooseStartDate() async {
              final picked = await showDatePicker(
                context: dialogContext,
                initialDate: startDate,
                firstDate: DateTime(1900, 1, 1),
                lastDate: DateTime(2100, 12, 31),
              );

              if (picked == null) return;

              setDialogState(() {
                startDate = _dateOnly(picked);
                if (endDate.isBefore(startDate)) endDate = startDate;
              });
            }

            Future<void> chooseEndDate() async {
              final picked = await showDatePicker(
                context: dialogContext,
                initialDate: endDate.isBefore(startDate) ? startDate : endDate,
                firstDate: startDate,
                lastDate: DateTime(2100, 12, 31),
              );

              if (picked == null) return;
              setDialogState(() => endDate = _dateOnly(picked));
            }

            return AlertDialog(
              title: Text(event == null ? '予定を追加' : '予定を編集'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        maxLength: 100,
                        decoration: const InputDecoration(labelText: '予定名'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '予定名を入力してください。';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: detailsController,
                        maxLength: 500,
                        maxLines: 3,
                        decoration: const InputDecoration(labelText: '詳細（任意）'),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: chooseStartDate,
                          icon: const Icon(Icons.event),
                          label: Text('開始日：${_formatDate(startDate)}'),
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: chooseEndDate,
                          icon: const Icon(Icons.event_available),
                          label: Text('終了日：${_formatDate(endDate)}'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('キャンセル'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    Navigator.of(dialogContext).pop(
                      _EventDraft(
                        startDate: startDate,
                        endDate: endDate,
                        title: titleController.text.trim(),
                        details: detailsController.text.trim(),
                      ),
                    );
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    detailsController.dispose();

    if (!mounted || draft == null) return;
    await _saveEvent(draft, event);
  }

  Future<void> _saveEvent(
    _EventDraft draft,
    _CalendarEvent? existingEvent,
  ) async {
    final token = _adminToken;
    if (token == null) return;

    setState(() => _saving = true);

    try {
      await _CalendarApi.saveEvent(
        token: token,
        id: existingEvent?.id,
        draft: draft,
      );

      if (!mounted) return;

      _showSnack(existingEvent == null ? '予定を追加しました。' : '予定を更新しました。');
      await _loadEvents();
    } catch (error) {
      _showSnack('保存できませんでした：${_errorText(error)}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _deleteEvent(_CalendarEvent event) async {
    final token = _adminToken;
    if (token == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('予定を削除'),
          content: Text('「${event.title}」を削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('キャンセル'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('削除'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    setState(() => _saving = true);

    try {
      await _CalendarApi.deleteEvent(token: token, id: event.id);
      if (!mounted) return;

      _showSnack('予定を削除しました。');
      await _loadEvents();
    } catch (error) {
      _showSnack('削除できませんでした：${_errorText(error)}');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
