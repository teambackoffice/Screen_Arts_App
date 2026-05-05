import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_arts_app/controller/job_order_controller.dart';
import 'package:screen_arts_app/modal/job_work_modal_class.dart';
import 'package:screen_arts_app/view/job_detail_screen.dart';

class JobOrders extends StatefulWidget {
  const JobOrders({super.key});

  @override
  State<JobOrders> createState() => _JobOrdersState();
}

class _JobOrdersState extends State<JobOrders> {
  String _selectedFilter = 'All';

  final Color primaryColor = const Color(0xFF6366F1);
  final Color backgroundColor = const Color(0xFFF8FAFC);
  final Color cardColor = Colors.white;

  @override
  void initState() {
    super.initState();
    // Fetch data on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EMPLOYEEJobWorkController>().getJobWorks();
    });
  }

  List<Message> _getFiltered(List<Message> jobs) {
    if (_selectedFilter == 'All') return jobs;
    return jobs.where((j) => j.customJobStatus == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Consumer<EMPLOYEEJobWorkController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null) {
            return _buildErrorState(controller);
          }

          final jobs = controller.jobWorks?.message ?? [];
          final filtered = _getFiltered(jobs);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Text(
                  '${filtered.length} Active Assignments',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => controller.getJobWorks(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => _JobCard(
                            job: filtered[index],
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      JobDetailScreen(job: filtered[index]),
                                ),
                              );
                              if (context.mounted) {
                                controller.getJobWorks();
                              }
                            },
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: cardColor,
      elevation: 0,
      title: Row(
        children: [
          // CircleAvatar(
          //   backgroundColor: primaryColor.withOpacity(0.1),
          //   child: Text(
          //     "RK",
          //     style: TextStyle(
          //       color: primaryColor,
          //       fontSize: 14,
          //       fontWeight: FontWeight.bold,
          //     ),
          //   ),
          // ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'My Workshop',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Consumer<EMPLOYEEJobWorkController>(
          builder: (context, controller, _) => IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
            onPressed: controller.isLoading ? null : controller.getJobWorks,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_turned_in_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "No jobs found",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(EMPLOYEEJobWorkController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              controller.error ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.getJobWorks,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Job Card ───────────────────────────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  final Message job;
  final VoidCallback onTap;

  const _JobCard({required this.job, required this.onTap});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'In Progress':
        return const Color(0xFF6366F1);
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return const Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(job.customJobStatus);

    // Format posting date as readable string
    final date =
        '${job.postingDate.day} ${_month(job.postingDate.month)} ${job.postingDate.year}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      job.jobOrder,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  _StatusBadge(status: job.customJobStatus, color: statusColor),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                job.customItems.isNotEmpty
                    ? job.customItems.first.itemName
                    : job.operation,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job.customServiceType,
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              if (job.customCustomerName.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      job.customCustomerName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  if (job.customItems.isNotEmpty) ...[
                    const Spacer(),
                    const Icon(
                      Icons.layers_outlined,
                      size: 13,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${job.customItems.length} item${job.customItems.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
              if (job.timeLogs.isNotEmpty &&
                  job.timeLogs.first.fromTime != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatTime(job.timeLogs.first.fromTime),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    if (job.timeLogs.first.toTime != null) ...[
                      const SizedBox(width: 4),
                      const Text(
                        '-',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(job.timeLogs.first.toTime),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    int h = dt.hour;
    int m = dt.minute;
    String ampm = h >= 12 ? 'PM' : 'AM';
    h = h % 12;
    if (h == 0) h = 12;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $ampm';
  }

  String _month(int m) => const [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m];
}

// ── Status Badge ───────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
