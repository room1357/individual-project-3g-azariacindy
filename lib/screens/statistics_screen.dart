import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Expense> expenses;

  const StatisticsScreen({super.key, required this.expenses});

  // Hitung total per kategori
  Map<String, double> getTotalByCategory() {
    Map<String, double> data = {};
    for (var expense in expenses) {
      data[expense.category] = (data[expense.category] ?? 0) + expense.amount;
    }
    return data;
  }

  // Hitung total per bulan (yyyy-mm)
  Map<String, double> getTotalByMonth() {
    Map<String, double> data = {};
    for (var expense in expenses) {
      String key = "${expense.date.month}-${expense.date.year}";
      data[key] = (data[key] ?? 0) + expense.amount;
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final categoryData = getTotalByCategory();
    final monthData = getTotalByMonth();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistik Pengeluaran"),
        // Use theme AppBar colors
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 📊 Statistik ringkas
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard("Total", "Rp ${expenses.fold(0.0, (a, b) => a + b.amount).toStringAsFixed(0)}"),
                  _buildStatCard("Jumlah", "${expenses.length} item"),
                  _buildStatCard(
                    "Rata-rata",
                    "Rp ${(expenses.fold(0.0, (a, b) => a + b.amount) / (expenses.isEmpty ? 1 : expenses.length)).toStringAsFixed(0)}",
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 🥧 Pie Chart per kategori
              const Text("Pengeluaran per Kategori", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 250,
                child: PieChart(
                  PieChartData(
                    sections: categoryData.entries.map((e) {
                      return PieChartSectionData(
                        value: e.value,
                        title: e.key,
                        radius: 80,
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 📉 Bar Chart per bulan
              const Text("Pengeluaran per Bulan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final keys = monthData.keys.toList();
                            if (value.toInt() < keys.length) {
                              return Text(keys[value.toInt()]);
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    barGroups: monthData.entries.toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: data.value,
                            color: Theme.of(context).colorScheme.primary,
                            width: 20,
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
