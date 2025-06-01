import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;
   DatabaseService.internal();


  // Common helper methods can stay here
  Future<void> checkResponse(dynamic response) async {
    if (response.status != 200 && response.status != 201) {
      throw PostgrestException(
        message: 'Request failed with status: ${response.status}',
        code: response.status.toString(),
      );
    }
  }
}

