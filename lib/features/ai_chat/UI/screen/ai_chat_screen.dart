import 'dart:io';
import 'dart:math' as math;

import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:excel/excel.dart' as xsl;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fuse_system/core/Networking/groq_service.dart';

// ─── Message model ────────────────────────────────────────────────────────────

class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;

  ChatMessage({required this.text, required this.isUser, this.isError = false});
}

// ─── Sheet Parser ─────────────────────────────────────────────────────────────

class SheetParser {
  static Future<String> parse(String filePath) async {
    final ext = filePath.split('.').last.toLowerCase();
    if (ext == 'xlsx' || ext == 'xlsm') return _parseXlsx(filePath);
    return _parseCsv(filePath, sep: ext == 'tsv' ? '\t' : ',');
  }

  static Future<String> _parseXlsx(String path) async {
    final bytes = await File(path).readAsBytes();
    final workbook = xsl.Excel.decodeBytes(bytes);
    final buf = StringBuffer();
    for (final sheetName in workbook.tables.keys) {
      final sheet = workbook.tables[sheetName]!;
      final rows = sheet.rows
          .map((r) => r.map((c) => c?.value?.toString() ?? '').toList())
          .toList();
      buf.writeln('=== Sheet: $sheetName ===');
      buf.writeln(_summariseRows(rows));
      buf.writeln();
    }
    return buf.toString();
  }

  static Future<String> _parseCsv(String path, {String sep = ','}) async {
    final raw = await File(path).readAsString();
    final rows = const CsvToListConverter()
        .convert(raw, fieldDelimiter: sep)
        .map((r) => r.map((c) => c.toString()).toList())
        .toList();
    return _summariseRows(rows);
  }

  static String _summariseRows(List<List<String>> rows) {
    if (rows.isEmpty) return '(empty)';
    final headers = rows.first;
    final data = rows.skip(1).toList();
    final buf = StringBuffer();

    buf.writeln('Columns: ${headers.join(', ')}');
    buf.writeln('Total rows: ${data.length}');
    buf.writeln();

    final numStats = <String, _Stat>{};
    for (var c = 0; c < headers.length; c++) {
      final vals = data
          .where((r) => c < r.length)
          .map((r) => double.tryParse(r[c]))
          .whereType<double>()
          .toList();
      if (vals.isEmpty) continue;
      vals.sort();
      numStats[headers[c]] = _Stat(
        count: vals.length,
        sum: vals.reduce((a, b) => a + b),
        min: vals.first,
        max: vals.last,
        mean: vals.reduce((a, b) => a + b) / vals.length,
      );
    }

    if (numStats.isNotEmpty) {
      buf.writeln('=== NUMERIC STATS ===');
      buf.writeln('Column | Rows | Sum | Min | Mean | Max');
      for (final e in numStats.entries) {
        final s = e.value;
        buf.writeln(
          '${e.key} | ${s.count} | ${s.sum.toStringAsFixed(2)} | '
          '${s.min.toStringAsFixed(2)} | ${s.mean.toStringAsFixed(2)} | ${s.max.toStringAsFixed(2)}',
        );
      }
      buf.writeln();
    }

    final catCols = <String, Set<String>>{};
    for (var c = 0; c < headers.length; c++) {
      if (numStats.containsKey(headers[c])) continue;
      final unique = data
          .where((r) => c < r.length && r[c].isNotEmpty)
          .map((r) => r[c])
          .toSet();
      if (unique.length <= 50) catCols[headers[c]] = unique;
    }

    if (catCols.isNotEmpty) {
      buf.writeln('=== CATEGORICAL VALUES ===');
      for (final e in catCols.entries) {
        buf.writeln('${e.key}: ${e.value.take(30).join(', ')}');
      }
      buf.writeln();
    }

    buf.writeln('=== SAMPLE ROWS (first 10) ===');
    buf.writeln(headers.join(' | '));
    for (final row in data.take(10)) {
      buf.writeln(row.join(' | '));
    }

    return buf.toString();
  }
}

