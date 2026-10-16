import 'package:adhan/adhan.dart';

class PrayerSettings {
  final CalculationMethod calculationMethod;
  final Madhab madhab;
  final String cityName;
  final double? latitude;
  final double? longitude;

  PrayerSettings({
    this.calculationMethod = CalculationMethod.karachi,
    this.madhab = Madhab.hanafi,
    this.cityName = 'Karachi',
    this.latitude,
    this.longitude,
  });

  PrayerSettings copyWith({
    CalculationMethod? calculationMethod,
    Madhab? madhab,
    String? cityName,
    double? latitude,
    double? longitude,
  }) {
    return PrayerSettings(
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      cityName: cityName ?? this.cityName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // Helper names for UI display
  static String getMethodName(CalculationMethod method) {
    switch (method) {
      case CalculationMethod.karachi:
        return 'University of Islamic Sciences, Karachi';
      case CalculationMethod.muslim_world_league:
        return 'Muslim World League (MWL)';
      case CalculationMethod.north_america:
        return 'ISNA (North America)';
      case CalculationMethod.egyptian:
        return 'Egyptian General Authority of Survey';
      case CalculationMethod.umm_al_qura:
        return 'Umm al-Qura University, Makkah';
      case CalculationMethod.dubai:
        return 'Dubai';
      case CalculationMethod.qatar:
        return 'Qatar';
      case CalculationMethod.kuwait:
        return 'Kuwait';
      case CalculationMethod.singapore:
        return 'Singapore';
      default:
        return 'Karachi';
    }
  }

  static String getMadhabName(Madhab madhab) {
    switch (madhab) {
      case Madhab.hanafi:
        return 'Hanafi';
      case Madhab.shafi:
        return 'Shafi / Maliki / Hanbali';
    }
  }
}
