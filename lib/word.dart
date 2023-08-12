class Word {
  int? id;
  String? turkish;
  String? english;
  String? turkish_sentence;
  String? english_sentence;

  Word.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    //title = json['title'];
    turkish = json['turkish'];
    english = json['english'];
    turkish_sentence = json['turkish_sentence'];
    english_sentence = json['english_sentence'];
  }
}
