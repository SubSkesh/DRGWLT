class User {


  //<editor-fold desc="Data Methods">
  final String id; // ID Firebase Auth
  final String email; // Email registrata
  final String? displayName; // Nome visualizzato (facoltativo)
  final String? photoUrl; // Avatar o foto profilo
  final DateTime createdAt; // Quando ha creato l’account

  // Statistiche o preferenze future
  final int? walletCount; // Quanti wallet ha creato
  final bool? darkMode; // Preferenza tema (se vuoi personalizzare)
  final String? locale; // Lingua selezionata (es. "it", "en")

 const  User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
     this.walletCount,
     this.darkMode,
    this.locale,
  });


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is User &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              email == other.email &&
              displayName == other.displayName &&
              photoUrl == other.photoUrl &&
              createdAt == other.createdAt &&
              walletCount == other.walletCount &&
              darkMode == other.darkMode &&
              locale == other.locale
          );


  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode ^
      createdAt.hashCode ^
      walletCount.hashCode ^
      darkMode.hashCode ^
      locale.hashCode;


  @override
  String toString() {
    return 'User{' +
        ' uid: $id,' +
        ' email: $email,' +
        ' displayName: $displayName,' +
        ' photoUrl: $photoUrl,' +
        ' createdAt: $createdAt,' +
        ' walletCount: $walletCount,' +
        ' darkMode: $darkMode,' +
        ' locale: $locale,' +
        '}';
  }


  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    int? walletCount,
    bool? darkMode,
    String? locale,
  }) {
    return User(
      id: uid ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      walletCount: walletCount ?? this.walletCount,
      darkMode: darkMode ?? this.darkMode,
      locale: locale ?? this.locale,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'uid': this.id,
      'email': this.email,
      'displayName': this.displayName,
      'photoUrl': this.photoUrl,
      'createdAt': this.createdAt,
      'walletCount': this.walletCount,
      'darkMode': this.darkMode,
      'locale': this.locale,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      photoUrl: map['photoUrl'] as String,
      createdAt: map['createdAt'] as DateTime,
      walletCount: map['walletCount'] as int,
      darkMode: map['darkMode'] as bool,
      locale: map['locale'] as String,
    );
  }


  //</editor-fold>


}