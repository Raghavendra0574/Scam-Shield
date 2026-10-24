import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/scan_provider.dart';
import '../services/demo_post_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<DemoPost>> _postsFuture;

  @override
  void initState() {
    super.initState();
    _postsFuture = fetchDemoPosts();
  }

  void _reloadPosts() {
    setState(() {
      _postsFuture = fetchDemoPosts();
    });
  }

  String _formatScanTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }

  Widget _buildApiFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Demo API Feed',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              onPressed: _reloadPosts,
              tooltip: 'Refresh posts',
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        const Text(
          'Sample posts fetched online for API demonstration. '
          'These are not verified scam reports.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<DemoPost>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            // Loading state.
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Loading posts from API...'),
                    ],
                  ),
                ),
              );
            }

            // Error state.
            if (snapshot.hasError) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_off,
                        size: 40,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Unable to load posts.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Check your internet connection '
                        'and try again.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _reloadPosts,
                        icon: const Icon(Icons.refresh),
                        label: const Text('TRY AGAIN'),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Successfully fetched data.
            final posts = snapshot.data ?? [];

            if (posts.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No posts are available.'),
                ),
              );
            }

            return Column(
              children: posts.map((post) {
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${post.id}'),
                    ),
                    title: Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        post.body,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatistics() {
    return Consumer<ScanProvider>(
      builder: (context, scan, child) {
        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Messages Scanned',
                value: '${scan.totalScans}',
                icon: Icons.message,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Warnings Found',
                value: '${scan.warningsFound}',
                icon: Icons.warning_amber,
                color: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Consumer<ScanProvider>(
      builder: (context, scan, child) {
        final activities = scan.recentActivity;

        if (activities.isEmpty) {
          return const Card(
            child: ListTile(
              leading: Icon(Icons.history),
              title: Text('No scans yet'),
              subtitle: Text(
                'Your recent scan activity will appear here.',
              ),
            ),
          );
        }

        return Card(
          child: Column(
            children: activities.map((activity) {
              final suspicious = activity.isSuspicious;

              final subtitle = suspicious
                  ? 'Checked at '
                      '${_formatScanTime(activity.scannedAt)}\n'
                      'Indicators: '
                      '${activity.matchedWords.join(', ')}'
                  : 'Checked at '
                      '${_formatScanTime(activity.scannedAt)}';

              return ListTile(
                leading: Icon(
                  suspicious
                      ? Icons.warning_amber
                      : Icons.check_circle,
                  color: suspicious ? Colors.orange : Colors.green,
                ),
                title: Text(
                  suspicious
                      ? 'Potential scam signs detected'
                      : 'No matching keywords found',
                ),
                subtitle: Text(subtitle),
                isThreeLine: suspicious,
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Dashboard'),
        centerTitle: true,
        leading: const Icon(Icons.dashboard),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Protection status.
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.shield,
                          color: Colors.white,
                          size: 48,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Scam Shield Active',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Stay alert. Check suspicious messages.',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Your Overview',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Actual counts from the current app session.
                  _buildStatistics(),

                  const SizedBox(height: 24),

                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Latest five scans.
                  _buildRecentActivity(),

                  const SizedBox(height: 24),

                  // REST API section.
                  _buildApiFeed(),

                  const SizedBox(height: 24),

                  const Text(
                    'Safety Tip',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Card(
                    color: Colors.amber.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Colors.orange,
                            size: 34,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Never share your OTP, password, '
                              'or banking PIN with anyone. '
                              'Verify unexpected requests through '
                              'official channels.',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}