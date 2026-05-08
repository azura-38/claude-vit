enum HungerStatus {
  ac('Aç'),
  tok('Tok'),
  farketmez('Farketmez');

  final String label;
  const HungerStatus(this.label);
}

enum Gender {
  male('Erkek'),
  female('Kadın');

  final String label;
  const Gender(this.label);
}

enum ImportanceLevel {
  low('Düşük'),
  medium('Orta'),
  high('Yüksek/Kritik');

  final String label;
  const ImportanceLevel(this.label);
}
