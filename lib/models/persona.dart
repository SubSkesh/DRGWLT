class Buyer {
  // 🔐 Proprietà private
  String _idBuyer;
  String _nome;
  // String _email;
  // String _telefono;
  // String _indirizzo;
  double _totaleSpeso;
  DateTime _ultimoOrdine;
  // bool _isPremium;

  // 🧱 Costruttore
  Buyer({
    required String idBuyer,
    required String nome,
    double totaleSpeso = 0.0,
    DateTime? ultimoOrdine,
    ,
  })  : _idBuyer = idBuyer,
        _nome = nome,
        _email = email,
        _telefono = telefono,
        _indirizzo = indirizzo,
        _totaleSpeso = totaleSpeso,
        _ultimoOrdine = ultimoOrdine ?? DateTime.now(),
        _isPremium = isPremium;

  // 📥 Setter
  set nome(String value) => _nome = value;
  set email(String value) => _email = value;
  set telefono(String value) => _telefono = value;
  set indirizzo(String value) => _indirizzo = value;
  set isPremium(bool value) => _isPremium = value;

  // 📤 Getter
  String get idBuyer => _idBuyer;
  String get nome => _nome;
  String get email => _email;
  String get telefono => _telefono;
  String get indirizzo => _indirizzo;
  double get totaleSpeso => _totaleSpeso;
  DateTime get ultimoOrdine => _ultimoOrdine;
  bool get isPremium => _isPremium;

  // 📈 Metodo per aggiornare spesa
  void aggiornaSpesa(double importo) {
    if (importo > 0) {
      _totaleSpeso += importo;
      _ultimoOrdine = DateTime.now();
    }
  }

  // 🧾 Stampa dettagli buyer
  void stampaDettagli() {
    print('👤 Buyer: $_nome ($_idBuyer)');
    print('📧 Email: $_email');
    print('📞 Telefono: $_telefono');
    print('🏠 Indirizzo: $_indirizzo');
    print('💰 Totale speso: €$_totaleSpeso');
    print('📅 Ultimo ordine: $_ultimoOrdine');
    print('⭐ Premium: $_isPremium');
  }
}