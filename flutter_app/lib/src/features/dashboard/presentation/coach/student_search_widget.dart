import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_app/src/services/student_service.dart';
import 'package:flutter_app/src/models/student_group_model.dart';
import 'package:flutter/material.dart';

class StudentSearchWidget extends StatefulWidget {
  /// List of currently selected student IDs
  final List<String> selectedStudents;

  /// Map of student IDs to their names
  final Map<String, String> studentNames;

  /// Callback when a student is selected
  final Function(String id, String name) onStudentSelected;

  /// Callback when a student is removed
  final Function(String id) onStudentRemoved;

  /// Academy ID to filter students
  final String? academyId;

  const StudentSearchWidget({
    Key? key,
    required this.selectedStudents,
    required this.studentNames,
    required this.onStudentSelected,
    required this.onStudentRemoved,
    required this.academyId,
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
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchStudents(query);
    });
  }

  Future<void> _showOverlay() async {
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
                        final result = _searchResults[index];
                        final type = result['type'];
                        final id = result['id'];
                        final name = result['name'];

                        return ListTile(
                          dense: true,
                          title: Text(name ?? 'Unknown'),
                          subtitle:
                              type == 'group' ? Text('Student Group') : null,
                          onTap: () async {
                            if (type == 'student') {
                              if (!widget.selectedStudents.contains(id)) {
                                widget.onStudentSelected(id, name);
                              }
                            } else if (type == 'group') {
                              if (!widget.selectedStudents.contains(id)) {
                                widget.onStudentSelected(id, name);
                              }
                            }
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _clearSearch();
                            });
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
      _removeOverlay(); // Remove overlay first
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    List<Map<String, dynamic>> combinedResults = [];

    // Search for students
    try {
      final studentResults = await _studentService.searchStudentsByName(
        query,
        widget.academyId,
      );
      combinedResults.addAll(
        studentResults.map((s) => {...s, 'type': 'student'}),
      );

      // Search for student groups
      final groupResults = await _studentService.searchStudentGroupsByName(
        query,
        widget.academyId!,
      ); // Use the new service method
      combinedResults.addAll(
        groupResults.map(
          (g) => {
            'id': g.id,
            'name': g.name,
            'student_ids': g.studentIds,
            'type': 'group',
          },
        ),
      );

      // Sort results to prioritize students or groups as desired
      // For now, no specific sorting, just combine.

      _removeOverlay(); // Ensure old overlay is removed before state update
      setState(() {
        _searchResults = combinedResults;
      });

      if (_searchResults.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showOverlay(); // Show new overlay after frame build
        });
      }
    } catch (e) {
      print('Error searching students: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error searching students: $e')));
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
              children:
                  widget.selectedStudents
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
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Students',
                  hintText: 'Enter student name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                          : null,
                ),
                onChanged: _onSearchChanged,
                onTap: () async {
                  if (_searchResults.isNotEmpty) {
                    await _showOverlay();
                  }
                },
              ),
            ),
          
            // Remove the inline search results here — overlay replaces it
          ],
        ),
      ),
    );
  }
}
