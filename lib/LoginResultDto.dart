class LoginResult {
  User? user;
  bool? success;
  String? accessToken;
  String? refreshToken;
  String? sessionKey;
  String? expiration;
  String? refreshTokenExpiration;

  LoginResult({this.user, this.success, this.accessToken, this.refreshToken, this.sessionKey, this.expiration, this.refreshTokenExpiration});

  LoginResult.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
    success = json['success'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    sessionKey = json['sessionKey'];
    expiration = json['expiration'];
    refreshTokenExpiration = json['refreshTokenExpiration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    data['success'] = success;
    data['accessToken'] = accessToken;
    data['refreshToken'] = refreshToken;
    data['sessionKey'] = sessionKey;
    data['expiration'] = expiration;
    data['refreshTokenExpiration'] = refreshTokenExpiration;
    return data;
  }
}

class User {
  int? id;
  String? uniqueId;
  String? name;
  String? email;
  bool? emailVerified;
  String? phoneNumber;
  bool? phoneVerified;

  User({this.id, this.uniqueId, this.name, this.email, this.emailVerified, this.phoneNumber, this.phoneVerified});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    uniqueId = json['uniqueId'];
    name = json['name'];
    email = json['email'];
    emailVerified = json['emailVerified'];
    phoneNumber = json['phoneNumber'];
    phoneVerified = json['phoneVerified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['uniqueId'] = uniqueId;
    data['name'] = name;
    data['email'] = email;
    data['emailVerified'] = emailVerified;
    data['phoneNumber'] = phoneNumber;
    data['phoneVerified'] = phoneVerified;
    return data;
  }
}
