import 'package:flutter_app/src/models/user_model.dart';
import 'package:flutter_app/src/services/database_service.dart';

class UserService extends DatabaseService{
  UserService._internal() : super.internal();

  static final UserService _instance = UserService._internal();
  
  factory UserService() {
    return _instance;
  }
  Future<UserModel> getUser(String userId) async {
    final response = await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();
  // todo: might need to validate response -> await check response
    response.forEach((key, value) {
      print('Key: $key, Value: $value');
    });

    return UserModel.fromMap(response as Map<String, dynamic>);
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    final response = await supabase
        .from('users')
        .update(data)
        .eq('id', userId);
    await checkResponse(response);
  }

  // Add other user-specific operations
}