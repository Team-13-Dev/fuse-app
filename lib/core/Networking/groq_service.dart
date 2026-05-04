import 'package:dio/dio.dart';
import 'package:fuse_system/core/Helpers/cosine_simillarty.dart';
import 'embed_service.dart';

class GroqService {
  final EmbedService _embedService = EmbedService();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://api.groq.com/openai/v1",
      headers: {
        "Authorization": "Bearer YOUR_GROQ_API_KEY",
        "Content-Type": "application/json",
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<String> sendMessage(String message) async {
    // ── Step 1: Embed the user's query ──
    final queryEmbedding = await _embedService.embed(message);

    // ── Step 2: Score all documents ──
    final scored = <Map<String, dynamic>>[];

    for (int i = 0; i < DocumentStore.documents.length; i++) {
      scored.add({
        "doc": DocumentStore.documents[i],
        "score": cosineSimilarity(queryEmbedding, DocumentStore.embeddings[i]),
      });
    }

    // ── Step 3: Sort and take top 5 ──
    scored.sort(
      (a, b) => (b["score"] as double).compareTo(a["score"] as double),
    );
    final top = scored.take(5).toList();

    // ── Step 4: Build context ──
    final context = top.map((t) => t["doc"] as String).join("\n");

    // ── Step 5: Call Groq with context ──
    final response = await _dio.post(
      "/chat/completions",
      data: {
        "model": "llama-3.1-8b-instant",
        "messages": [
          {
            "role": "system",
            "content":
                "You are a business assistant. Answer using only the provided data. Use EGP.",
          },
          {"role": "user", "content": "Question: $message\n\nData:\n$context"},
        ],
      },
    );

    return response.data["choices"][0]["message"]["content"];
  }
}
