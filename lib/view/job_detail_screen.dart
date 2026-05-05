import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_arts_app/controller/job_work_controller.dart';
import 'package:screen_arts_app/modal/job_work_modal_class.dart';

class JobDetailScreen extends StatelessWidget {
  final Message job;
  const JobDetailScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobWorkProvider()..init(job),
      child: _JobDetailView(job: job),
    );
  }
}

class _JobDetailView extends StatelessWidget {
  final Message job;
  const _JobDetailView({required this.job});

  static const Color primaryColor = Color(0xFF6366F1);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  String _fmt(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<JobWorkProvider>();

    final String jobStatus = _resolveStatus(provider.status);
    final Color statusColor = _resolveStatusColor(provider.status);

    final itemName = job.customItems.isNotEmpty
        ? job.customItems.first.itemName
        : 'N/A';
    final copies = job.customItems.isNotEmpty
        ? job.customItems.first.copies.toString()
        : '0';
    final totalCost = job.customItems.isNotEmpty
        ? job.customItems.first.designCost.toString()
        : '0';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Color(0xFF1E293B),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          job.jobOrder,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Error Banner ──────────────────────────────────────────
          if (provider.errorMessage.isNotEmpty)
            Material(
              color: errorColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: errorColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.errorMessage,
                        style: const TextStyle(
                          color: errorColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                _HeroHeader(
                  serviceType: job.customServiceType.isNotEmpty
                      ? job.customServiceType
                      : 'Service',
                  operation: job.operation.isNotEmpty
                      ? job.operation
                      : 'Operation',
                  status: jobStatus,
                  statusColor: statusColor,
                ),
                const SizedBox(height: 24),
                _InfoGrid(
                  items: [
                    _InfoTile(
                      label: 'Item Name',
                      value: itemName,
                      icon: Icons.inventory_2_outlined,
                    ),
                    _InfoTile(
                      label: 'Sales Order No',
                      value: job.customSalesOrderNumber,
                      icon: Icons.payments_outlined,
                      isBold: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const SizedBox(height: 24),
                if (job.customEmployees.isNotEmpty) ...[
                  const _SectionTitle(title: "Assigned Team"),
                  _EmployeeList(employees: job.customEmployees),
                  const SizedBox(height: 24),
                ],
                if (job.timeLogs.isNotEmpty ||
                    provider.localTimeLogs.isNotEmpty) ...[
                  const _SectionTitle(title: "Activity Log"),
                  ...job.timeLogs
                      .where((log) => log.fromTime != null)
                      .map((log) => _ServerTimeLogTile(log: log, fmt: _fmt)),
                  ...provider.localTimeLogs.map(
                    (entry) => _LocalTimeLogTile(entry: entry, fmt: _fmt),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),

          // ── Bottom Actions ────────────────────────────────────────
          _BottomActionContainer(
            child: provider.isLoading
                ? const SizedBox(
                    height: 54,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildActionButtons(context, provider),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, JobWorkProvider provider) {
    if (provider.status == JobWorkStatus.completed) {
      return Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.check_circle, color: successColor),
            SizedBox(width: 10),
            Text(
              'Job Completed Successfully',
              style: TextStyle(
                color: successColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      key: ValueKey(provider.status),
      children: [
        // IDLE → Start only
        if (provider.status == JobWorkStatus.idle)
          Expanded(
            child: _MainButton(
              label: 'Start',
              icon: Icons.play_arrow_rounded,
              color: primaryColor,
              onPressed: () =>
                  context.read<JobWorkProvider>().startTimeLog(job.name),
            ),
          ),

        // RUNNING → Stop only
        if (provider.status == JobWorkStatus.running)
          Expanded(
            child: _MainButton(
              label: 'Stop',
              icon: Icons.stop_rounded,
              color: errorColor,
              isOutlined: true,
              onPressed: () =>
                  context.read<JobWorkProvider>().stopTimeLog(job.name),
            ),
          ),

        // STOPPED → Continue + Complete
        if (provider.status == JobWorkStatus.stopped) ...[
          Expanded(
            child: _MainButton(
              label: 'Continue',
              icon: Icons.play_circle_outline_rounded,
              color: primaryColor,
              onPressed: () =>
                  context.read<JobWorkProvider>().continueTimeLog(job.name),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _MainButton(
              label: 'Complete',
              icon: Icons.done_all_rounded,
              color: successColor,
              onPressed: () =>
                  context.read<JobWorkProvider>().completeJobWork(job.name),
            ),
          ),
        ],
      ],
    );
  }

  String _resolveStatus(JobWorkStatus status) {
    switch (status) {
      case JobWorkStatus.running:
        return 'In Progress';
      case JobWorkStatus.stopped:
        return 'Stopped';
      case JobWorkStatus.completed:
        return 'Completed';
      case JobWorkStatus.idle:
        return job.customJobStatus.isNotEmpty ? job.customJobStatus : 'Pending';
    }
  }

  Color _resolveStatusColor(JobWorkStatus status) {
    switch (status) {
      case JobWorkStatus.running:
        return primaryColor;
      case JobWorkStatus.stopped:
        return Colors.orange;
      case JobWorkStatus.completed:
        return successColor;
      case JobWorkStatus.idle:
        return Colors.orange;
    }
  }
}

// ── Local Time Log Tile ───────────────────────────────────────────────────────

class _LocalTimeLogTile extends StatelessWidget {
  final LocalTimeEntry entry;
  final String Function(DateTime) fmt;
  const _LocalTimeLogTile({required this.entry, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isRunning = entry.stopTime == null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRunning ? Colors.indigo.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRunning
              ? Colors.indigo.withOpacity(0.2)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isRunning ? Icons.timer_outlined : Icons.history_rounded,
            size: 18,
            color: isRunning ? Colors.indigo : Colors.black54,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              fmt(entry.startTime),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: isRunning
                  ? const Text(
                      "Running...",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  : Text(
                      fmt(entry.stopTime!),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Supporting UI Components ──────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final String serviceType;
  final String operation;
  final String status;
  final Color statusColor;
  const _HeroHeader({
    required this.serviceType,
    required this.operation,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF334155)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                serviceType.toUpperCase(),
                style: TextStyle(
                  color: Colors.indigo.shade200,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: statusColor.withOpacity(0.4)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            operation,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isBold;
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final List<Widget> items;
  const _InfoGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: items
          .map(
            (e) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: e,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Color(0xFF475569),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _DetailRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServerTimeLogTile extends StatelessWidget {
  final TimeLog log;
  final String Function(DateTime) fmt;
  const _ServerTimeLogTile({required this.log, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final isRunning = log.toTime == null;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRunning ? Colors.indigo.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRunning
              ? Colors.indigo.withOpacity(0.2)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isRunning ? Icons.timer_outlined : Icons.history_rounded,
            size: 18,
            color: isRunning ? Colors.indigo : Colors.black54,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              log.fromTime != null ? fmt(log.fromTime!) : 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.grey),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: isRunning
                  ? const Text(
                      "Running...",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  : Text(
                      fmt(log.toTime!),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeList extends StatelessWidget {
  final List<CustomEmployee> employees;
  const _EmployeeList({required this.employees});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      children: employees.asMap().entries.map((entry) {
        final emp = entry.value;
        final isLast = entry.key == employees.length - 1;
        final name = emp.name1.isNotEmpty ? emp.name1 : emp.employees;
        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFF1F5F9),
                radius: 18,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Employee',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MainButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isOutlined;
  const _MainButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isOutlined ? Colors.white : color,
          foregroundColor: isOutlined ? color : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: isOutlined
                ? BorderSide(color: color, width: 2)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _BottomActionContainer extends StatelessWidget {
  final Widget child;
  const _BottomActionContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: child,
    );
  }
}