class _Stat {
  final int count;
  final double sum, min, max, mean;
  const _Stat({
    required this.count,
    required this.sum,
    required this.min,
    required this.max,
    required this.mean,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with TickerProviderStateMixin {
  // ── Controllers ──
  late AnimationController _typingController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // ── State ──
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isParsing = false;
  String _context = '';
  String _fileName = '';

  final GroqService _groq = GroqService();

  // ── Suggestion chips ──
  final List<String> _defaultChips = [
    'How can I boost my sales?',
    'What are my top categories?',
    'Tips to reduce order failures?',
  ];

  final List<String> _fileChips = [
    'What is my total revenue?',
    'Which column has the highest average?',
    'Summarise the data for me',
  ];

  @override
  void initState() {
    super.initState();

    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _messages.add(
      ChatMessage(
        text:
            "Hello! I'm FUSE AI. Ask me anything about your store's performance, products, or strategy. You can also upload an Excel or CSV file and I'll analyse it for you.",
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _typingController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─── File picker ─────────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xlsm', 'xls', 'csv', 'tsv'],
    );
    if (result == null || result.files.single.path == null) return;

    final path = result.files.single.path!;
    final name = result.files.single.name;

    setState(() {
      _isParsing = true;
      _fileName = name;
      _context = '';
    });

    try {
      final ctx = await SheetParser.parse(path);
      setState(() {
        _context = ctx;
        _isParsing = false;
        _messages.add(
          ChatMessage(
            text: '📎 "$name" loaded successfully! Ask me anything about it.',
            isUser: false,
          ),
        );
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isParsing = false;
        _fileName = '';
      });
      _showSnack('Could not read file: $e', error: true);
    }
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error
            ? const Color(0xFFE17055)
            : const Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ─── Send ─────────────────────────────────────────────────────────────────

  Future<void> _sendMessage([String? override]) async {
    final text = (override ?? _textController.text).trim();
    if (text.isEmpty || _isLoading || _isParsing) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      // Build history excluding the seed welcome + new user message
      final history = _messages.sublist(0, _messages.length - 1);

      String reply;

      // If GroqService supports context pass-through, use the raw Dio path.
      // Otherwise fall back to the plain wrapper and prepend context as a
      // user message so it still reaches the model.
      if (_context.isNotEmpty) {
        reply = await _sendWithContext(history, text);
      } else {
        reply = await _groq.sendMessage(text);
      }

      setState(() => _messages.add(ChatMessage(text: reply, isUser: false)));
    } catch (e) {
      setState(
        () => _messages.add(
          ChatMessage(
            text: 'Sorry, something went wrong. Please try again.',
            isUser: false,
            isError: true,
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  /// Sends the message together with the spreadsheet context via Groq's API
  /// using the same endpoint/key that [GroqService] wraps.
  Future<String> _sendWithContext(
    List<ChatMessage> history,
    String userMessage,
  ) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    const model = 'llama-3.1-8b-instant';

    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.groq.com/openai/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
    );

    final systemPrompt =
        '''You are a business assistant for a FUSE commerce system. Answer using ONLY the data provided below.
Always use EGP for monetary values. Be concise and accurate.

--- BUSINESS DATA ---
$_context
--- END DATA ---''';

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': systemPrompt},
      ...history
          .takeLast(10)
          .map(
            (m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text},
          ),
      {'role': 'user', 'content': userMessage},
    ];

    final res = await dio.post(
      '/chat/completions',
      data: {
        'model': model,
        'messages': messages,
        'temperature': 0.3,
        'max_tokens': 1024,
      },
    );
    return res.data['choices'][0]['message']['content'] as String;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            if (_fileName.isNotEmpty) _buildFileChip(),
            if (_isParsing) _buildParsingBanner(),
            Expanded(child: _buildMessageList()),
            _buildSuggestionRow(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  // ─── App bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFFEEF2F7),
      child: Row(
        children: [
          // Back
          _circleButton(
            icon: Icons.arrow_back,
            onTap: () => Navigator.of(context).pop(),
          ),

          // Title
          Expanded(
            child: Column(
              children: [
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF22C55E),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'FUSE AI',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF22C55E),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Upload shortcut
          _circleButton(
            icon: Icons.upload_file_rounded,
            color: _context.isNotEmpty
                ? const Color(0xFF2563EB)
                : Colors.black54,
            onTap: _isParsing ? null : _pickFile,
            tooltip: 'Upload Excel / CSV',
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    Color color = Colors.black54,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Tooltip(
        message: tooltip ?? '',
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }

  // ─── File chip ────────────────────────────────────────────────────────────

  Widget _buildFileChip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.table_chart_rounded,
            size: 14,
            color: Color(0xFF2563EB),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _fileName,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _context = '';
              _fileName = '';
            }),
            child: const Icon(Icons.close, size: 14, color: Color(0xFF2563EB)),
          ),
        ],
      ),
    );
  }

  // ─── Parsing banner ───────────────────────────────────────────────────────

  Widget _buildParsingBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF2563EB),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Reading "$_fileName"…',
            style: const TextStyle(fontSize: 13, color: Color(0xFF2563EB)),
          ),
        ],
      ),
    );
  }

  // ─── Message list ─────────────────────────────────────────────────────────

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoading && index == _messages.length) {
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildTypingIndicator(),
          );
        }

        final msg = _messages[index];

        if (index == 0 && !msg.isUser) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimestamp(),
              const SizedBox(height: 12),
              _buildAIMessage(msg.text),
              const SizedBox(height: 16),
            ],
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: msg.isUser
              ? _buildUserMessage(msg.text)
              : _buildAIMessage(msg.text, isError: msg.isError),
        );
      },
    );
  }

  // ─── Suggestion chips row ─────────────────────────────────────────────────

  Widget _buildSuggestionRow() {
    final chips = _context.isNotEmpty ? _fileChips : _defaultChips;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _sendMessage(chips[i]),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF2563EB).withOpacity(0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              chips[i],
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Timestamp ────────────────────────────────────────────────────────────

  Widget _buildTimestamp() {
    final now = TimeOfDay.now();
    final hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = now.period == DayPeriod.am ? 'AM' : 'PM';
    return Center(
      child: Text(
        'Today, $hour:$minute $period',
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ─── AI message bubble ────────────────────────────────────────────────────

  Widget _buildAIMessage(String text, {bool isError = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAIAvatar(),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  'FUSE AI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isError ? const Color(0xFFFFF0EE) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: isError
                      ? Border.all(
                          color: const Color(0xFFE17055).withOpacity(0.4),
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 15,
                    color: isError ? const Color(0xFFE17055) : Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAIAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF2563EB).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Image.asset('assets/aiLogo.png', width: 30.w, height: 30.h),
      ),
    );
  }

  // ─── User message bubble ──────────────────────────────────────────────────

  Widget _buildUserMessage(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFF2563EB),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'Y',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'YOU',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Typing indicator ─────────────────────────────────────────────────────

  Widget _buildTypingIndicator() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAIAvatar(),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                'FUSE AI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _typingController,
                builder: (context, _) {
                  return Row(
                    children: List.generate(3, (i) {
                      final delay = i * 0.2;
                      final value = math
                          .sin(
                            (_typingController.value * math.pi) -
                                (delay * math.pi),
                          )
                          .clamp(0.0, 1.0);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Color.lerp(
                            Colors.grey.shade300,
                            const Color(0xFF2563EB),
                            value,
                          ),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Input bar ────────────────────────────────────────────────────────────

  Widget _buildInputBar() {
    final canSend = !_isLoading && !_isParsing;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attach / file button
          GestureDetector(
            onTap: _isParsing ? null : _pickFile,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _context.isNotEmpty
                    ? Icons.table_chart_rounded
                    : Icons.attach_file_rounded,
                size: 20,
                color: _context.isNotEmpty
                    ? const Color(0xFF2563EB)
                    : Colors.black54,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _textController,
                enabled: canSend,
                onSubmitted: (_) => _sendMessage(),
                maxLines: 4,
                minLines: 1,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: _context.isEmpty
                      ? 'Ask FUSE about your business'
                      : 'Ask about your data…',
                  hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Mic button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.mic_outlined,
              size: 20,
              color: Colors.black54,
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          GestureDetector(
            onTap: canSend ? _sendMessage : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: !canSend
                      ? [Colors.grey.shade300, Colors.grey.shade400]
                      : [const Color(0xFFFF6B35), const Color(0xFFFF4500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: canSend
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF6B35).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Extension ────────────────────────────────────────────────────────────────

extension<T> on List<T> {
  List<T> takeLast(int n) => length <= n ? this : sublist(length - n);
}
