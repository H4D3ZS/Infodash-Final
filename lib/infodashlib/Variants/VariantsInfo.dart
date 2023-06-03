class VariantsInfo {
  late String _name = "";
  late String _description = "";

  String get description => _description;

  set description(String description) {
    _description = description;
  }

  late String _firstDetected = "";

  String get firstDetected => _firstDetected;

  set firstDetected(String firstDetected) {
    _firstDetected = firstDetected;
  }

  late String _lineage = "";

  String get lineage => _lineage;

  set lineage(String lineage) {
    _lineage = lineage;
  }

  late DateTime _dateReported = DateTime.now();

  DateTime get dateReported => _dateReported;

  set dateReported(DateTime dateReported) {
    _dateReported = dateReported;
  }

  late List<String> _symptomps = [];
  late String _imageUrl = "";

  String get imageUrl => _imageUrl;

  set imageUrl(String imageUrl) {
    _imageUrl = imageUrl;
  }

  String get name {
    return _name;
  }

  set name(String value) {
    _name = value;
  }

  List<String> get symptomps {
    return _symptomps;
  }

  set symptomps(List<String> symptomps) {
    _symptomps = symptomps;
  }

  Map<String, dynamic> toJson() {
    var data = this;
    var result = {
      // 'name': data.name,
      'lineage': data.lineage,
      'first_detected': data.firstDetected,
      'date_reported': data.dateReported,
      'description': data.description,
      'symptoms': data.symptomps,
      'image_url':
          'https://www.uhhospitals.org/-/media/Images/Blog/What-You-Need-to-Know-About-The-Omicron-Variant_Blog-OpenGraph.jpg'
    };

    return result;
  }
}
