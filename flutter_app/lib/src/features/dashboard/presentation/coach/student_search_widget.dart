import 'package:flutter/material.dart';
import 'package:flutter_app/src/services/student_service.dart';

class StudentSearchWidget extends StatefulWidget {
  /// List of currently selected student IDs
  final List<String> selectedStudents;

  /// Map of student IDs to their names
  final Map<String, String> studentNames;

  /// Callback when a student is selected
  final Function(String id, String name) onStudentSelected;

  /// Callback when a student is removed
  final Function(String id) onStudentRemoved;

  const StudentSearchWidget({
    Key? key,
    required this.selectedStudents,
    required this.studentNames,
    required this.onStudentSelected,
    required this.onStudentRemoved,
  }) : super(key: key);

  @override
  State<StudentSearchWidget> createState() => _StudentSearchWidgetState();
}
class _StudentSearchWidgetState extends State<StudentSearchWidget> {
  final _searchController = TextEditingController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  List<Map<String, dynamic>> _searchResults = [];
  final StudentService _studentService = StudentService();

void _showOverlay() {
  if (_overlayEntry != null) return;

  _overlayEntry = OverlayEntry(
    builder: (context) {
      return Stack(
        children: [
          // Transparent barrier to detect taps outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _removeOverlay();
                FocusScope.of(context).unfocus();
              },
              behavior: HitTestBehavior.translucent,
              child: Container(),
            ),
          ),
          // The dropdown itself
          Positioned(
            width: MediaQuery.of(context).size.width * 0.8,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, 48),
              child: Material(
                elevation: 4,
                child: Container(
                  constraints: BoxConstraints(maxHeight: 150),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final student = _searchResults[index];
                      return ListTile(
                        dense: true,
                        title: Text(student['name'] ?? 'Unknown'),
                        onTap: () {
                          if (!widget.selectedStudents.contains(student['id'])) {
                            widget.onStudentSelected(student['id'], student['name']);
                          }
                          _clearSearch();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );

  Overlay.of(context)!.insert(_overlayEntry!);
}


  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults.clear();
    });
    _removeOverlay();
    FocusScope.of(context).unfocus();
  }

  Future<void> _searchStudents(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      _removeOverlay();
      return;
    }
    try {
      final results = await _studentService.searchStudentsByName(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
        if (_searchResults.isNotEmpty) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (e) {
      print('Error searching students: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching students: $e')),
      );
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Add Students",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: widget.selectedStudents
                  .map(
                    (id) => Chip(
                      label: Text(widget.studentNames[id] ?? id),
                      onDeleted: () {
                        widget.onStudentRemoved(id);
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 12),

            CompositedTransformTarget(
              link: _layerLink,
              child: SizedBox(
                width: double.infinity,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search students...',
                    border: OutlineInputBorder(),
                    isDense: true,
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
                  ),
                  controller: _searchController,
                  onChanged: _searchStudents,
                ),
              ),
            ),

            // Remove the inline search results here — overlay replaces it
          ],
        ),
      ),
    );
  }
}
