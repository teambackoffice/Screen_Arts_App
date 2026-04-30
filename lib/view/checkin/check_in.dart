import 'dart:async';
import 'package:flutter/material.dart';

class CheckInOut extends StatefulWidget {
  const CheckInOut({super.key});

  @override
  State<CheckInOut> createState() => _CheckInOutState();
}

class _CheckInOutState extends State<CheckInOut> with TickerProviderStateMixin {
  bool _isCheckedIn = false;
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  late AnimationController _pageAnimCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  late AnimationController _checkInBtnCtrl;
  late AnimationController _checkOutBtnCtrl;
  late Animation<double> _checkInScale;
  late Animation<double> _checkOutScale;

  @override
  void initState() {
    super.initState();

    _pageAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _pageAnimCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _pageAnimCtrl, curve: Curves.easeOut));
    _pageAnimCtrl.forward();

    _checkInBtnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _checkOutBtnCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
    );
    _checkInScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _checkInBtnCtrl, curve: Curves.easeInOut),
    );
    _checkOutScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _checkOutBtnCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageAnimCtrl.dispose();
    _checkInBtnCtrl.dispose();
    _checkOutBtnCtrl.dispose();
    super.dispose();
  }

  void _handleCheckIn() {
    if (_isCheckedIn) return;
    setState(() {
      _isCheckedIn = true;
      _checkInTime = DateTime.now();
      _checkOutTime = null;
      _elapsed = Duration.zero;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() => _elapsed = DateTime.now().difference(_checkInTime!));
      });
    });
  }

  void _handleCheckOut() {
    if (!_isCheckedIn) return;
    setState(() {
      _isCheckedIn = false;
      _checkOutTime = DateTime.now();
      _timer?.cancel();
    });
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m:$s $period';
  }

  String _formatElapsed(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h : $m : $s';
  }

  String _todayDateString() {
    final now = DateTime.now();
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F4F1),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDateCard(),
                        const SizedBox(height: 16),
                        _buildStatusCard(),
                        const SizedBox(height: 20),
                        _buildButtons(),
                        const SizedBox(height: 20),

                        _buildTimelineCard(),
                        const SizedBox(height: 16),
                        _buildActivityLog(),
                      ],
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

  // ── Top Bar ──────────────────────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 20, 20, 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F4F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Attendance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF185FA5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0EEE8)),
      ],
    );
  }

  // ── Date Card ────────────────────────────────────────────────────────────
  Widget _buildDateCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E6E0), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.today_rounded, size: 18, color: Color(0xFF888780)),
          const SizedBox(width: 10),
          Text(
            _todayDateString(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEDE6),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Text(
              'Today',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5F5E5A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Status Card ──────────────────────────────────────────────────────────
  Widget _buildStatusCard() {
    final Color color = _isCheckedIn
        ? const Color(0xFF1D9E75)
        : const Color(0xFF888780);
    final Color bgColor = _isCheckedIn
        ? const Color(0xFFE1F5EE)
        : const Color(0xFFF5F4F1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          _PulseDot(color: color, active: _isCheckedIn),
          const SizedBox(width: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _isCheckedIn ? 'Currently Checked In' : 'Not Checked In',
              key: ValueKey(_isCheckedIn),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          const Spacer(),
          if (_isCheckedIn && _checkInTime != null)
            Text(
              'Since ${_checkInTime!.hour % 12 == 0 ? 12 : _checkInTime!.hour % 12}:${_checkInTime!.minute.toString().padLeft(2, '0')} ${_checkInTime!.hour >= 12 ? 'PM' : 'AM'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }

  // ── Check In / Check Out Buttons ─────────────────────────────────────────
  Widget _buildButtons() {
    return Row(
      children: [
        // ── CHECK IN ──
        Expanded(
          child: ScaleTransition(
            scale: _checkInScale,
            child: GestureDetector(
              onTapDown: (_) => _checkInBtnCtrl.forward(),
              onTapUp: (_) {
                _checkInBtnCtrl.reverse();
                _handleCheckIn();
              },
              onTapCancel: () => _checkInBtnCtrl.reverse(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 72,
                decoration: BoxDecoration(
                  color: _isCheckedIn
                      ? const Color(0xFF1D9E75)
                      : const Color(0xFF185FA5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (_isCheckedIn
                                  ? const Color(0xFF1D9E75)
                                  : const Color(0xFF185FA5))
                              .withOpacity(0.38),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.login_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Check In',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // ── CHECK OUT ──
        Expanded(
          child: ScaleTransition(
            scale: _checkOutScale,
            child: GestureDetector(
              onTapDown: (_) => _checkOutBtnCtrl.forward(),
              onTapUp: (_) {
                _checkOutBtnCtrl.reverse();
                _handleCheckOut();
              },
              onTapCancel: () => _checkOutBtnCtrl.reverse(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 72,
                decoration: BoxDecoration(
                  color: !_isCheckedIn && _checkOutTime != null
                      ? const Color(0xFF993C1D)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: !_isCheckedIn && _checkOutTime != null
                        ? Colors.transparent
                        : const Color(0xFFE8E6E0),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (!_isCheckedIn && _checkOutTime != null
                                  ? const Color(0xFF993C1D)
                                  : Colors.black)
                              .withOpacity(
                                !_isCheckedIn && _checkOutTime != null
                                    ? 0.3
                                    : 0.05,
                              ),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: !_isCheckedIn && _checkOutTime != null
                            ? Colors.white.withOpacity(0.2)
                            : const Color(0xFFFAECE7),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: !_isCheckedIn && _checkOutTime != null
                            ? Colors.white
                            : const Color(0xFF993C1D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Check Out',
                      style: TextStyle(
                        color: !_isCheckedIn && _checkOutTime != null
                            ? Colors.white
                            : const Color(0xFF1A1A1A),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Timeline Card ────────────────────────────────────────────────────────
  Widget _buildTimelineCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E6E0), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TODAY'S SESSION",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF888780),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _TimelineRow(
            label: 'Check In',
            time: _checkInTime != null
                ? _formatTime(_checkInTime!)
                : '--:-- --',
            icon: Icons.login_rounded,
            iconBg: const Color(0xFFE6F1FB),
            iconColor: const Color(0xFF185FA5),
            isActive: _checkInTime != null,
          ),
          const _TimelineConnector(),
          _TimelineRow(
            label: 'Check Out',
            time: _checkOutTime != null
                ? _formatTime(_checkOutTime!)
                : _isCheckedIn
                ? 'In progress...'
                : '--:-- --',
            icon: Icons.logout_rounded,
            iconBg: const Color(0xFFFAECE7),
            iconColor: const Color(0xFF993C1D),
            isActive: _checkOutTime != null,
            isPending: _isCheckedIn,
          ),
        ],
      ),
    );
  }

  // ── Activity Log ─────────────────────────────────────────────────────────
  Widget _buildActivityLog() {
    final logs = [
      _LogEntry(time: '09:00 AM', label: 'Checked In', isIn: true),
      _LogEntry(time: '01:05 PM', label: 'Checked Out', isIn: false),
      _LogEntry(time: '01:45 PM', label: 'Checked In', isIn: true),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E6E0), width: 0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                const Text(
                  'ACTIVITY LOG',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF888780),
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEDE6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF5F5E5A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0EEE8)),
          ...List.generate(logs.length, (i) {
            final log = logs[i];
            final isLast = i == logs.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: log.isIn
                              ? const Color(0xFFE6F1FB)
                              : const Color(0xFFFAECE7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          log.isIn ? Icons.login_rounded : Icons.logout_rounded,
                          size: 16,
                          color: log.isIn
                              ? const Color(0xFF185FA5)
                              : const Color(0xFF993C1D),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        log.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        log.time,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF888780),
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    color: Color(0xFFF0EEE8),
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Time Label ────────────────────────────────────────────────────────────
class _TimeLabel extends StatelessWidget {
  final String label;
  const _TimeLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Color(0xFFBBB9B3),
        letterSpacing: 0.5,
      ),
    );
  }
}

// ── Pulse Dot ─────────────────────────────────────────────────────────────
class _PulseDot extends StatefulWidget {
  final Color color;
  final bool active;
  const _PulseDot({required this.color, this.active = true});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _opacity = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withOpacity(0.4),
        ),
      );
    }
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
      ),
    );
  }
}

// ── Timeline Row ──────────────────────────────────────────────────────────
class _TimelineRow extends StatelessWidget {
  final String label;
  final String time;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool isActive;
  final bool isPending;

  const _TimelineRow({
    required this.label,
    required this.time,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.isActive = false,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isActive ? iconBg : const Color(0xFFF5F4F1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            size: 17,
            color: isActive ? iconColor : const Color(0xFFBBB9B3),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isActive
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFFBBB9B3),
            ),
          ),
        ),
        Text(
          time,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isPending
                ? const Color(0xFF1D9E75)
                : isActive
                ? const Color(0xFF1A1A1A)
                : const Color(0xFFBBB9B3),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ── Timeline Connector ────────────────────────────────────────────────────
class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 19, top: 4, bottom: 4),
      child: Container(width: 1, height: 20, color: const Color(0xFFE8E6E0)),
    );
  }
}

// ── Log Entry Model ───────────────────────────────────────────────────────
class _LogEntry {
  final String time;
  final String label;
  final bool isIn;
  const _LogEntry({
    required this.time,
    required this.label,
    required this.isIn,
  });
}
