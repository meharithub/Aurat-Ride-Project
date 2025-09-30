import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  final String apiKey;

  PlacesService(this.apiKey);

  // Get autocomplete predictions
  Future<List<dynamic>> getPredictions(String input) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&types=geocode";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['predictions'] ?? [];
    } else {
      throw Exception("Failed to fetch predictions");
    }
  }

  // Get place details (lat/lng) by placeId
  Future<Map<String, dynamic>?> getPlaceLatLng(String placeId) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final location = json['result']?['geometry']?['location'];
      if (location != null) {
        return {
          "lat": location['lat'],
          "lng": location['lng'],
        };
      }
    }
    return null;
  }
}
