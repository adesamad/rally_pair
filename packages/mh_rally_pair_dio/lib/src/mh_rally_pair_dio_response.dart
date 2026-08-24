class MhRallyPairDioResponse {
  const MhRallyPairDioResponse({
    this.success,
    this.code,
    this.data,
    this.message,
  });

  factory MhRallyPairDioResponse.fromJson(Map<String, dynamic> json) {
    return MhRallyPairDioResponse(
      success: json['success'] as bool?,
      code: json['code'] as int?,
      data: json['data'],
      message: json['message'] as String?,
    );
  }

  final bool? success;
  final int? code;
  final dynamic data;
  final String? message;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'success': success,
    'code': code,
    'data': data,
    'message': message,
  };
}
