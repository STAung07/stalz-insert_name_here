# Services Documentation

## StudentService

The `StudentService` provides methods for interacting with student data in the application. It extends the base `DatabaseService` class and follows the singleton pattern to ensure only one instance exists throughout the application.

### Usage

To use the StudentService in your code:

```dart
import 'package:flutter_app/src/services/student_service.dart';

// Get the singleton instance
final studentService = StudentService();

// Now you can call methods on the service
```

### Available Methods

#### `getAllStudents()`

Returns a list of all students in the system as `UserModel` objects.

```dart
List<UserModel> students = await studentService.getAllStudents();
```

#### `searchStudentsByName(String query)`

Searches for students by name and returns a list of maps with 'id' and 'name' keys.

```dart
List<Map<String, dynamic>> searchResults = await studentService.searchStudentsByName("John");
// Each result has format: {'id': 'user_id', 'name': 'user_full_name'}
```

#### `getStudentsByIds(List<String> studentIds)`

Returns a list of `UserModel` objects for the given student IDs.

```dart
List<UserModel> students = await studentService.getStudentsByIds(['id1', 'id2']);
```

#### `loadStudentNames(List<String> studentIds)`

Returns a map of student IDs to their full names.

```dart
Map<String, String> studentNames = await studentService.loadStudentNames(['id1', 'id2']);
// Format: {'id1': 'John Doe', 'id2': 'Jane Smith'}
```

### Implementation Details

The service uses Supabase to query the 'users' table with the role 'student'. It handles type casting to ensure proper data types are returned from the database queries.

### Error Handling

All methods include try-catch blocks and will throw exceptions with descriptive error messages if database operations fail.