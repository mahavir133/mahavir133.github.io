class BraBandData {
  final String usUk;
  final String euJp;
  final String fr;
  final String au;

  const BraBandData(this.usUk, this.euJp, this.fr, this.au);

  static const List<BraBandData> bands = [
    BraBandData('28', '60', '75', '6'),
    BraBandData('30', '65', '80', '8'),
    BraBandData('32', '70', '85', '10'),
    BraBandData('34', '75', '90', '12'),
    BraBandData('36', '80', '95', '14'),
    BraBandData('38', '85', '100', '16'),
    BraBandData('40', '90', '105', '18'),
    BraBandData('42', '95', '110', '20'),
    BraBandData('44', '100', '115', '22'),
    BraBandData('46', '105', '120', '24'),
    BraBandData('48', '110', '125', '26'),
  ];
}

class BraCupData {
  final String us;
  final String uk;
  final String euFr;
  final String au;
  final String jp;

  const BraCupData(this.us, this.uk, this.euFr, this.au, this.jp);

  static const List<BraCupData> cups = [
    BraCupData('AA', 'AA', 'AA', 'AA', 'A'),
    BraCupData('A', 'A', 'A', 'A', 'B'),
    BraCupData('B', 'B', 'B', 'B', 'C'),
    BraCupData('C', 'C', 'C', 'C', 'D'),
    BraCupData('D', 'D', 'D', 'D', 'E'),
    BraCupData('DD', 'DD', 'E', 'DD', 'F'),
    BraCupData('DDD/E', 'E', 'F', 'E', 'G'),
    BraCupData('G', 'F', 'G', 'F', 'H'),
    BraCupData('H', 'FF', 'H', 'G', 'I'),
    BraCupData('I', 'G', 'I', 'H', 'J'),
    BraCupData('J', 'GG', 'J', 'I', 'K'),
  ];
}
