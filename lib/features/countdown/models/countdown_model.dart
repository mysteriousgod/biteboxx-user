class CountdownModel {
  final String title;
  final String subtitle;
  final DateTime launchDate;

  CountdownModel({
    required this.title,
    required this.subtitle,
    required this.launchDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'launchDate': launchDate.toIso8601String(),
    };
  }

  factory CountdownModel.fromJson(Map<String, dynamic> json) {
    return CountdownModel(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] ?? '',
      launchDate: DateTime.parse(json['launchDate']),
    );
  }

  // Default countdown configuration for April 8th launch
  factory CountdownModel.defaultLaunch() {
    final now = DateTime.now();
    // Set to April 8th, 12:00 PM (noon)
    final launchDate = DateTime(now.year, 4, 8, 12, 0, 0);
    
    // If April 8th has passed this year, set to next year
    if (launchDate.isBefore(now)) {
      launchDate.add(Duration(days: 365));
    }

    return CountdownModel(
      title: 'BiteBoxx Coming Soon!',
      subtitle: 'Delicious food, delivered to your doorstep',
      launchDate: launchDate,
    );
  }

  Map<String, int> getRemainingTime() {
    final now = DateTime.now();
    final difference = launchDate.difference(now);

    if (difference.isNegative) {
      return {
        'days': 0,
        'hours': 0,
        'minutes': 0,
        'seconds': 0,
      };
    }

    return {
      'days': difference.inDays,
      'hours': difference.inHours % 24,
      'minutes': difference.inMinutes % 60,
      'seconds': difference.inSeconds % 60,
    };
  }

  bool get isLaunched => launchDate.isBefore(DateTime.now());
}
