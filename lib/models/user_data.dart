// Maps the UserData interface from CartContext.tsx

class UserData {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String postalCode;
  final String paymentMethod;

  const UserData({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'postalCode': postalCode,
        'paymentMethod': paymentMethod,
      };

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        address: json['address'] as String,
        city: json['city'] as String,
        postalCode: json['postalCode'] as String,
        paymentMethod: json['paymentMethod'] as String,
      );
}
