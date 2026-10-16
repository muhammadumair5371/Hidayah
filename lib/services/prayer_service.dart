import 'package:adhan/adhan.dart';
import 'package:intl/intl.dart';

class PrayerTimesData {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String currentPrayerName;
  final String nextPrayerName;
  final DateTime nextPrayerTime;
  final Duration timeUntilNext;

  PrayerTimesData({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.currentPrayerName,
    required this.nextPrayerName,
    required this.nextPrayerTime,
    required this.timeUntilNext,
  });
}

class PrayerService {
  PrayerTimesData calculatePrayerTimes({
    required double latitude,
    required double longitude,
    CalculationMethod method = CalculationMethod.karachi,
    Madhab madhab = Madhab.hanafi,
    DateTime? date,
  }) {
    final targetDate = date ?? DateTime.now();
    final myCoordinates = Coordinates(latitude, longitude);
    
    // Set parameters
    CalculationParameters params = method.getParameters();
    params.madhab = madhab;

    // Calculate prayer times for today
    final prayerTimes = PrayerTimes(myCoordinates, DateComponents.from(targetDate), params);
    
    // Also calculate for tomorrow in case next prayer rolls over to tomorrow (e.g. after Isha)
    final tomorrowDate = targetDate.add(const Duration(days: 1));
    final tomorrowPrayerTimes = PrayerTimes(myCoordinates, DateComponents.from(tomorrowDate), params);

    final now = DateTime.now();

    String currentName = 'Isha';
    String nextName = 'Fajr';
    DateTime nextTime = tomorrowPrayerTimes.fajr;

    // Determine current and next prayer among main prayers
    final mainPrayers = [
      {'name': 'Fajr', 'time': prayerTimes.fajr},
      {'name': 'Dhuhr', 'time': prayerTimes.dhuhr},
      {'name': 'Asr', 'time': prayerTimes.asr},
      {'name': 'Maghrib', 'time': prayerTimes.maghrib},
      {'name': 'Isha', 'time': prayerTimes.isha},
    ];

    for (int i = 0; i < mainPrayers.length; i++) {
      final pTime = mainPrayers[i]['time'] as DateTime;
      if (now.isBefore(pTime)) {
        nextName = mainPrayers[i]['name'] as String;
        nextTime = pTime;
        // Current is previous
        currentName = i == 0 ? 'Isha (Yesterday)' : (mainPrayers[i - 1]['name'] as String);
        break;
      } else {
        if (i == mainPrayers.length - 1) {
          // After Isha today, next is tomorrow Fajr
          currentName = 'Isha';
          nextName = 'Fajr';
          nextTime = tomorrowPrayerTimes.fajr;
        } else {
          currentName = mainPrayers[i]['name'] as String;
        }
      }
    }

    final timeUntil = nextTime.difference(now);

    return PrayerTimesData(
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      asr: prayerTimes.asr,
      maghrib: prayerTimes.maghrib,
      isha: prayerTimes.isha,
      currentPrayerName: currentName,
      nextPrayerName: nextName,
      nextPrayerTime: nextTime,
      timeUntilNext: timeUntil.isNegative ? Duration.zero : timeUntil,
    );
  }

  String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }
}
