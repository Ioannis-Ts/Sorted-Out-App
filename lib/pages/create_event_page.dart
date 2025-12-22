import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_variables.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  List<String> _imageUrls = List.filled(4, '');

  bool _isEditingTitle = false;
  bool _isEditingLocation = false;

  // --- LOGIC: Create Event ---
  Future<void> _createEvent() async {
    final title = _titleController.text.trim();
    final location = _locationController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty ||
        location.isEmpty ||
        description.isEmpty ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill: Title, Location, Date, Time, Description')),
      );
      return;
    }

    final eventDateTime = DateTime(
      _selectedDate!.year,
      _selectedDate!.month,
      _selectedDate!.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    try {
      await FirebaseFirestore.instance.collection('Events').add({
        'title': title,
        'location': location,
        'date': Timestamp.fromDate(eventDateTime),
        'description': description,
        'imageUrls': _imageUrls.where((e) => e.trim().isNotEmpty).toList(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      Navigator.pop(context); // Go back to Home/Events page
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    }
  }

  void _setImageAtSlot(int slotIndex, String url) {
    setState(() {
      _imageUrls[slotIndex] = url;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _onAddImagePressed(int slotIndex) async {
    final url = await _pickUrlDialog();
    if (url != null && url.isNotEmpty) _setImageAtSlot(slotIndex, url);
  }

  Future<String?> _pickUrlDialog() async {
    final controller = TextEditingController();

    final url = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Paste image URL'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'https://...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    return url?.trim();
  }

  @override
  Widget build(BuildContext context) {
    final dateText = (_selectedDate == null)
        ? 'Date'
        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';

    final timeText = (_selectedTime == null)
        ? 'Time'
        : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. Content
          SafeArea(
            child: Column(
              children: [
                // --- HEADER (Back Arrow + Title + Save Button) ---
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ✅ Back button (Top Left)
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 28),
                        color: AppColors.textMain,
                        onPressed: () => Navigator.pop(context),
                      ),
                      
                      // Title
                      Text(
                        'Add Event',
                        style: AppTexts.generalTitle.copyWith(
                          fontSize: 28,
                        ),
                      ),
                      
                      // Save button (Top Right)
                      TextButton(
                        onPressed: _createEvent,
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

                // --- SCROLLABLE FORM ---
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        
                        // Event Title Input
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isEditingTitle = true;
                              });
                            },
                            child: _isEditingTitle
                                ? TextField(
                                    controller: _titleController,
                                    autofocus: true,
                                    textAlign: TextAlign.center,
                                    style: AppTexts.generalTitle.copyWith(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Event Title',
                                    ),
                                    onEditingComplete: () {
                                      setState(() {
                                        _isEditingTitle = false;
                                      });
                                    },
                                  )
                                : Text(
                                    _titleController.text.isEmpty
                                        ? 'Event Title'
                                        : _titleController.text,
                                    style: AppTexts.generalTitle.copyWith(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Location - Date - Time
                        Row(
                          children: [
                            // Location
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isEditingLocation = true;
                                  });
                                },
                                child: _isEditingLocation
                                    ? TextField(
                                        controller: _locationController,
                                        autofocus: true,
                                        style: AppTexts.generalBody.copyWith(fontSize: 16),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'Location',
                                          isDense: true,
                                        ),
                                        onEditingComplete: () {
                                          setState(() {
                                            _isEditingLocation = false;
                                          });
                                        },
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

                            Text(' - ', style: AppTexts.generalBody.copyWith(fontSize: 16)),

                            // Date
                            GestureDetector(
                              onTap: () async {
                                await _selectDate(context);
                                if (_selectedDate != null) {
                                  if (mounted) await _selectTime(context);
                                }
                              },
                              child: Text(
                                dateText,
                                style: AppTexts.generalBody.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            Text(' - ', style: AppTexts.generalBody.copyWith(fontSize: 16)),

                            // Time
                            GestureDetector(
                              onTap: () async {
                                if (_selectedDate == null) {
                                  await _selectDate(context);
                                  if (_selectedDate == null) return;
                                }
                                if (mounted) await _selectTime(context);
                              },
                              child: Text(
                                timeText,
                                style: AppTexts.generalBody.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Description Label
                        Text(
                          'Description',
                          style: AppTexts.generalTitle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Description Box
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.ourYellow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _descriptionController,
                            maxLines: 8,
                            style: AppTexts.generalBody.copyWith(
                              fontSize: 14,
                              color: AppColors.textMain,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'What will your event be about?',
                              hintStyle: AppTexts.generalBody.copyWith(
                                fontSize: 14,
                                color: AppColors.grey,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Pictures Label
                        Text(
                          'Pictures',
                          style: AppTexts.generalTitle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Pictures Box
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.ourYellow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildAddPhotoBox(0),
                                  const SizedBox(width: 16),
                                  _buildAddPhotoBox(1),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildAddPhotoBox(2),
                                  const SizedBox(width: 16),
                                  _buildAddPhotoBox(3),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Extra space at bottom for easy scrolling
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
      // ✅ No BottomNavigationBar here
    );
  }

  // Widget helper for photo boxes
  Widget _buildAddPhotoBox(int slotIndex) {
    final url = _imageUrls[slotIndex].trim();
    final hasUrl = url.isNotEmpty;

    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onAddImagePressed(slotIndex),
              borderRadius: BorderRadius.circular(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: hasUrl
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, size: 32, color: AppColors.grey),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                      )
                    : const Center(
                        child: Icon(Icons.add, size: 40, color: AppColors.grey),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}