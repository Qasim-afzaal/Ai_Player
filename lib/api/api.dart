import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://147.182.254.9:8002";

  static Map<String, String> headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(
      "$baseUrl$endpoint",
    ).replace(queryParameters: queryParams);
    return await http.get(uri, headers: headers);
  }

  static Future<http.Response> post(String endpoint, {dynamic body}) async {
    final uri = Uri.parse("$baseUrl$endpoint");
    return await http.post(uri, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> patch(String endpoint, {dynamic body}) async {
    final uri = Uri.parse("$baseUrl$endpoint");
    return await http.patch(uri, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse("$baseUrl$endpoint");
    return await http.delete(uri, headers: headers);
  }
}
