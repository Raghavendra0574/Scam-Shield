import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/scan_provider.dart';
import '../services/demo_post_service.dart';

const Color _dashboardBlue = Color(0xFF2563EB);
const Color _dashboardInk = Color(0xFF14213D);

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

  Widget _sectionHeading(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _dashboardInk,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.25,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Consumer<ScanProvider>(
      builder: (context, scan, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final veryNarrow = constraints.maxWidth < 380;
            final cardWidth = (constraints.maxWidth - 14) / 2;
            final cards = [
              _StatCard(
                title: 'Messages Scanned',
                value: '${scan.totalScans}',
                icon: Icons.mark_chat_read_outlined,
                color: const Color(0xFF2563EB),
                detail: 'Total checks saved',
              ),
              _StatCard(
                title: 'Warnings Found',
                value: '${scan.warningsFound}',
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFDA7A16),
                detail: 'Messages with indicators',
              ),
            ];

            if (veryNarrow) {
              return Column(
                children: [
                  cards[0],
                  const SizedBox(height: 12),
                  cards[1],
                ],
              );
            }

            return Row(
              // A SingleChildScrollView gives this section unbounded height.
              // Do not stretch the Row children to the infinite available height.
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: cardWidth, child: cards[0]),
                const SizedBox(width: 14),
                SizedBox(width: cardWidth, child: cards[1]),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Consumer<ScanProvider>(
      builder: (context, scan, child) {
        final activities = scan.recentActivity;

        if (activities.isEmpty) {
          return const _DashboardPanel(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 27, horizontal: 18),
              child: Column(
                children: [
                  _EmptyStateIcon(icon: Icons.history_rounded),
                  SizedBox(height: 12),
                  Text(
                    'No scans yet',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Check a message on the scanner screen to start your activity history.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      height: 1.4,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return _DashboardPanel(
          child: Column(
            children: [
              for (var index = 0; index < activities.length; index++) ...[
                _ActivityTile(
                  suspicious: activities[index].isSuspicious,
                  title: activities[index].isSuspicious
                      ? 'Potential scam signs detected'
                      : 'No matching keywords found',
                  subtitle: activities[index].isSuspicious
                      ? 'Checked at ${_formatScanTime(activities[index].scannedAt)}\n'
                          'Indicators: ${activities[index].matchedWords.join(', ')}'
                      : 'Checked at ${_formatScanTime(activities[index].scannedAt)}',
                ),
                if (index != activities.length - 1)
                  const Divider(height: 1, indent: 58, endIndent: 14),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildApiFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                'Demo API Feed',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: _dashboardInk,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _reloadPosts,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Sample online posts used to demonstrate REST API integration. These are not verified scam reports.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 13),
        FutureBuilder<List<DemoPost>>(
          future: _postsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _DashboardPanel(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 26,
                        height: 26,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                      SizedBox(height: 13),
                      Text(
                        'Loading sample posts...',
                        style: TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (snapshot.hasError) {
              return _DashboardPanel(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      const _EmptyStateIcon(icon: Icons.cloud_off_rounded),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load demo posts',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Check your internet connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _reloadPosts,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final posts = snapshot.data ?? <DemoPost>[];
            if (posts.isEmpty) {
              return const _DashboardPanel(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No sample posts are available.'),
                ),
              );
            }

            return _DashboardPanel(
              child: Column(
                children: [
                  for (var index = 0; index < posts.length; index++) ...[
                    _ApiPostTile(post: posts[index]),
                    if (index != posts.length - 1)
                      const Divider(height: 1, indent: 66, endIndent: 14),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth < 600 ? 16.0 : 28.0;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.space_dashboard_rounded, color: _dashboardBlue),
            SizedBox(width: 10),
            Text(
              'Safety Dashboard',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Back to scanner',
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(screenWidth < 420 ? 20 : 25),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF15305D), Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.13),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'YOUR SAFETY WORKSPACE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Scam Shield Active',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  height: 1.12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                'Review your checks and recent warning signs.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.80),
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.shield_moon_outlined,
                          color: Colors.white.withValues(alpha: 0.93),
                          size: screenWidth < 420 ? 54 : 78,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 27),
                  _sectionHeading(
                    'Your Overview',
                    'A quick summary of your saved scan activity.',
                  ),
                  _buildStatistics(),
                  const SizedBox(height: 27),
                  _sectionHeading(
                    'Recent Activity',
                    'The latest messages checked in this app.',
                  ),
                  _buildRecentActivity(),
                  const SizedBox(height: 27),
                  _buildApiFeed(),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E8),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF6E5B8)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Color(0xFFB7791F),
                          size: 25,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Safety Tip',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF7C5016),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Never share your OTP, password, or banking PIN. Verify unexpected requests through an official website or phone number.',
                                style: TextStyle(
                                  color: Color(0xFF7C5016),
                                  fontSize: 12,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Center(
                    child: Text(
                      'SCAM SHIELD  •  CHECK CAREFULLY',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 1,
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

class _DashboardPanel extends StatelessWidget {
  final Widget child;

  const _DashboardPanel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE4EAF3)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 18,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String detail;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return _DashboardPanel(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                Icon(Icons.trending_up_rounded,
                    size: 18, color: color.withValues(alpha: 0.7)),
              ],
            ),
            const SizedBox(height: 17),
            Text(
              value,
              style: const TextStyle(
                fontSize: 31,
                height: 1.0,
                fontWeight: FontWeight.w800,
                color: _dashboardInk,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: _dashboardInk,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              detail,
              style: const TextStyle(
                fontSize: 10,
                height: 1.35,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final bool suspicious;
  final String title;
  final String subtitle;

  const _ActivityTile({
    required this.suspicious,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = suspicious
        ? const Color(0xFFC57917)
        : const Color(0xFF138A58);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              suspicious
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline_rounded,
              color: color,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _dashboardInk,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.blueGrey.shade200,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _ApiPostTile extends StatelessWidget {
  final DemoPost post;

  const _ApiPostTile({required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF1FF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(
                '${post.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: _dashboardBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: _dashboardInk,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  post.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateIcon extends StatelessWidget {
  final IconData icon;

  const _EmptyStateIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFEAF1FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: _dashboardBlue, size: 26),
    );
  }
}
