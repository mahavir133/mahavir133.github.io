class ClothingSizeData {
  final String category;
  final String intl; // XS, S, M, L, XL...
  final String us;
  final String uk;
  final String eu;
  final String jp;
  final String kr;
  final String au;

  const ClothingSizeData({
    required this.category,
    required this.intl,
    required this.us,
    required this.uk,
    required this.eu,
    required this.jp,
    required this.kr,
    required this.au,
  });

  static const List<ClothingSizeData> sizes = [
    // Tops
    ClothingSizeData(
      category: 'Tops',
      intl: 'XS',
      us: '2/4',
      uk: '6/8',
      eu: '34/36',
      jp: '7',
      kr: '44',
      au: '6/8',
    ),
    ClothingSizeData(
      category: 'Tops',
      intl: 'S',
      us: '6/8',
      uk: '10/12',
      eu: '38/40',
      jp: '9',
      kr: '55',
      au: '10/12',
    ),
    ClothingSizeData(
      category: 'Tops',
      intl: 'M',
      us: '10/12',
      uk: '14/16',
      eu: '42/44',
      jp: '11',
      kr: '66',
      au: '14/16',
    ),
    ClothingSizeData(
      category: 'Tops',
      intl: 'L',
      us: '14/16',
      uk: '18/20',
      eu: '46/48',
      jp: '13',
      kr: '77',
      au: '18/20',
    ),
    ClothingSizeData(
      category: 'Tops',
      intl: 'XL',
      us: '18/20',
      uk: '22/24',
      eu: '50/52',
      jp: '15',
      kr: '88',
      au: '22/24',
    ),
    ClothingSizeData(
      category: 'Tops',
      intl: 'XXL',
      us: '22/24',
      uk: '26/28',
      eu: '54/56',
      jp: '17',
      kr: '99',
      au: '26/28',
    ),

    // Bottoms (Women's)
    ClothingSizeData(
      category: 'Bottoms',
      intl: 'XS',
      us: '2',
      uk: '6',
      eu: '34',
      jp: '5',
      kr: '44',
      au: '6',
    ),
    ClothingSizeData(
      category: 'Bottoms',
      intl: 'S',
      us: '4/6',
      uk: '8/10',
      eu: '36/38',
      jp: '7/9',
      kr: '55',
      au: '8/10',
    ),
    ClothingSizeData(
      category: 'Bottoms',
      intl: 'M',
      us: '8/10',
      uk: '12/14',
      eu: '40/42',
      jp: '11/13',
      kr: '66',
      au: '12/14',
    ),
    ClothingSizeData(
      category: 'Bottoms',
      intl: 'L',
      us: '12/14',
      uk: '16/18',
      eu: '44/46',
      jp: '15/17',
      kr: '77',
      au: '16/18',
    ),
    ClothingSizeData(
      category: 'Bottoms',
      intl: 'XL',
      us: '16',
      uk: '20',
      eu: '48',
      jp: '19',
      kr: '88',
      au: '20',
    ),

    // Dresses
    ClothingSizeData(
      category: 'Dresses',
      intl: 'XS',
      us: '2',
      uk: '6',
      eu: '34',
      jp: '5',
      kr: '44',
      au: '6',
    ),
    ClothingSizeData(
      category: 'Dresses',
      intl: 'S',
      us: '4',
      uk: '8',
      eu: '36',
      jp: '7',
      kr: '55',
      au: '8',
    ),
    ClothingSizeData(
      category: 'Dresses',
      intl: 'M',
      us: '8',
      uk: '12',
      eu: '40',
      jp: '11',
      kr: '66',
      au: '12',
    ),
    ClothingSizeData(
      category: 'Dresses',
      intl: 'L',
      us: '12',
      uk: '16',
      eu: '44',
      jp: '15',
      kr: '77',
      au: '16',
    ),
    ClothingSizeData(
      category: 'Dresses',
      intl: 'XL',
      us: '16',
      uk: '20',
      eu: '48',
      jp: '19',
      kr: '88',
      au: '20',
    ),
  ];
}
