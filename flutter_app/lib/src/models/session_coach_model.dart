class SessionCoachModel  {
  final String sessionId;
  final String coachId;

  SessionCoachModel({
    required this.sessionId,
    required this.coachId,
  });
  factory SessionCoachModel.fromMap(Map<String, dynamic> map) {
    return SessionCoachModel(
      sessionId: map['session_id']?? '',
      coachId: map['coach_id']?? '',
    );
  }

  Map<String, dynamic> toJsonMap(SessionCoachModel sessionCoach) {
    return {
      'session_id': sessionCoach.sessionId,
      'coachId': sessionCoach.coachId
    };
  }
}