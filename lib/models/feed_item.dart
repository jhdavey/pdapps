class FeedItem {
  final String type;
  final Map<String, dynamic> data;

  FeedItem({required this.type, required this.data});

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      type: json['type'],
      data: json['data'],
    );
  }
}
