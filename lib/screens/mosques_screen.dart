import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class MosquesScreen extends StatelessWidget {
  const MosquesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Nearby Mosques'),
            actions: [
              IconButton(
                icon: const Icon(Icons.map_rounded, color: AppTheme.accentGold),
                tooltip: 'Open Google Maps Search',
                onPressed: () => provider.openLiveNearbyMosquesMap(),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppTheme.accentGold),
                tooltip: 'Refresh Location & Distance',
                onPressed: () => provider.loadMosques(),
              ),
            ],
          ),
          body: provider.isLoadingMosques && provider.mosques.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accentGold))
              : provider.mosqueError != null && provider.mosques.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
                            const SizedBox(height: 16),
                            Text(
                              provider.mosqueError!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppTheme.textLight),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => provider.loadMosques(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppTheme.accentGold,
                      onRefresh: () => provider.loadMosques(),
                      child: Column(
                        children: [
                          // Location Info Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            color: AppTheme.surfaceDark,
                            child: Row(
                              children: [
                                const Icon(Icons.location_on, color: AppTheme.accentGold, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Mosques sorted by distance from: ${provider.cityName}',
                                    style: const TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w500),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => provider.openLiveNearbyMosquesMap(),
                                  icon: const Icon(Icons.open_in_new_rounded, size: 14, color: AppTheme.accentGold),
                                  label: const Text('Live Maps', style: TextStyle(color: AppTheme.accentGold, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),

                          // Mosques List
                          Expanded(
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16.0),
                              itemCount: provider.mosques.length,
                              itemBuilder: (context, index) {
                                final mosque = provider.mosques[index];
                                final distanceText = mosque.distanceKm != null
                                    ? mosque.distanceKm! < 1.0
                                        ? '${(mosque.distanceKm! * 1000).toStringAsFixed(0)} m'
                                        : '${mosque.distanceKm!.toStringAsFixed(1)} km'
                                    : '-- km';

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceCard,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGreen,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppTheme.accentGold.withOpacity(0.4)),
                                      ),
                                      child: const Icon(Icons.mosque_rounded, color: AppTheme.accentGold, size: 24),
                                    ),
                                    title: Text(
                                      mosque.name,
                                      style: const TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 6),
                                        Text(
                                          mosque.address,
                                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Icon(Icons.near_me_rounded, color: AppTheme.accentGold, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              distanceText,
                                              style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w600, fontSize: 13),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.accentGold, size: 16),
                                    onTap: () {
                                      provider.openMosqueMap(mosque.latitude, mosque.longitude, mosque.name);
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }
}
