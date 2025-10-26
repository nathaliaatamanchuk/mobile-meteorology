import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/app_shell.dart';
import '../models/station.dart';
import '../services/station_service.dart';

class StationData {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final double pressure;
  final double rain;
  final double luminosity;
  final Map<String, List<FlSpot>> history;

  const StationData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.rain,
    required this.luminosity,
    required this.history,
  });
}

class MetricId {
  static const temp = 'temperature';
  static const hum = 'humidity';
  static const wind = 'wind';
  static const press = 'pressure';
  static const rain = 'rain';
  static const lux = 'lux';
}

class DashboardScreen extends StatefulWidget {
  final StationData? data; // mantém compatibilidade com tua assinatura antiga
  const DashboardScreen({super.key, this.data});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _svc = StationService();

  bool _loading = true;
  String? _err;
  List<Station> _stations = const [];
  Station? _selected;
  StationData? _data; // mock gerado a partir da estação

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() {
      _loading = true;
      _err = null;
    });
    try {
      final list = await _svc.list();
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      final selected = list.isNotEmpty ? list.first : null;

      setState(() {
        _stations = list;
        _selected = selected;
        _data = selected != null
            ? _mockFromStation(selected)
            : (widget.data ?? _fallbackMock());
      });
    } catch (e) {
      setState(() {
        _err = '$e';
        _data = widget.data ?? _fallbackMock();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // ---------------------------
  // Mock determinístico por estação
  // ---------------------------
  StationData _mockFromStation(Station s) {
    final seed = _seedFromString(s.guid.isNotEmpty ? s.guid : s.name);
    final r = Random(seed);

    double base(double min, double max) => min + (max - min) * r.nextDouble();

    final temp = base(18, 30);
    final hum = base(45, 85);
    final wind = base(2, 18);
    final press = base(1008, 1022);
    final rain = r.nextInt(5) == 0 ? base(0.5, 6.0) : 0.0;
    final lux = base(400, 1100);

    List<FlSpot> series(double start, double step, double jitter) {
      return List.generate(30, (i) {
        final v = start + sin(i / 4.0 + r.nextDouble()) * jitter + r.nextDouble();
        return FlSpot(i.toDouble(), v);
      });
    }

    return StationData(
      temperature: temp,
      humidity: hum,
      windSpeed: wind,
      pressure: press,
      rain: rain,
      luminosity: lux,
      history: {
        MetricId.temp: series(temp - 2, 1, 1.2),
        MetricId.hum: series(hum - 5, 1, 3.0),
        MetricId.wind: series(wind - 1, .5, 1.5),
        MetricId.press: series(press - 3, .6, 1.2),
        MetricId.rain: List.generate(30, (i) => FlSpot(i.toDouble(), i % 8 == 0 ? base(0.0, 4.0) : 0.0)),
        MetricId.lux: series(lux - 60, 5, 20),
      },
    );
  }

  int _seedFromString(String s) {
    var h = 0;
    for (final c in s.codeUnits) {
      h = 0x1fffffff & (h * 31 + c);
    }
    return h;
  }

  // Mock padrão caso não haja estações
  StationData _fallbackMock() {
    final tempSeries = List.generate(30, (i) => FlSpot(i.toDouble(), 20 + i * 0.2));
    final humSeries = List.generate(30, (i) => FlSpot(i.toDouble(), 55 + (i % 6) * 2.0));
    final windSeries = List.generate(30, (i) => FlSpot(i.toDouble(), 8 + (i % 5) * 0.8));
    final pressSeries = List.generate(30, (i) => FlSpot(i.toDouble(), 1012 + (i % 4) * 1.0));
    final rainSeries = List.generate(30, (i) => FlSpot(i.toDouble(), (i % 8 == 0) ? 2.0 : 0.0));
    final luxSeries = List.generate(30, (i) => FlSpot(i.toDouble(), 600 + (i % 10) * 30.0));
    return StationData(
      temperature: 25.4,
      humidity: 67.0,
      windSpeed: 12.3,
      pressure: 1012,
      rain: 1.5,
      luminosity: 850,
      history: {
        MetricId.temp: tempSeries,
        MetricId.hum: humSeries,
        MetricId.wind: windSeries,
        MetricId.press: pressSeries,
        MetricId.rain: rainSeries,
        MetricId.lux: luxSeries,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = _data ?? _fallbackMock();

    final items = [
      _DashboardItem("Temperatura", "${d.temperature.toStringAsFixed(1)} °C", Icons.thermostat, MetricId.temp, "°C"),
      _DashboardItem("Umidade", "${d.humidity.toStringAsFixed(0)} %", Icons.water_drop, MetricId.hum, "%"),
      _DashboardItem("Vento", "${d.windSpeed.toStringAsFixed(1)} km/h", Icons.air, MetricId.wind, "km/h"),
      _DashboardItem("Pressão", "${d.pressure.toStringAsFixed(0)} hPa", Icons.speed, MetricId.press, "hPa"),
      _DashboardItem("Chuva", "${d.rain.toStringAsFixed(1)} mm", Icons.umbrella, MetricId.rain, "mm"),
      _DashboardItem("Luminosidade", "${d.luminosity.toStringAsFixed(0)} lux", Icons.wb_sunny, MetricId.lux, "lux"),
    ];

    return AppShell(
      appBar: AppBar(
        title: const Text("Dashboard", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_err != null)
              ? Center(child: Text(_err!))
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // -----------------------
                          // Dropdown de estações
                          // -----------------------
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: DropdownButtonFormField<Station>(
                                value: _selected,
                                items: _stations
                                    .map((s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s.name),
                                        ))
                                    .toList(),
                                onChanged: (s) {
                                  if (s == null) return;
                                  setState(() {
                                    _selected = s;
                                    _data = _mockFromStation(s);
                                  });
                                },
                                decoration: InputDecoration(
                                  labelText: 'Estação',
                                  filled: true,
                                  fillColor: const Color(0xFFD3E7EF),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(28),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // -----------------------
                          // Grid com animação suave
                          // -----------------------
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, anim) {
                                return FadeTransition(
                                  opacity: anim,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: .98, end: 1).animate(anim),
                                    child: child,
                                  ),
                                );
                              },
                              child: GridView.count(
                                key: ValueKey(_selected?.guid ?? 'no-station'),
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.1,
                                children: items.map((item) {
                                  return _DashboardCard(
                                    item: item,
                                    onTap: () {
                                      final series = d.history[item.metricId] ?? const <FlSpot>[];
                                      Navigator.of(context).push(_chartRoute(
                                        MetricChartPage(title: item.title, unit: item.unit, spots: series),
                                      ));
                                    },
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }

  // Pequena transição custom na navegação para o gráfico
  Route _chartRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        final tween = Tween(begin: const Offset(0, .05), end: Offset.zero).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: anim.drive(tween), child: FadeTransition(opacity: anim, child: child));
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}

class _DashboardItem {
  final String title;
  final String value;
  final IconData icon;
  final String metricId;
  final String unit;
  const _DashboardItem(this.title, this.value, this.icon, this.metricId, this.unit);
}

class _DashboardCard extends StatelessWidget {
  final _DashboardItem item;
  final VoidCallback onTap;
  const _DashboardCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFFD7EAF4),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(2, 3))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: 42, color: const Color(0xFF3C6E91)),
              const SizedBox(height: 12),
              Text(item.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF3C6E91))),
              const SizedBox(height: 6),
              Text(item.title, style: TextStyle(fontSize: 16, color: Colors.blueGrey.shade700, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class MetricChartPage extends StatelessWidget {
  final String title;
  final String unit;
  final List<FlSpot> spots;
  const MetricChartPage({super.key, required this.title, required this.unit, required this.spots});

  @override
  Widget build(BuildContext context) {
    final hasData = spots.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
        child: hasData
            ? LineChart(
                LineChartData(
                  minX: spots.first.x,
                  maxX: spots.last.x,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (t) => t.map((s) => LineTooltipItem('${s.y.toStringAsFixed(2)} $unit', const TextStyle(fontWeight: FontWeight.w600))).toList(),
                    ),
                  ),
                  gridData: FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 26,
                        interval: (spots.length / 4).clamp(1, 999).toDouble(),
                        getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (v, m) => Text('${v.toStringAsFixed(0)}', style: const TextStyle(fontSize: 11)),
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true, border: Border.all(color: Colors.black12)),
                  lineBarsData: [LineChartBarData(spots: spots, isCurved: true, barWidth: 3, dotData: const FlDotData(show: false))],
                ),
              )
            : const Center(child: Text('Sem dados para exibir')),
      ),
    );
  }
}
