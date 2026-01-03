import 'package:flutter/material.dart';
import '../services/bug_report_service.dart';

class BugReportSheet extends StatefulWidget {
  const BugReportSheet({super.key, required this.source});
  final String source; // 'shake' ή 'shortcut'

  @override
  State<BugReportSheet> createState() => _BugReportSheetState();
}

class _BugReportSheetState extends State<BugReportSheet> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final msg = _controller.text.trim();
    if (msg.isEmpty) return;

    setState(() => _sending = true);
    try {
      final routeName = ModalRoute.of(context)?.settings.name;

      await BugReportService.submit(
        message: msg,
        source: widget.source,
        route: routeName,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit bug report: $e')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Report a bug',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Περιέγραψε τι συνέβη…',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _sending ? null : _submit,
              child: Text(_sending ? 'Sending…' : 'Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
