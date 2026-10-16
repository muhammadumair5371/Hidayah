import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final state = provider.tasbihState;
        final bool isCompleted = state.count >= state.target;

        if (isCompleted && state.count == state.target) {
          // Stronger vibration on target reached
          HapticFeedback.vibrate();
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Digital Tasbih'),
            actions: [
              PopupMenuButton<int>(
                icon: const Icon(Icons.palette_rounded, color: AppTheme.accentGold),
                onSelected: (themeIndex) {
                  provider.setTasbihTheme(themeIndex);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 0, child: Text('Classic Beads')),
                  const PopupMenuItem(value: 1, child: Text('Simple Circle')),
                  const PopupMenuItem(value: 2, child: Text('Modern Minimal')),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentGold),
                onPressed: () => provider.resetTasbih(),
                tooltip: 'Reset Count',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Target & Presets Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target: ${state.target}',
                      style: const TextStyle(color: AppTheme.accentGold, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        _buildTargetChip(context, provider, 33),
                        const SizedBox(width: 6),
                        _buildTargetChip(context, provider, 99),
                        const SizedBox(width: 6),
                        _buildTargetChip(context, provider, 100),
                        const SizedBox(width: 6),
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.accentGold, size: 20),
                          onPressed: () => _showCustomTargetDialog(context, provider),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: state.target > 0 ? (state.count / state.target).clamp(0.0, 1.0) : 0.0,
                    backgroundColor: AppTheme.surfaceDark,
                    valueColor: AlwaysStoppedAnimation<Color>(isCompleted ? Colors.greenAccent : AppTheme.accentGold),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${state.count} / ${state.target}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ),

                const Spacer(),

                // Central Interactive Tap Area based on theme
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    provider.incrementTasbih();
                  },
                  child: _buildTasbihThemeWidget(state.themeIndex, state.count, state.target, isCompleted),
                ),

                const Spacer(),

                // Action Controls (Decrease & Reset)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textLight,
                        side: BorderSide(color: AppTheme.textMuted.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        provider.decrementTasbih();
                      },
                      icon: const Icon(Icons.remove, size: 18),
                      label: const Text('Minus 1'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.surfaceCard,
                        foregroundColor: AppTheme.accentGold,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: AppTheme.accentGold.withOpacity(0.3)),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        provider.resetTasbih();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tap anywhere on the circle to count',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTargetChip(BuildContext context, AppProvider provider, int targetValue) {
    bool isSelected = provider.tasbihState.target == targetValue;
    return InkWell(
      onTap: () => provider.setTasbihTarget(targetValue),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGold : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
        ),
        child: Text(
          '$targetValue',
          style: TextStyle(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.textLight,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTasbihThemeWidget(int themeIndex, int count, int target, bool isCompleted) {
    switch (themeIndex) {
      case 1:
        // Simple Circle Counter
        return Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surfaceCard,
            border: Border.all(
              color: isCompleted ? Colors.greenAccent : AppTheme.accentGold,
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: (isCompleted ? Colors.greenAccent : AppTheme.accentGold).withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.touch_app_rounded, color: AppTheme.accentGold, size: 36),
              const SizedBox(height: 12),
              Text(
                '$count',
                style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: AppTheme.textLight),
              ),
              if (isCompleted)
                const Text('Target Reached! 🎉', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        );
      case 2:
        // Modern Minimal
        return Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            gradient: LinearGradient(
              colors: [AppTheme.secondaryGreen, AppTheme.surfaceDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: AppTheme.accentGold.withOpacity(0.4), width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$count',
                style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w300, color: AppTheme.accentGold),
              ),
              const SizedBox(height: 8),
              Text(
                isCompleted ? 'COMPLETED' : 'TAP TO COUNT',
                style: TextStyle(color: isCompleted ? Colors.greenAccent : AppTheme.textMuted, fontSize: 12, letterSpacing: 2),
              ),
            ],
          ),
        );
      case 0:
      default:
        // Classic Beads Ring
        return Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.surfaceDark,
            border: Border.all(color: AppTheme.accentGold, width: 6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Decorative bead ring simulation
              for (int i = 0; i < 12; i++)
                Transform.rotate(
                  angle: i * (3.14159 / 6),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.radio_button_checked, color: AppTheme.accentGold, size: 28),
                  const SizedBox(height: 4),
                  Text(
                    '$count',
                    style: const TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                  ),
                  Text(
                    isCompleted ? '✓ Done' : 'Tap here',
                    style: TextStyle(color: isCompleted ? Colors.greenAccent : AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        );
    }
  }

  void _showCustomTargetDialog(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(text: provider.tasbihState.target.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: const Text('Set Custom Target', style: TextStyle(color: AppTheme.textLight)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.textLight),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.surfaceCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Set'),
              onPressed: () {
                final val = int.tryParse(controller.text);
                if (val != null && val > 0) {
                  provider.setTasbihTarget(val);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }
}
