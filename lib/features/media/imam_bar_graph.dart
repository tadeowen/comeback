import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:shimmer/shimmer.dart';

class ImamRatingAnalyticsScreen extends StatelessWidget {
  const ImamRatingAnalyticsScreen({super.key});

  Future<Map<String, dynamic>> _fetchData(String imamId) async {
    try {
      // Fetch rating distribution
      final ratingsSnapshot = await FirebaseFirestore.instance
          .collection(
              'imamRatings') // Fixed typo from 'imamRatings' to 'imamRatings' if needed
          .where('imamId', isEqualTo: imamId)
          .get();

      final ratingCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      for (var doc in ratingsSnapshot.docs) {
        final rating = (doc['rating'] as num?)?.toInt() ?? 0;
        if (rating >= 1 && rating <= 5) {
          ratingCounts[rating] = (ratingCounts[rating] ?? 0) + 1;
        }
      }

      // Fetch request status counts from dua_request
      final requestsSnapshot = await FirebaseFirestore.instance
          .collection('dua_request')
          .where('imamId', isEqualTo: imamId)
          .get();

      int pendingCount = 0;
      int resolvedCount = 0;

      for (var doc in requestsSnapshot.docs) {
        final status = doc.data()['status'] as String? ??
            'pending'; // Safely access status field
        if (status == 'pending') {
          pendingCount++;
        } else if (status == 'resolved') {
          resolvedCount++;
        }
      }

      return {
        'ratingCounts': ratingCounts,
        'pendingCount': pendingCount,
        'resolvedCount': resolvedCount,
      };
    } catch (e) {
      debugPrint('Error fetching data: $e');
      return {
        'ratingCounts': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
        'pendingCount': 0,
        'resolvedCount': 0,
      };
    }
  }

  double _calculateAverageRating(Map<int, int> ratingCounts) {
    int totalRatings = 0;
    int sumOfRatings = 0;
    ratingCounts.forEach((rating, count) {
      totalRatings += count;
      sumOfRatings += rating * count;
    });
    return totalRatings > 0 ? sumOfRatings / totalRatings : 0;
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildShimmerCard()),
                const SizedBox(width: 10),
                Expanded(child: _buildShimmerCard()),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const SizedBox(
        height: 100,
        child: Padding(
          padding: EdgeInsets.all(16.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imamId = FirebaseAuth.instance.currentUser?.uid;
    if (imamId == null) {
      return const Scaffold(
          body: Center(child: Text('User not authenticated')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Analytics Dashboard'),
        backgroundColor: Colors.green[700],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _fetchData(imamId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data ??
              {
                'ratingCounts': {1: 0, 2: 0, 3: 0, 4: 0, 5: 0},
                'pendingCount': 0,
                'resolvedCount': 0,
              };

          final ratingCounts = data['ratingCounts'] as Map<int, int>;
          final pendingCount = data['pendingCount'] as int;
          final resolvedCount = data['resolvedCount'] as int;

          final averageRating = _calculateAverageRating(ratingCounts);
          final totalRatings = ratingCounts.values.fold(0, (a, b) => a + b);

          // Calculate maximum value for dynamic Y-axis scaling
          final maxRatingCount =
              ratingCounts.values.fold(0, (a, b) => a > b ? a : b);
          final yAxisInterval = (maxRatingCount / 5).ceil().toDouble();
          final yAxisMax = (maxRatingCount + yAxisInterval).toDouble();

          // Ensure we have at least some data for the pie chart
          final hasRequestData = (pendingCount + resolvedCount) > 0;
          final pieChartData = hasRequestData
              ? [
                  StatusData('Pending', pendingCount, Colors.orange),
                  StatusData('Resolved', resolvedCount, Colors.green),
                ]
              : [
                  StatusData('No Data', 1, Colors.grey),
                ];

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF5F7FA), Color(0xFFE4E7EB)],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildSummaryCard(
                          'Average Rating',
                          averageRating.toStringAsFixed(1),
                          Icons.star,
                          Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSummaryCard(
                          'Total Ratings',
                          totalRatings.toString(),
                          Icons.people,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 300,
                        child: SfCartesianChart(
                          plotAreaBackgroundColor: Colors.white,
                          title: ChartTitle(
                            text: 'Rating Distribution',
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          primaryXAxis: CategoryAxis(
                            title: AxisTitle(text: 'Star Rating'),
                            axisLine:
                                const AxisLine(width: 2, color: Colors.grey),
                            majorTickLines: const MajorTickLines(size: 4),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.amber[800],
                            ),
                          ),
                          primaryYAxis: NumericAxis(
                            title: AxisTitle(text: 'Number of Ratings'),
                            minimum: 0,
                            maximum: yAxisMax > 5 ? yAxisMax : 5,
                            interval: yAxisInterval > 1 ? yAxisInterval : 1,
                            axisLine:
                                const AxisLine(width: 2, color: Colors.grey),
                            majorTickLines: const MajorTickLines(size: 4),
                            majorGridLines: const MajorGridLines(
                              width: 1,
                              color: Colors.grey,
                              dashArray: [5, 5],
                            ),
                          ),
                          series: <CartesianSeries<RatingData, String>>[
                            ColumnSeries<RatingData, String>(
                              dataSource: [
                                RatingData('1★', ratingCounts[1]!,
                                    const Color(0xFFEF5350)),
                                RatingData('2★', ratingCounts[2]!,
                                    const Color(0xFFFFA726)),
                                RatingData('3★', ratingCounts[3]!,
                                    const Color(0xFFFFEE58)),
                                RatingData('4★', ratingCounts[4]!,
                                    const Color(0xFF66BB6A)),
                                RatingData('5★', ratingCounts[5]!,
                                    const Color(0xFF42A5F5)),
                              ],
                              xValueMapper: (RatingData data, _) => data.rating,
                              yValueMapper: (RatingData data, _) => data.count,
                              color: const Color.fromRGBO(8, 142, 255, 1),
                              pointColorMapper: (RatingData data, _) =>
                                  data.color,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelAlignment: ChartDataLabelAlignment.top,
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(5),
                              width: 0.6,
                              spacing: 0.2,
                              animationDuration: 1000,
                            )
                          ],
                          tooltipBehavior: TooltipBehavior(
                            enable: true,
                            format: 'point.x : point.y ratings',
                            color: Colors.black87,
                            textStyle: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 300,
                        child: SfCircularChart(
                          title: ChartTitle(
                            text: 'Prayer Request Status',
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          legend: Legend(
                            isVisible: true,
                            position: LegendPosition.bottom,
                            overflowMode: LegendItemOverflowMode.wrap,
                          ),
                          series: <CircularSeries>[
                            PieSeries<StatusData, String>(
                              dataSource: pieChartData,
                              xValueMapper: (StatusData data, _) => data.status,
                              yValueMapper: (StatusData data, _) => data.count,
                              dataLabelSettings: const DataLabelSettings(
                                isVisible: true,
                                labelPosition: ChartDataLabelPosition.outside,
                                textStyle: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              pointColorMapper: (StatusData data, _) =>
                                  data.color,
                              explode: true,
                              explodeIndex: 0,
                              explodeOffset: '10%',
                              animationDuration: 1000,
                            ),
                          ],
                          tooltipBehavior: TooltipBehavior(
                            enable: true,
                            format: 'point.x : point.y',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class RatingData {
  final String rating;
  final int count;
  final Color color;

  RatingData(this.rating, this.count, this.color);
}

class StatusData {
  final String status;
  final int count;
  final Color color;

  StatusData(this.status, this.count, this.color);
}
