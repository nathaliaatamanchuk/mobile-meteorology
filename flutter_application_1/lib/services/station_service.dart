import '../models/station.dart';
import 'api.dart';

class StationService {
  final ApiClient _api = ApiClient();

  Future<List<Station>> list() async {
    final data = await _api.getList('/stations/', auth: true);
    return data.map((e) => Station.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Station> create({required String name, String description = '', required double latitude, required double longitude, bool isActive = true}) async {
    final payload = {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive
    };
    final json = await _api.postJson('/stations/', payload, auth: true);
    return Station.fromJson(json);
  }
}
