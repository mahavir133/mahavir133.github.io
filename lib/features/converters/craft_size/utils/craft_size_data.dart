class WireGaugeData {
  final int gauge; // AWG / SWG
  final double awgMm2;
  final double awgDiaMm;
  final double swgDiaMm;

  const WireGaugeData(this.gauge, this.awgDiaMm, this.awgMm2, this.swgDiaMm);

  static const List<WireGaugeData> sizes = [
    WireGaugeData(0, 8.252, 53.48, 8.230),
    WireGaugeData(1, 7.348, 42.41, 7.620),
    WireGaugeData(2, 6.544, 33.62, 7.010),
    WireGaugeData(4, 5.189, 21.15, 5.893),
    WireGaugeData(6, 4.115, 13.30, 4.877),
    WireGaugeData(8, 3.264, 8.37, 4.064),
    WireGaugeData(10, 2.588, 5.26, 3.251),
    WireGaugeData(12, 2.053, 3.31, 2.642),
    WireGaugeData(14, 1.628, 2.08, 2.032),
    WireGaugeData(16, 1.291, 1.31, 1.626),
    WireGaugeData(18, 1.024, 0.823, 1.219),
    WireGaugeData(20, 0.812, 0.518, 0.914),
    WireGaugeData(22, 0.644, 0.326, 0.711),
    WireGaugeData(24, 0.511, 0.205, 0.559),
    WireGaugeData(26, 0.405, 0.129, 0.457),
    WireGaugeData(28, 0.321, 0.081, 0.376),
    WireGaugeData(30, 0.255, 0.051, 0.315),
  ];
}

class KnittingNeedleData {
  final double metricMm;
  final String us;
  final String uk;

  const KnittingNeedleData(this.metricMm, this.us, this.uk);

  static const List<KnittingNeedleData> sizes = [
    KnittingNeedleData(2.0, '0', '14'),
    KnittingNeedleData(2.25, '1', '13'),
    KnittingNeedleData(2.75, '2', '12'),
    KnittingNeedleData(3.0, '2.5', '11'),
    KnittingNeedleData(3.25, '3', '10'),
    KnittingNeedleData(3.5, '4', '9'),
    KnittingNeedleData(3.75, '5', '9'),
    KnittingNeedleData(4.0, '6', '8'),
    KnittingNeedleData(4.5, '7', '7'),
    KnittingNeedleData(5.0, '8', '6'),
    KnittingNeedleData(5.5, '9', '5'),
    KnittingNeedleData(6.0, '10', '4'),
    KnittingNeedleData(6.5, '10.5', '3'),
    KnittingNeedleData(8.0, '11', '0'),
    KnittingNeedleData(9.0, '13', '00'),
    KnittingNeedleData(10.0, '15', '000'),
  ];
}

class CrochetHookData {
  final double metricMm;
  final String us;
  final String uk;

  const CrochetHookData(this.metricMm, this.us, this.uk);

  static const List<CrochetHookData> sizes = [
    CrochetHookData(2.0, '-', '14'),
    CrochetHookData(2.25, 'B/1', '13'),
    CrochetHookData(2.5, 'C/2', '12'),
    CrochetHookData(2.75, 'C', '12'),
    CrochetHookData(3.0, 'D/3', '11'),
    CrochetHookData(3.25, 'D', '10'),
    CrochetHookData(3.5, 'E/4', '9'),
    CrochetHookData(3.75, 'F/5', '9'),
    CrochetHookData(4.0, 'G/6', '8'),
    CrochetHookData(4.5, '7', '7'),
    CrochetHookData(5.0, 'H/8', '6'),
    CrochetHookData(5.5, 'I/9', '5'),
    CrochetHookData(6.0, 'J/10', '4'),
    CrochetHookData(6.5, 'K/10.5', '3'),
    CrochetHookData(8.0, 'L/11', '0'),
    CrochetHookData(9.0, 'M/13', '00'),
    CrochetHookData(10.0, 'N/15', '000'),
  ];
}
