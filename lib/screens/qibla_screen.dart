import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  bool _hasHapticked = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final double qiblaBearing = provider.getQiblaBearing();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Qibla Direction'),
            actions: [
              PopupMenuButton<int>(
                icon: const Icon(Icons.palette_rounded, color: AppTheme.accentGold),
                onSelected: (themeIndex) {
                  provider.setQiblaTheme(themeIndex);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0, child: Text('Classic Dial')),
                  const PopupMenuItem(value: 1, child: Text('Minimal Modern')),
                  const PopupMenuItem(value: 2, child: Text('Kaaba Arrow')),
                ],
              ),
            ],
          ),
          body: StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
                        const SizedBox(height: 16),
                        Text(
                          'Compass error: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppTheme.textLight),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.accentGold),
                );
              }

              final double? heading = snapshot.data?.heading;

              if (heading == null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.compass_calibration, size: 64, color: AppTheme.accentGold),
                        const SizedBox(height: 16),
                        const Text(
                          'No compass sensor detected or calibration required.\nPlease move your phone in a figure-8 motion to calibrate.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textLight, fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => provider.refreshLocationAndData(),
                          child: const Text('Retry Location'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Calculate needle angle
              // direction = qiblaBearing - heading
              double direction = qiblaBearing - heading;
              double normalizedDirection = (direction + 360) % 360;

              // Check if pointing correctly toward Qibla (within +/- 3 degrees)
              bool isAligned = normalizedDirection <= 3 || normalizedDirection >= 357;
              if (isAligned && !_hasHapticked) {
                HapticFeedback.heavyImpact();
                _hasHapticked = true;
              } else if (!isAligned) {
                _hasHapticked = false;
              }

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Status / Calibration Hint
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isAligned ? Colors.green.withOpacity(0.2) : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isAligned ? Colors.green : AppTheme.accentGold.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isAligned ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                              color: isAligned ? Colors.green : AppTheme.accentGold,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isAligned
                                  ? 'Facing Qibla Successfully!'
                                  : 'Rotate phone until needle points to top',
                              style: TextStyle(
                                color: isAligned ? Colors.greenAccent : AppTheme.textLight,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Compass UI based on selected theme
                      Center(
                        child: _buildCompassWidget(
                          themeIndex: provider.qiblaThemeIndex,
                          heading: heading,
                          qiblaBearing: qiblaBearing,
                          direction: direction,
                          isAligned: isAligned,
                        ),
                      ),

                      const Spacer(),

                      // Details Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoColumn('Qibla Angle', '${qiblaBearing.toStringAsFixed(1)}°'),
                            Container(width: 1, height: 30, color: AppTheme.textMuted.withOpacity(0.3)),
                            _buildInfoColumn('Phone Heading', '${heading.toStringAsFixed(1)}°'),
                            Container(width: 1, height: 30, color: AppTheme.textMuted.withOpacity(0.3)),
                            _buildInfoColumn('City', provider.cityName),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Tip: Move phone in a figure-8 motion if compass is erratic.',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppTheme.accentGold, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCompassWidget({
    required int themeIndex,
    required double heading,
    required double qiblaBearing,
    required double direction,
    required bool isAligned,
  }) {
    switch (themeIndex) {
      case 1:
        // Minimal Modern
        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.surfaceCard,
                  border: Border.all(color: isAligned ? Colors.green : AppTheme.accentGold, width: 3),
                ),
              ),
              Transform.rotate(
                angle: (direction * (math.pi / 180)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.navigation_rounded, size: 64, color: isAligned ? Colors.greenAccent : AppTheme.accentGold),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
              const Center(
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.primaryGreen,
                  child: Icon(Icons.mosque, color: AppTheme.accentGold, size: 20),
                ),
              ),
            ],
          ),
        );
      case 2:
        // Kaaba Arrow
        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [AppTheme.surfaceCard, AppTheme.backgroundDark],
                  ),
                  border: Border.all(color: AppTheme.accentGold, width: 2),
                ),
              ),
              Transform.rotate(
                angle: (direction * (math.pi / 180)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isAligned ? Colors.green : AppTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star, color: Colors.black, size: 28),
                    ),
                    const SizedBox(height: 130),
                  ],
                ),
              ),
              const Center(
                child: Text(
                  '🕋',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ],
          ),
        );
      case 0:
      default:
        // Classic Dial
        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.rotate(
                angle: (-heading * (math.pi / 180)),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.surfaceCard,
                    border: Border.all(color: AppTheme.accentGold.withOpacity(0.5), width: 4),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Positioned(top: 10, child: Text('N', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
                      const Positioned(bottom: 10, child: Text('S', style: TextStyle(color: AppTheme.textMuted))),
                      const Positioned(left: 10, child: Text('W', style: TextStyle(color: AppTheme.textMuted))),
                      const Positioned(right: 10, child: Text('E', style: TextStyle(color: AppTheme.textMuted))),
                    ],
                  ),
                ),
              ),
              Transform.rotate(
                angle: (direction * (math.pi / 180)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_drop_up_rounded,
                      size: 90,
                      color: isAligned ? Colors.greenAccent : AppTheme.accentGold,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.accentGold),
                  ),
                  child: const Center(
                    child: Icon(Icons.navigation, color: AppTheme.accentGold, size: 20),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
