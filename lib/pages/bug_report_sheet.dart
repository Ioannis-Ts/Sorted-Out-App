import 'package:flutter/material.dart';
import '../services/bug_report_service.dart';
import '../theme/app_variables.dart'; // ✅ Για τα AppColors και AppTexts

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
    // Αφαιρέσαμε το Dialog/Center.
    // Χρησιμοποιούμε Container που πιάνει το πλάτος και κάθεται κάτω.
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.ourYellow, // ✅ Κίτρινο Πλαίσιο
        // Στρογγυλεύουμε μόνο τις πάνω γωνίες αφού είναι στο κάτω μέρος
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      // Προσθέτουμε padding για το keyboard (viewInsets.bottom)
      padding: EdgeInsets.fromLTRB(
        20,
        24,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Πιάνει όσο χώρο χρειάζεται
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --- TITLE ---
          Text(
            'Report a bug',
            textAlign: TextAlign.center,
            style: AppTexts.generalTitle.copyWith( // ✅ General Title Style
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: 16),

          // --- TEXT FIELD ---
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Περίγραψε τι συνέβη…',
              filled: true,
              fillColor: Colors.white, // ✅ Λευκό φόντο στο πεδίο
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),

          const SizedBox(height: 20),

          // --- BUTTON ---
          ElevatedButton(
            onPressed: _sending ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.main, // ✅ Χρώμα Main
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: const StadiumBorder(), // ✅ Οβάλ σχήμα
              elevation: 0,
            ),
            child: Text(
              _sending ? 'Sending…' : 'Submit',
              style: AppTexts.generalTitle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}