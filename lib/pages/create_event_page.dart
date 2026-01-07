import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_variables.dart';

class CreateEventPage extends StatefulWidget {
  final String userId;
  final String? eventId; // null = create, όχι null = edit

  const CreateEventPage({
    super.key,
    required this.userId,
    this.eventId,
  });

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  List<String> _imageUrls = List.filled(4, '');

  bool _isEditingTitle = false;
  bool _isEditingLocation = false;
  bool _loading = false;

  bool get isEdit => widget.eventId != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) _loadEvent();
  }

  Future<void> _loadEvent() async {
    setState(() => _loading = true);

    final doc = await FirebaseFirestore.instance
        .collection('Events')
        .doc(widget.eventId)
        .get();

    final data = doc.data()!;
    final dt = (data['date'] as Timestamp).toDate();

    _titleController.text = data['title'];
    _locationController.text = data['location'];
    _descriptionController.text = data['description'];
    _selectedDate = DateTime(dt.year, dt.month, dt.day);
    _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);

    final imgs = (data['imageUrls'] as List?)?.cast<String>() ?? [];
    for (int i = 0; i < imgs.length && i < 4; i++) {
      _imageUrls[i] = imgs[i];
    }

    setState(() => _loading = false);
  }

  Future<void> _saveEvent() async {
    if (_titleController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final dateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    final data = {
      'title': _titleController.text.trim(),
      'location': _locationController.text.trim(),
      'description': _descriptionController.text.trim(),
      'date': Timestamp.fromDate(dateTime),
      'imageUrls': _imageUrls.where((e) => e.isNotEmpty).toList(),
      'creatorId': widget.userId,
    };

    if (isEdit) {
      await FirebaseFirestore.instance
          .collection('Events')
          .doc(widget.eventId)
          .update(data);
    } else {
      await FirebaseFirestore.instance.collection('Events').add(data);
    }

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _pickImage(int index) async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Paste image URL'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (url != null && url.isNotEmpty) {
      setState(() => _imageUrls[index] = url);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final dateText = _selectedDate == null
        ? 'Date'
        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';

    final timeText = _selectedTime == null
        ? 'Time'
        : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        isEdit ? 'Edit Event' : 'Add Event',
                        style: AppTexts.generalTitle.copyWith(fontSize: 28),
                      ),
                      TextButton(
                        onPressed: _saveEvent,
                        child: Text(
                          'Save',
                          style: AppTexts.generalBody.copyWith(
                            fontSize: 18,
                            color: AppColors.anotherGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TITLE
                        Center(
                          child: GestureDetector(
                            onTap: () => setState(() => _isEditingTitle = true),
                            child: _isEditingTitle
                                ? TextField(
                                    controller: _titleController,
                                    autofocus: true,
                                    textAlign: TextAlign.center,
                                    style: AppTexts.generalTitle.copyWith(fontSize: 28),
                                    decoration: const InputDecoration(border: InputBorder.none),
                                    onEditingComplete: () =>
                                        setState(() => _isEditingTitle = false),
                                  )
                                : Text(
                                    _titleController.text.isEmpty
                                        ? 'Event Title'
                                        : _titleController.text,
                                    style: AppTexts.generalTitle.copyWith(fontSize: 28),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // LOCATION - DATE - TIME (ΙΔΙΟ)
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _isEditingLocation = true),
                                child: _isEditingLocation
                                    ? TextField(
                                        controller: _locationController,
                                        autofocus: true,
                                        decoration:
                                            const InputDecoration(border: InputBorder.none),
                                        onEditingComplete: () =>
                                            setState(() => _isEditingLocation = false),
                                      )
                                    : Text(
                                        _locationController.text.isEmpty
                                            ? 'Location'
                                            : _locationController.text,
                                        style: AppTexts.generalBody.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            Text(' - ', style: AppTexts.generalBody),
                            GestureDetector(
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2100),
                                );
                                if (d != null) {
                                  final t = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  );
                                  if (t != null) {
                                    setState(() {
                                      _selectedDate = d;
                                      _selectedTime = t;
                                    });
                                  }
                                }
                              },
                              child: Text(dateText, style: AppTexts.generalBody),
                            ),
                            Text(' - ', style: AppTexts.generalBody),
                            Text(timeText, style: AppTexts.generalBody),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // DESCRIPTION
                        Text('Description', style: AppTexts.generalTitle.copyWith(fontSize: 16)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.ourYellow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _descriptionController,
                            maxLines: 8,
                            decoration: const InputDecoration(border: InputBorder.none),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // IMAGES (ΚΙΤΡΙΝΟ BOX ΟΠΩΣ ΠΡΙΝ)
                        Text('Pictures', style: AppTexts.generalTitle.copyWith(fontSize: 16)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.ourYellow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              for (int i = 0; i < 4; i += 2)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      _imageBox(i),
                                      const SizedBox(width: 12),
                                      _imageBox(i + 1),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageBox(int index) {
    final url = _imageUrls[index];
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: InkWell(
          onTap: () => _pickImage(index),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: url.isEmpty
                ? const Center(child: Icon(Icons.add, color: AppColors.grey))
                : Image.network(url, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}
