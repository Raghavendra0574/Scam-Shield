import 'dart:convert';
import 'package:http/http.dart' as http;

// Model representing one API post.
class DemoPost {
  final int id;
  final String title;
  final String body;

  const DemoPost({
    required this.id,
    required this.title,
    required this.body,
  });

  factory DemoPost.fromJson(Map<String, dynamic> json) {
    return DemoPost(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

// Fetch sample posts from the REST API.
Future<List<DemoPost>> fetchDemoPosts() async {
  final url = Uri.parse(
    'https://jsonplaceholder.typicode.com/posts?_limit=5',
  );

  final response = await http
      .get(url)
      .timeout(const Duration(seconds: 15));

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to load posts. HTTP ${response.statusCode}',
    );
  }

  final decodedData = jsonDecode(response.body);

  if (decodedData is! List) {
    throw const FormatException(
      'Unexpected response from the API.',
    );
  }

  return decodedData.map<DemoPost>((item) {
    if (item is! Map<String, dynamic>) {
      throw const FormatException('Invalid post data.');
    }

    return DemoPost.fromJson(item);
  }).toList();
}