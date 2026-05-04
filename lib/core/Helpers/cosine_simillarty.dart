import 'dart:math' as math;

double cosineSimilarity(List<double> a, List<double> b) {
  double dot = 0, magA = 0, magB = 0;

  for (int i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    magA += a[i] * a[i];
    magB += b[i] * b[i];
  }

  return dot / (math.sqrt(magA) * math.sqrt(magB));
}
