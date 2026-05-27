class DetectionResult {
  final int score;
  final String eye;
  final String eyebrow;
  final String mouth;

  DetectionResult({
    required this.score,
    required this.eye,
    required this.eyebrow,
    required this.mouth,
  });
}