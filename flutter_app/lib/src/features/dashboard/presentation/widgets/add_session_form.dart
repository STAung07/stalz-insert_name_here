import 'package:flutter/material.dart';
import 'package:flutter_app/src/models/training_session_model.dart';
import 'package:flutter_app/src/services/training_session_service.dart';
import 'package:intl/intl.dart';

class AddSessionForm extends StatefulWidget {
  final String coachId;
  final VoidCallback? onSessionCreated;
  const AddSessionForm({super.key, required this.coachId, this.onSessionCreated});

  @override
  State<AddSessionForm> createState() => _AddSessionFormState();
}

class _AddSessionFormState extends State<AddSessionForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  Future<void> _selectDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = pickedTime;
        } else {
          _endTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Session Title'),
            validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text(_selectedDate == null
                ? 'Select Date'
                : DateFormat('MMM dd, yyyy').format(_selectedDate!)),
            trailing: const Icon(Icons.calendar_today),
            onTap: () => _selectDate(context),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  title: Text(_startTime == null
                      ? 'Start Time'
                      : _startTime!.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(context, true),
                ),
              ),
              Expanded(
                child: ListTile(
                  title: Text(_endTime == null
                      ? 'End Time'
                      : _endTime!.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // location
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(labelText: 'location'),
            validator: (value) => value?.isEmpty ?? true ? 'Please enter a location' : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // TODO: Save session to database
                TrainingSessionModel newSession = TrainingSessionModel(
                  academyId: "",
                  title: _titleController.text,
                  startTime: DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _startTime!.hour, _startTime!.minute),
                  endTime: DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, _endTime!.hour, _endTime!.minute),
                  location: _locationController.text,
                );
                TrainingSessionService().createSession(newSession, widget.coachId);
                if (widget.onSessionCreated != null) {
                  widget.onSessionCreated!();
                }
                Navigator.of(context).pop();
                print("refreshing");
              }
            },
            child: const Text('Save Session'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}