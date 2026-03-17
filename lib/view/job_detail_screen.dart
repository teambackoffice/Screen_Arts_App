import 'dart:ui';
import 'package:flutter/material.dart';

class _TimeEntry {
  final DateTime startTime;
  DateTime? stopTime;
  _TimeEntry({required this.startTime, this.stopTime});
}

class JobDetailScreen extends StatefulWidget {
  final Map<String, dynamic> job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  bool _isRunning = false;
  bool _showComplete = false;
  bool _isCompleted = false;
  final List<_TimeEntry> _timeLog = [];

  // Theme Colors
  final Color primaryColor = const Color(0xFF6366F1); // Indigo
  final Color successColor = const Color(0xFF10B981); // Emerald
  final Color errorColor = const Color(0xFFEF4444); // Rose
  final Color surfaceColor = Colors.white;
  final Color backgroundColor = const Color(0xFFF8FAFC);

  String get _jobStatus {
    if (_isCompleted) return 'Completed';
    if (_isRunning) return 'In Progress';
    return widget.job['status'] ?? 'Pending';
  }

  Color get _statusColor {
    if (_isCompleted) return successColor;
    if (_isRunning) return primaryColor;
    return Colors.orange;
  }

  String _fmt(DateTime dt) =>
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}";

  void _onStart() {
    setState(() {
      _isRunning = true;
      _showComplete = true;
      _timeLog.insert(0, _TimeEntry(startTime: DateTime.now()));
    });
  }

  void _onStop() {
    setState(() {
      _isRunning = false;
      if (_timeLog.isNotEmpty && _timeLog.first.stopTime == null) {
        _timeLog.first.stopTime = DateTime.now();
      }
    });
  }

  void _onComplete() {
    setState(() {
      if (_isRunning &&
          _timeLog.isNotEmpty &&
          _timeLog.first.stopTime == null) {
        _timeLog.first.stopTime = DateTime.now();
      }
      _isRunning = false;
      _isCompleted = true;
      _showComplete = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final List employees = job['employees'] ?? [];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
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
          job['jobOrderId'],
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          _StatusBadge(status: _jobStatus, color: _statusColor),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                // ── Hero Section ───────────────────────────────────
                _HeroHeader(
                  serviceType: job['serviceType'],
                  operation: job['operation'],
                ),

                const SizedBox(height: 24),

                // ── Info Grid ──────────────────────────────────────
                _InfoGrid(
                  items: [
                    _InfoTile(
                      label: 'Item Name',
                      value: job['itemName'],
                      icon: Icons.inventory_2_outlined,
                    ),
                    _InfoTile(
                      label: 'Total Cost',
                      value: '₹${job['totalCost']}',
                      icon: Icons.payments_outlined,
                      isBold: true,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Production Specs ──────────────────────────────
                _SectionTitle(title: "Production Specs"),
                _SectionCard(
                  children: [
                    _DetailRow(
                      label: 'Copies',
                      value: '${job['copies']} units',
                    ),
                    _DetailRow(label: 'Size', value: job['size']),
                    _DetailRow(label: 'Material', value: job['material']),
                    _DetailRow(
                      label: 'Colors',
                      value: job['colors'],
                      isLast: true,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Team ──────────────────────────────────────────
                _SectionTitle(title: "Assigned Team"),
                _EmployeeList(employees: employees),

                const SizedBox(height: 24),

                // ── Time Log ──────────────────────────────────────
                if (_timeLog.isNotEmpty) ...[
                  _SectionTitle(title: "Activity Log"),
                  ..._timeLog
                      .map((entry) => _TimeLogTile(entry: entry, fmt: _fmt))
                      .toList(),
                ],

                const SizedBox(height: 40),
              ],
            ),
          ),

          // ── Bottom Actions ──────────────────────────────────────
          _BottomActionContainer(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildActionButtons(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_isCompleted) {
      return Container(
        height: 54,
        width: double.infinity,
        decoration: BoxDecoration(
          color: successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: successColor),
            const SizedBox(width: 10),
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
      key: ValueKey('$_isRunning$_showComplete'),
      children: [
        if (!_isRunning)
          Expanded(
            child: _MainButton(
              label: 'Start Session',
              icon: Icons.play_arrow_rounded,
              color: primaryColor,
              onPressed: _onStart,
            ),
          ),
        if (_isRunning)
          Expanded(
            child: _MainButton(
              label: 'Stop',
              icon: Icons.stop_rounded,
              color: errorColor,
              onPressed: _onStop,
              isOutlined: true,
            ),
          ),
        if (_showComplete || _isRunning) ...[
          const SizedBox(width: 12),
          Expanded(
            child: _MainButton(
              label: 'Complete',
              icon: Icons.done_all_rounded,
              color: successColor,
              onPressed: _onComplete,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Supporting UI Components ──────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  final String serviceType;
  final String operation;
  const _HeroHeader({required this.serviceType, required this.operation});

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
          Text(
            serviceType.toUpperCase(),
            style: TextStyle(
              color: Colors.indigo.shade200,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
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

class _StatusBadge extends StatelessWidget {
  final String status;
  final Color color;
  const _StatusBadge({required this.status, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(
        child: Text(
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
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
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
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

class _EmployeeList extends StatelessWidget {
  final List employees;
  const _EmployeeList({required this.employees});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      children: employees.asMap().entries.map((entry) {
        final emp = entry.value;
        final isLast = entry.key == employees.length - 1;
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
                  emp['name'][0],
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
                    emp['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    emp['role'],
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
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

class _TimeLogTile extends StatelessWidget {
  final _TimeEntry entry;
  final String Function(DateTime) fmt;
  const _TimeLogTile({required this.entry, required this.fmt});

  @override
  Widget build(BuildContext context) {
    bool isRunning = entry.stopTime == null;
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
            color: isRunning ? Colors.indigo : Colors.black,
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
