class HeartRateZone {
  final String name;
  final int minHr;
  final int maxHr;
  final String description;

  HeartRateZone(this.name, this.minHr, this.maxHr, this.description);
}

class HeartRateResult {
  final int maxHr;
  final List<HeartRateZone> zones;

  HeartRateResult(this.maxHr, this.zones);
}

class HeartRateCalculator {
  static HeartRateResult calculateZones({
    required int age,
    int? restingHr,
  }) {
    if (age <= 0 || age > 120) throw Exception("Invalid age");
    
    // Tanaka formula is more accurate than 220-age
    int maxHr = (208 - 0.7 * age).round();
    
    List<HeartRateZone> zones = [];
    
    if (restingHr != null && restingHr > 0) {
      // Karvonen Method
      int hrr = maxHr - restingHr; // Heart Rate Reserve
      int getKarvonen(double intensity) => (hrr * intensity + restingHr).round();
      
      zones.add(HeartRateZone("Zone 1 (Recovery)", getKarvonen(0.50), getKarvonen(0.60), "Very light, helps recovery."));
      zones.add(HeartRateZone("Zone 2 (Endurance)", getKarvonen(0.60), getKarvonen(0.70), "Light, builds aerobic endurance."));
      zones.add(HeartRateZone("Zone 3 (Aerobic)", getKarvonen(0.70), getKarvonen(0.80), "Moderate, improves aerobic capacity."));
      zones.add(HeartRateZone("Zone 4 (Threshold)", getKarvonen(0.80), getKarvonen(0.90), "Hard, raises anaerobic threshold."));
      zones.add(HeartRateZone("Zone 5 (Maximum)", getKarvonen(0.90), getKarvonen(1.00), "Maximum effort, peak performance."));
    } else {
      // Standard Method (% of Max HR)
      int getStandard(double intensity) => (maxHr * intensity).round();
      
      zones.add(HeartRateZone("Zone 1 (Recovery)", getStandard(0.50), getStandard(0.60), "Very light, helps recovery."));
      zones.add(HeartRateZone("Zone 2 (Endurance)", getStandard(0.60), getStandard(0.70), "Light, builds aerobic endurance."));
      zones.add(HeartRateZone("Zone 3 (Aerobic)", getStandard(0.70), getStandard(0.80), "Moderate, improves aerobic capacity."));
      zones.add(HeartRateZone("Zone 4 (Threshold)", getStandard(0.80), getStandard(0.90), "Hard, raises anaerobic threshold."));
      zones.add(HeartRateZone("Zone 5 (Maximum)", getStandard(0.90), getStandard(1.00), "Maximum effort, peak performance."));
    }

    return HeartRateResult(maxHr, zones);
  }
}
