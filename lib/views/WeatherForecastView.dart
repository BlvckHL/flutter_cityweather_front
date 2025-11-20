import 'package:flutter/material.dart';
import 'package:flutter_cityweather_front/services/ApiResponse.dart';
import 'package:flutter_cityweather_front/services/DataConverter.dart';
import 'package:flutter_cityweather_front/services/GroupedWeather.dart';

class WeatherForecastView extends StatelessWidget {
  final ApiResponse forecast;

  const WeatherForecastView({super.key, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final converter = DataConverter();
    final summaries = converter.byDay(forecast);
    final description =
        converter.descriptionFromWeatherCode(forecast.current.weatherCode);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CurrentWeatherCard(
            current: forecast.current,
            description: description,
          ),
          const SizedBox(height: 16),
          _DailyForecastList(
            summaries: summaries,
            converter: converter,
          ),
        ],
      ),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  final CurrentWeather current;
  final String description;

  const _CurrentWeatherCard({
    required this.current,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _iconForCode(current.weatherCode),
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${current.temperature.toStringAsFixed(1)}°C",
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      description,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoChip(
                  icon: Icons.air,
                  label: "Vent",
                  value: "${current.windSpeed.toStringAsFixed(1)} km/h",
                ),
                _InfoChip(
                  icon: Icons.schedule,
                  label: "Mis à jour",
                  value:
                      "${current.time.hour.toString().padLeft(2, '0')}h${current.time.minute.toString().padLeft(2, '0')}",
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
        Text(
          value,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _DailyForecastList extends StatelessWidget {
  final List<GroupedWeather> summaries;
  final DataConverter converter;

  const _DailyForecastList({
    required this.summaries,
    required this.converter,
  });

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return const Text("Prévisions indisponibles pour les prochains jours.");
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Prévisions à 7 jours",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: summaries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final summary = summaries[index];
            final description =
                converter.descriptionFromWeatherCode(summary.weatherCode);
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  _iconForCode(summary.weatherCode),
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
                title: Text(summary.dayLabel),
                subtitle: Text(
                  "$description\n${summary.minAndMax()}",
                ),
                isThreeLine: true,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.water_drop, size: 16),
                    Text("${summary.precipitation.toStringAsFixed(1)} mm"),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

IconData _iconForCode(int code) {
  if (code == 0) return Icons.wb_sunny;
  if (code == 1 || code == 2) return Icons.wb_cloudy;
  if (code == 3) return Icons.cloud;
  if (code == 45 || code == 48) return Icons.blur_on;
  if (code == 51 || code == 53 || code == 55) return Icons.grain;
  if (code == 61 || code == 63 || code == 65) return Icons.umbrella;
  if (code == 66 || code == 67) return Icons.ac_unit;
  if (code == 71 || code == 73 || code == 75 || code == 77) {
    return Icons.ac_unit;
  }
  if (code == 80 || code == 81 || code == 82) return Icons.thunderstorm;
  if (code == 85 || code == 86) return Icons.ac_unit;
  if (code == 95 || code == 96 || code == 99) return Icons.flash_on;
  return Icons.help_outline;
}

