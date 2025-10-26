class Station {
  final String guid;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final bool isActive;
  Station({required this.guid, required this.name, required this.description, required this.latitude, required this.longitude, required this.isActive});
  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(
      guid: json['guid'] as String,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      latitude: double.parse('${json['latitude']}'),
      longitude: double.parse('${json['longitude']}'),
      isActive: json['is_active'] == null ? true : json['is_active'] as bool,
    );
  }
  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'code': null,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
    };
  }
}
