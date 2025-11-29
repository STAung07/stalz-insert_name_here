import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseService {
  final supabase = Supabase.instance.client;
   DatabaseService.internal();


  // Common helper methods can stay here
  Future<void> checkResponse(dynamic response) async {
    // If using Supabase's PostgrestResponse, check for status
    if (response is PostgrestResponse) {
      if (response.status != 200 && response.status != 201) {
        throw PostgrestException(
          message: 'Request failed with status: ${response.status}',
          code: response.status.toString(),
        );
      }
    }
    // If response is a Map and contains 'status'
    else if (response is Map && response.containsKey('status')) {
      if (response['status'] != 200 && response['status'] != 201) {
        throw Exception('Request failed with status: ${response['status']}');
      }
    }
    // Otherwise, assume success if not null
  }
}

