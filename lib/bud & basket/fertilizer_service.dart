import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/fertilzer_model.dart';

class FertilizerService {
  final String serverIp; // dynamic IP

  FertilizerService({required this.serverIp});

  Future<List<Fertilizer>> fetchFertilizers() async {
    final url = Uri.parse('http://$serverIp:4000/api/fertilizers'); // use dynamic IP + port
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Fertilizer.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch fertilizers');
    }
  }
}
