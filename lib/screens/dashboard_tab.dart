import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/schedule_provider.dart';
import '../services/smart_assistant.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Consumer<ScheduleProvider>(
        builder: (context, provider, child) {
          final insight = SmartAssistant.getDailyInsight(provider.events);
          final completionRate = provider.completionRate;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInsightCard(context, insight),
                const SizedBox(height: 30),
                const Text(
                  'Your Progress',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                _buildProgressChart(context, completionRate),
                const SizedBox(height: 30),
                _buildStatCards(context, provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInsightCard(BuildContext context, String insight) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Insight',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  insight,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX();
  }

  Widget _buildProgressChart(BuildContext context, double rate) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 60,
          sections: [
            PieChartSectionData(
              color: Theme.of(context).primaryColor,
              value: rate * 100,
              title: '${(rate * 100).toInt()}%',
              radius: 50,
              titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              color: Colors.grey.withOpacity(0.2),
              value: (1 - rate) * 100,
              title: '',
              radius: 40,
            ),
          ],
        ),
      ),
    ).animate().scale();
  }

  Widget _buildStatCards(BuildContext context, ScheduleProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context, 
            'Upcoming', 
            provider.events.where((e) => !e.isCompleted).length.toString(), 
            Icons.calendar_today, 
            Colors.orange,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: _buildStatCard(
            context, 
            'High Priority', 
            provider.highPriorityCount.toString(), 
            Icons.priority_high, 
            Colors.redAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY();
  }
}
