class News {
  final String title;
  final String media;
  final String link;
  final String rights;
  final String publishDate;

  News(
      {required this.title,
      required this.media,
      required this.link,
      required this.rights,
      required this.publishDate});

  News fromJson(Map<String, dynamic> json) {
    return News(
        title: json['userId'],
        media: json['media'],
        link: json['link'],
        rights: json['rights'],
        publishDate: json['publishDate']);
  }
}
