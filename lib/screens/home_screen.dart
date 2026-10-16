import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:adhan/adhan.dart';
import '../providers/app_provider.dart';
import '../models/prayer_settings.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final prayerData = provider.prayerTimesData;
        final now = DateTime.now();
        final formattedDate = DateFormat('EEEE, dd MMMM yyyy').format(now);

        return Scaffold(
          appBar: AppBar(
            title: InkWell(
              onTap: () => provider.refreshLocationAndData(),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.my_location_rounded, color: AppTheme.accentGold, size: 20),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        provider.cityName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: AppTheme.accentGold),
                onPressed: () => _showSettingsDialog(context, provider),
                tooltip: 'Settings',
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentGold),
                onPressed: () => provider.refreshLocationAndData(),
                tooltip: 'Detect Location',
              ),
            ],
          ),
          body: provider.isLoadingLocation && prayerData == null
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
              : RefreshIndicator(
                  color: AppTheme.accentGold,
                  onRefresh: () => provider.refreshLocationAndData(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // GPS Error / Detection Banner if permission or GPS is off
                        if (provider.locationError != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.location_off_rounded, color: AppTheme.accentGold, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Using Default Location',
                                        style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      Text(
                                        provider.locationError!,
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => provider.refreshLocationAndData(),
                                  child: const Text('Detect', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),

                        // Date info
                        Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 16),

                        // Top Prayer Card (Current & Next Prayer with Live Countdown)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.secondaryGreen, AppTheme.primaryGreen],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(color: AppTheme.accentGold.withOpacity(0.3), width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGold.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Current: ${prayerData?.currentPrayerName ?? "N/A"}',
                                      style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                  const Icon(Icons.mosque, color: AppTheme.accentGold, size: 28),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Next Prayer',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 14, letterSpacing: 1.2),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                prayerData?.nextPrayerName ?? 'Loading...',
                                style: const TextStyle(color: AppTheme.textLight, fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                prayerData != null ? DateFormat('hh:mm a').format(prayerData.nextPrayerTime) : '--:--',
                                style: const TextStyle(color: AppTheme.accentGold, fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 16),
                              if (prayerData != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.timer_outlined, color: AppTheme.accentGold, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Time left: ${_formatDuration(prayerData.timeUntilNext)}',
                                        style: const TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.w500, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        Text(
                          "Today's Prayer Times",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),

                        // Prayer Times List
                        if (prayerData != null) ...[
                          _buildPrayerRow(context, 'Fajr', prayerData.fajr, prayerData.nextPrayerName == 'Fajr'),
                          _buildPrayerRow(context, 'Sunrise', prayerData.sunrise, false, isExtra: true),
                          _buildPrayerRow(context, 'Dhuhr', prayerData.dhuhr, prayerData.nextPrayerName == 'Dhuhr'),
                          _buildPrayerRow(context, 'Asr', prayerData.asr, prayerData.nextPrayerName == 'Asr'),
                          _buildPrayerRow(context, 'Maghrib', prayerData.maghrib, prayerData.nextPrayerName == 'Maghrib'),
                          _buildPrayerRow(context, 'Isha', prayerData.isha, prayerData.nextPrayerName == 'Isha'),
                        ] else
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('Unable to calculate prayer times. Check location settings.'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _buildPrayerRow(BuildContext context, String name, DateTime time, bool isNext, {bool isExtra = false}) {
    final timeStr = DateFormat('hh:mm a').format(time);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isNext ? AppTheme.surfaceCard : AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: isNext ? Border.all(color: AppTheme.accentGold, width: 1.5) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isExtra ? Icons.wb_twilight_rounded : Icons.access_time_rounded,
                color: isNext ? AppTheme.accentGold : AppTheme.textMuted,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                  color: isNext ? AppTheme.accentGold : AppTheme.textLight,
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (isNext)
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('Next', style: TextStyle(color: AppTheme.accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              Text(
                timeStr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                  color: isNext ? AppTheme.accentGold : AppTheme.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _showSettingsDialog(BuildContext context, AppProvider provider) {
    CalculationMethod selectedMethod = provider.prayerSettings.calculationMethod;
    Madhab selectedMadhab = provider.prayerSettings.madhab;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.surfaceDark,
              title: const Text('Prayer Settings', style: TextStyle(color: AppTheme.textLight)),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Calculation Method', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<CalculationMethod>(
                      value: selectedMethod,
                      dropdownColor: AppTheme.surfaceCard,
                      style: const TextStyle(color: AppTheme.textLight),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceCard,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: CalculationMethod.values.map((method) {
                        return DropdownMenuItem(
                          value: method,
                          child: Text(PrayerSettings.getMethodName(method), style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedMethod = val);
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text('Asr Madhab', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<Madhab>(
                      value: selectedMadhab,
                      dropdownColor: AppTheme.surfaceCard,
                      style: const TextStyle(color: AppTheme.textLight),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceCard,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      items: Madhab.values.map((madhab) {
                        return DropdownMenuItem(
                          value: madhab,
                          child: Text(PrayerSettings.getMadhabName(madhab), style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedMadhab = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
                  onPressed: () => Navigator.pop(context),
                ),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () {
                    provider.updatePrayerSettings(selectedMethod, selectedMadhab);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
