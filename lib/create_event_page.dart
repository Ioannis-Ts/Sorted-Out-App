import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme/app_variables.dart';
import 'widgets/main_nav_bar.dart';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  List<String> _imageUrls = [];

  bool _isEditingTitle = false;
  bool _isEditingLocation = false;
  bool _isEditingDate = false;
  bool _isEditingTime = false;

  // Δημιουργία Event στο Firestore
  Future<void> _createEvent() async {
    final title = _titleController.text;
    final location = _locationController.text;
    final description = _descriptionController.text;

    if (title.isEmpty || location.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields!')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Events').add({
        'title': title,
        'location': location,
        'date': Timestamp.fromDate(_selectedDate),
        'time': '${_selectedTime.hour}:${_selectedTime.minute}',
        'description': description,
        'imageUrls': _imageUrls,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event created successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create event: $e')),
      );
    }
  }

  // Επιλογή ημερομηνίας
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _isEditingDate = false;
      });
    }
  }

  // Επιλογή ώρας
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
        _isEditingTime = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppImages.background),
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          // Το περιεχόμενο
          SafeArea(
            child: Column(
              children: [
                // Custom AppBar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      // Title
                      Text(
                        'Add Event',
                        style: AppTexts.generalTitle.copyWith(
                          fontSize: 28,
                        ),
                      ),
                      // Save button
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
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Τίτλος του event (κεντραρισμένος)
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
                            // Τοποθεσία
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
                            
                            // Ημερομηνία
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: Text(
                                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                style: AppTexts.generalBody.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                            
                            Text(' - ', style: AppTexts.generalBody.copyWith(fontSize: 16)),
                            
                            // Ώρα
                            GestureDetector(
                              onTap: () => _selectTime(context),
                              child: Text(
                                '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                style: AppTexts.generalBody.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // "Description" label
                        Text(
                          'Description',
                          style: AppTexts.generalTitle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        const SizedBox(height: 12),

                        // Περιγραφή του event (κίτρινο κουτί)
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

                        // "Pictures" label
                        Text(
                          'Pictures',
                          style: AppTexts.generalTitle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        const SizedBox(height: 12),

                        // Φωτογραφίες (κίτρινο κουτί με 4 + buttons)
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
                                  _buildAddPhotoBox(),
                                  const SizedBox(width: 16),
                                  _buildAddPhotoBox(),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildAddPhotoBox(),
                                  const SizedBox(width: 16),
                                  _buildAddPhotoBox(),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80), // Διάστημα για το navigation bar
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: MainNavBar(
        currentIndex: null,
        onTabSelected: (index) {
          // Handle navigation based on index
          // 0 = AI, 1 = Home, 2 = Map
          if (index == 1) {
            Navigator.pop(context); // Go back to home
          }
          // Add other navigation logic here
        },
      ),
    );
  }

  // Widget για τα κουτιά προσθήκης φωτογραφιών
  Widget _buildAddPhotoBox() {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.grey,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // TODO: Implement image picker
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image picker not implemented yet')),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: const Center(
                child: Icon(
                  Icons.add,
                  size: 40,
                  color: AppColors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}