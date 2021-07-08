class Preferences {
  Preferences({this.language, this.imageSize}); //, this.lastLoginDate});

  int id;
  String language;
  String imageSize;
  //String lastLoginDate;

  Preferences.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.language = map['language'];
    this.imageSize = map['imageSize'];
    //this.lastLoginDate = map['lastLoginDate'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'language': this.language,
      'imageSize': this.imageSize,
      //'lastLoginDate': this.lastLoginDate,
    };
  }

  String toString() {
    return 'Preferences{id: $id, ' +
        'language: $language, ' +
        'imageSize: $imageSize}';
    //'lastLoginDate: $lastLoginDate}';
  }
}
