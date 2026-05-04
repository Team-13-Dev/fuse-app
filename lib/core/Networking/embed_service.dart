import 'package:dio/dio.dart';

class EmbedService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl:
          "https://api.openai.com/v1", // or OpenAI if Groq doesn't support embeddings
      headers: {
        "Authorization":
            "Bearer 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",
        "Content-Type": "application/json",
      },
    ),
  );

  Future<List<double>> embed(String text) async {
    final response = await _dio.post(
      "/embeddings",
      data: {
        "model": "text-embedding-3-small", // use OpenAI for embeddings
        "input": text,
      },
    );

    final List<dynamic> raw = response.data["data"][0]["embedding"];
    return raw.map((e) => (e as num).toDouble()).toList();
  }
}

class DocumentStore {
  // Your raw business documents/chunks
  static const List<String> documents = [
    "Total revenue this month is 124,500 EGP.",
    "Best selling product is Product A with 320 units sold.",
    "Worst selling product is Product C with only 4 units sold.",
    "Pending orders: 12. Completed: 87. Cancelled: 3.",
    "Net profit this month is 99,000 EGP after expenses.",
    "Top customer is Ahmed Mohamed with 32 orders.",
    "New customers this month: 45. Returning: 295.",
    "Most active sales day is Friday.",
    "Product A costs 150 EGP, stock: 200 units.",
    "Product B costs 80 EGP, stock: 50 units.",
    "Product C costs 320 EGP, stock: 10 units.",
    "Monthly expenses: Rent 8,000 EGP, Salaries 15,000 EGP, Utilities 2,500 EGP.",
  ];

  // Pre-computed embeddings — generated once and stored here
  // See Step 5 on how to generate these
  static List<List<double>> embeddings = [];
}
