import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<List<dynamic>> otimizarRota(Map<String, dynamic> requestData) async {
    try {
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/otimizar_rota/"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(requestData),
      );
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['rota_otimizada'];
      } else {
        throw Exception('Erro ao otimizar rota');
      }
    } catch (e) {
      throw Exception('Erro: $e');
    }
  }
}
