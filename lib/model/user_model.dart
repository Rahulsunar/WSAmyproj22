class UserModel {
  String? name;
  String? id;
  String? phone;
  String? childEmail;
  String? parentEmail;
  UserModel(
      {this.name, this.id, this.phone, this.childEmail, this.parentEmail});

  Map<String, dynamic> toJson() => {
        'name': name,
        'id': id,
        'phone': phone,
        'childEmail': childEmail,
        'parentEmail': parentEmail,
      };
}
