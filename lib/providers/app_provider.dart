import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../models/mosque_model.dart';
import '../models/prayer_settings.dart';
import '../models/tasbih_state.dart';
import '../services/location_service.dart';
import '../services/prayer_service.dart';
import '../services/mosque_service.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final PrayerService _prayerService = PrayerService();
  final MosqueService _mosqueService = MosqueService();
  final StorageService _storageService = StorageService();

  // Loading & Error States
  bool isLoadingLocation = false;
  String? locationError;
  double? latitude;
  double? longitude;
  String cityName = 'Karachi';

  // Prayer Times
  PrayerTimesData? prayerTimesData;
  PrayerSettings prayerSettings = PrayerSettings();
  Timer? _countdownTimer;

  // Tasbih
  TasbihState tasbihState = TasbihState(count: 0, target: 33, themeIndex: 0);

  // Qibla
  int qiblaThemeIndex = 0;

  // Mosques
  List<MosqueModel> mosques = [];
  bool isLoadingMosques = false;
  String? mosqueError;

  AppProvider() {
    _initApp();
  }

  Future<void> _initApp() async {
    await loadPersistedData();
    await refreshLocationAndData();
    _startCountdownTimer();
  }

  Future<void> loadPersistedData() async {
    // Tasbih
    final tasbihData = await _storageService.loadTasbih();
    tasbihState = TasbihState(
      count: tasbihData['count']!,
      target: tasbihData['target']!,
      themeIndex: tasbihData['themeIndex']!,
    );

    // Qibla Theme
    qiblaThemeIndex = await _storageService.loadQiblaTheme();

    // Prayer Settings
    final pSettings = await _storageService.loadPrayerSettings();
    final methods = CalculationMethod.values;
    final madhabs = Madhab.values;
    
    CalculationMethod method = methods[pSettings['methodIndex']! < methods.length ? pSettings['methodIndex']! : 0];
    Madhab madhab = madhabs[pSettings['madhabIndex']! < madhabs.length ? pSettings['madhabIndex']! : 0];

    prayerSettings = prayerSettings.copyWith(
      calculationMethod: method,
      madhab: madhab,
    );
    notifyListeners();
  }

  Future<void> refreshLocationAndData() async {
    isLoadingLocation = true;
    locationError = null;
    notifyListeners();

    try {
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        throw Exception('Location permission denied.');
      }

      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        latitude = position.latitude;
        longitude = position.longitude;
        cityName = await _locationService.getCityName(latitude!, longitude!);

        prayerSettings = prayerSettings.copyWith(
          latitude: latitude,
          longitude: longitude,
          cityName: cityName,
        );

        calculatePrayerTimes();
        await loadMosques();
      }
    } catch (e) {
      locationError = e.toString().replaceAll('Exception: ', '');
      // Fallback to default Karachi coordinates if permission or GPS fails
      latitude = 24.8607;
      longitude = 67.0011;
      cityName = 'Karachi (Default)';
      calculatePrayerTimes();
      await loadMosques();
    } finally {
      isLoadingLocation = false;
      notifyListeners();
    }
  }

  void calculatePrayerTimes() {
    if (latitude == null || longitude == null) return;
    prayerTimesData = _prayerService.calculatePrayerTimes(
      latitude: latitude!,
      longitude: longitude!,
      method: prayerSettings.calculationMethod,
      madhab: prayerSettings.madhab,
    );
    notifyListeners();
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (prayerTimesData != null && latitude != null && longitude != null) {
        // Re-calculate countdown or update prayer times if midnight passed
        calculatePrayerTimes();
      }
    });
  }

  // Prayer Settings update
  Future<void> updatePrayerSettings(CalculationMethod method, Madhab madhab) async {
    prayerSettings = prayerSettings.copyWith(
      calculationMethod: method,
      madhab: madhab,
    );
    await _storageService.savePrayerSettings(
      CalculationMethod.values.indexOf(method),
      Madhab.values.indexOf(madhab),
    );
    calculatePrayerTimes();
    notifyListeners();
  }

  // Tasbih actions
  void incrementTasbih() {
    int newCount = tasbihState.count + 1;
    tasbihState = tasbihState.copyWith(count: newCount);
    _storageService.saveTasbih(tasbihState.count, tasbihState.target, tasbihState.themeIndex);
    notifyListeners();
  }

  void decrementTasbih() {
    if (tasbihState.count > 0) {
      int newCount = tasbihState.count - 1;
      tasbihState = tasbihState.copyWith(count: newCount);
      _storageService.saveTasbih(tasbihState.count, tasbihState.target, tasbihState.themeIndex);
      notifyListeners();
    }
  }

  void resetTasbih() {
    tasbihState = tasbihState.copyWith(count: 0);
    _storageService.saveTasbih(tasbihState.count, tasbihState.target, tasbihState.themeIndex);
    notifyListeners();
  }

  void setTasbihTarget(int target) {
    tasbihState = tasbihState.copyWith(target: target);
    _storageService.saveTasbih(tasbihState.count, tasbihState.target, tasbihState.themeIndex);
    notifyListeners();
  }

  void setTasbihTheme(int themeIndex) {
    tasbihState = tasbihState.copyWith(themeIndex: themeIndex);
    _storageService.saveTasbih(tasbihState.count, tasbihState.target, tasbihState.themeIndex);
    notifyListeners();
  }

  // Qibla theme action
  Future<void> setQiblaTheme(int themeIndex) async {
    qiblaThemeIndex = themeIndex;
    await _storageService.saveQiblaTheme(themeIndex);
    notifyListeners();
  }

  // Mosques loading
  Future<void> loadMosques() async {
    if (latitude == null || longitude == null) {
      await refreshLocationAndData();
      if (latitude == null || longitude == null) return;
    }
    isLoadingMosques = true;
    mosqueError = null;
    notifyListeners();

    try {
      mosques = await _mosqueService.loadMosques(latitude!, longitude!);
    } catch (e) {
      mosqueError = e.toString();
    } finally {
      isLoadingMosques = false;
      notifyListeners();
    }
  }

  Future<void> openMosqueMap(double lat, double lon, String name) async {
    await _mosqueService.openMap(lat, lon, name);
  }

  Future<void> openLiveNearbyMosquesMap() async {
    if (latitude != null && longitude != null) {
      await _mosqueService.openLiveNearbyMosquesMap(latitude!, longitude!);
    }
  }

  double getQiblaBearing() {
    if (latitude == null || longitude == null) return 0.0;
    return _locationService.calculateQiblaBearing(latitude!, longitude!);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}
