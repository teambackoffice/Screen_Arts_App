import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screen_arts_app/controller/check_in_out_controller.dart';
import 'package:screen_arts_app/controller/get_check_controller.dart';

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

    // Fetch real status on open
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchInitialStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageAnimCtrl.dispose();
    _checkInBtnCtrl.dispose();
    _checkOutBtnCtrl.dispose();
    super.dispose();
  }

  // ── Fetch status on load ─────────────────────────────────────────────────
  Future<void> _fetchInitialStatus() async {
    final statusCtrl = context.read<CheckinStatusController>();
    await statusCtrl.fetchStatus();

    if (!mounted) return;

    final data = statusCtrl.statusData;
    if (data == null) return;

    final isIn = data.logType.toUpperCase() == 'IN';
    final parsed = _parseApiTime(data.time);

    setState(() {
      _isCheckedIn = isIn;
      if (isIn) {
        _checkInTime = parsed;
        _checkOutTime = null;
        _elapsed = parsed != null
            ? DateTime.now().difference(parsed)
            : Duration.zero;
        if (parsed != null) _startTimer();
      } else {
        _checkOutTime = parsed;
        _checkInTime = null;
        _timer?.cancel();
      }
    });
  }

  DateTime? _parseApiTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_checkInTime != null) {
        setState(() => _elapsed = DateTime.now().difference(_checkInTime!));
      }
    });
  }

  // ── Check In ──────────────────────────────────────────────────────────────
  Future<void> _handleCheckIn() async {
    if (_isCheckedIn) return;

    final controller = context.read<CheckinController>();
    await controller.markCheckin('IN');

    if (!mounted) return;

    if (controller.errorMessage != null) {
      _showSnackbar(controller.errorMessage!, isError: true);
      return;
    }

    setState(() {
      _isCheckedIn = true;
      _checkInTime = DateTime.now();
      _checkOutTime = null;
      _elapsed = Duration.zero;
    });
    _startTimer();

    // Refresh status from server
    context.read<CheckinStatusController>().fetchStatus();
    _showSnackbar(controller.successMessage ?? 'Checked in successfully!');
  }

  // ── Check Out ─────────────────────────────────────────────────────────────
  Future<void> _handleCheckOut() async {
    if (!_isCheckedIn) return;

    final controller = context.read<CheckinController>();
    await controller.markCheckin('OUT');

    if (!mounted) return;

    if (controller.errorMessage != null) {
      _showSnackbar(controller.errorMessage!, isError: true);
      return;
    }

    setState(() {
      _isCheckedIn = false;
      _checkOutTime = DateTime.now();
      _timer?.cancel();
    });

    // Refresh status from server
    context.read<CheckinStatusController>().fetchStatus();
    _showSnackbar(controller.successMessage ?? 'Checked out successfully!');
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFF993C1D)
            : const Color(0xFF1D9E75),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m:$s $period';
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
    final statusCtrl = context.watch<CheckinStatusController>();

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
                // Full-screen loader only on first load
                if (statusCtrl.isLoading && statusCtrl.statusData == null)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF185FA5),
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildDateCard(),
                          const SizedBox(height: 16),
                          _buildStatusCard(statusCtrl),
                          const SizedBox(height: 20),
                          _buildButtons(),
                          const SizedBox(height: 20),
                          _buildTimelineCard(),
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

  // ── Top Bar ───────────────────────────────────────────────────────────────
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
            ],
          ),
        ),
        const Divider(height: 1, thickness: 1, color: Color(0xFFF0EEE8)),
      ],
    );
  }

  // ── Date Card ─────────────────────────────────────────────────────────────
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

  // ── Status Card ───────────────────────────────────────────────────────────
  Widget _buildStatusCard(CheckinStatusController statusCtrl) {
    final apiData = statusCtrl.statusData;
    final bool isIn = apiData != null
        ? apiData.logType.toUpperCase() == 'IN'
        : _isCheckedIn;

    final Color dotColor = isIn
        ? const Color(0xFF1D9E75)
        : const Color(0xFF888780);
    final Color bgColor = isIn
        ? const Color(0xFFE1F5EE)
        : const Color(0xFFF5F4F1);

    // IN / OUT badge colours
    final Color badgeBg = isIn
        ? const Color(0xFF1D9E75).withOpacity(0.15)
        : const Color(0xFF993C1D).withOpacity(0.12);
    final Color badgeText = isIn
        ? const Color(0xFF1D9E75)
        : const Color(0xFF993C1D);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dotColor.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          _PulseDot(color: dotColor, active: isIn),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                isIn ? 'Currently Checked In' : 'Not Checked In',
                key: ValueKey(isIn),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: dotColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // ── Log-type badge (IN / OUT from API) ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isIn ? 'IN' : 'OUT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: badgeText,
                letterSpacing: 0.6,
              ),
            ),
          ),
          if (isIn && _checkInTime != null) ...[
            const SizedBox(width: 8),
            Text(
              'Since ${_checkInTime!.hour % 12 == 0 ? 12 : _checkInTime!.hour % 12}:${_checkInTime!.minute.toString().padLeft(2, '0')} ${_checkInTime!.hour >= 12 ? 'PM' : 'AM'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: dotColor.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Buttons ───────────────────────────────────────────────────────────────
  Widget _buildButtons() {
    final isActionLoading = context.watch<CheckinController>().isLoading;

    return Row(
      children: [
        // CHECK IN
        Expanded(
          child: ScaleTransition(
            scale: _checkInScale,
            child: GestureDetector(
              onTapDown: isActionLoading || _isCheckedIn
                  ? null
                  : (_) => _checkInBtnCtrl.forward(),
              onTapUp: isActionLoading || _isCheckedIn
                  ? null
                  : (_) {
                      _checkInBtnCtrl.reverse();
                      _handleCheckIn();
                    },
              onTapCancel: isActionLoading || _isCheckedIn
                  ? null
                  : () => _checkInBtnCtrl.reverse(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 72,
                decoration: BoxDecoration(
                  color: _isCheckedIn ? Colors.white : const Color(0xFF185FA5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isCheckedIn
                        ? const Color(0xFFE8E6E0)
                        : Colors.transparent,
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isCheckedIn
                          ? Colors.black.withOpacity(0.05)
                          : const Color(0xFF185FA5).withOpacity(0.38),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isActionLoading && !_isCheckedIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _isCheckedIn
                                  ? const Color(0xFFF5F4F1)
                                  : Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              Icons.login_rounded,
                              color: _isCheckedIn
                                  ? const Color(0xFFBBB9B3)
                                  : Colors.white,
                              size: 18,
                            ),
                          ),
                    const SizedBox(height: 6),
                    Text(
                      'Check In',
                      style: TextStyle(
                        color: _isCheckedIn
                            ? const Color(0xFFBBB9B3)
                            : Colors.white,
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

        // CHECK OUT
        Expanded(
          child: ScaleTransition(
            scale: _checkOutScale,
            child: GestureDetector(
              onTapDown: isActionLoading || !_isCheckedIn
                  ? null
                  : (_) => _checkOutBtnCtrl.forward(),
              onTapUp: isActionLoading || !_isCheckedIn
                  ? null
                  : (_) {
                      _checkOutBtnCtrl.reverse();
                      _handleCheckOut();
                    },
              onTapCancel: isActionLoading || !_isCheckedIn
                  ? null
                  : () => _checkOutBtnCtrl.reverse(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 72,
                decoration: BoxDecoration(
                  color: _isCheckedIn ? const Color(0xFF993C1D) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _isCheckedIn
                        ? Colors.transparent
                        : const Color(0xFFE8E6E0),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isCheckedIn
                          ? const Color(0xFF993C1D).withOpacity(0.3)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    isActionLoading && _isCheckedIn
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _isCheckedIn
                                  ? Colors.white.withOpacity(0.2)
                                  : const Color(0xFFF5F4F1),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                              size: 18,
                              color: _isCheckedIn
                                  ? Colors.white
                                  : const Color(0xFFBBB9B3),
                            ),
                          ),
                    const SizedBox(height: 6),
                    Text(
                      'Check Out',
                      style: TextStyle(
                        color: _isCheckedIn
                            ? Colors.white
                            : const Color(0xFFBBB9B3),
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

  // ── Timeline Card ─────────────────────────────────────────────────────────
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

  // // ── Activity Log ──────────────────────────────────────────────────────────
  // Widget _buildActivityLog(CheckinStatusController statusCtrl) {
  //   final apiData = statusCtrl.statusData;
  //   final List<_LogEntry> logs = [];

  //   if (apiData != null && apiData.time.isNotEmpty) {
  //     final parsed = _parseApiTime(apiData.time);
  //     if (parsed != null) {
  //       final isIn = apiData.logType.toUpperCase() == 'IN';
  //       final h = parsed.hour % 12 == 0 ? 12 : parsed.hour % 12;
  //       final m = parsed.minute.toString().padLeft(2, '0');
  //       final period = parsed.hour >= 12 ? 'PM' : 'AM';
  //       logs.add(
  //         _LogEntry(
  //           time: '$h:$m $period',
  //           label: isIn ? 'Checked In' : 'Checked Out',
  //           isIn: isIn,
  //         ),
  //       );
  //     }
  //   }

  //   Widget header = Padding(
  //     padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
  //     child: Row(
  //       children: [
  //         const Text(
  //           'ACTIVITY LOG',
  //           style: TextStyle(
  //             fontSize: 10,
  //             fontWeight: FontWeight.w700,
  //             color: Color(0xFF888780),
  //             letterSpacing: 1.2,
  //           ),
  //         ),
  //         const Spacer(),
  //         Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFFEFEDE6),
  //             borderRadius: BorderRadius.circular(6),
  //           ),
  //           child: const Text(
  //             'Today',
  //             style: TextStyle(
  //               fontSize: 11,
  //               fontWeight: FontWeight.w500,
  //               color: Color(0xFF5F5E5A),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );

  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: const Color(0xFFE8E6E0), width: 0.5),
  //     ),
  //     child: Column(
  //       children: [
  //         header,
  //         const Divider(height: 1, color: Color(0xFFF0EEE8)),

  //         // ── Empty state ──
  //         if (logs.isEmpty)
  //           const Padding(
  //             padding: EdgeInsets.symmetric(vertical: 24),
  //             child: Column(
  //               children: [
  //                 Icon(
  //                   Icons.history_rounded,
  //                   size: 28,
  //                   color: Color(0xFFBBB9B3),
  //                 ),
  //                 SizedBox(height: 8),
  //                 Text(
  //                   'No activity yet today',
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     color: Color(0xFFBBB9B3),
  //                     fontWeight: FontWeight.w500,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           )
  //         else
  //           ...List.generate(logs.length, (i) {
  //             final log = logs[i];
  //             final isLast = i == logs.length - 1;
  //             return Column(
  //               children: [
  //                 Padding(
  //                   padding: const EdgeInsets.symmetric(
  //                     horizontal: 16,
  //                     vertical: 12,
  //                   ),
  //                   child: Row(
  //                     children: [
  //                       Container(
  //                         width: 34,
  //                         height: 34,
  //                         decoration: BoxDecoration(
  //                           color: log.isIn
  //                               ? const Color(0xFFE6F1FB)
  //                               : const Color(0xFFFAECE7),
  //                           borderRadius: BorderRadius.circular(10),
  //                         ),
  //                         child: Icon(
  //                           log.isIn
  //                               ? Icons.login_rounded
  //                               : Icons.logout_rounded,
  //                           size: 16,
  //                           color: log.isIn
  //                               ? const Color(0xFF185FA5)
  //                               : const Color(0xFF993C1D),
  //                         ),
  //                       ),
  //                       const SizedBox(width: 12),
  //                       Column(
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Text(
  //                             log.label,
  //                             style: const TextStyle(
  //                               fontSize: 14,
  //                               fontWeight: FontWeight.w500,
  //                               color: Color(0xFF1A1A1A),
  //                             ),
  //                           ),
  //                           const SizedBox(height: 3),
  //                           // ── Log type badge ──
  //                           Container(
  //                             padding: const EdgeInsets.symmetric(
  //                               horizontal: 7,
  //                               vertical: 2,
  //                             ),
  //                             decoration: BoxDecoration(
  //                               color: log.isIn
  //                                   ? const Color(0xFF1D9E75).withOpacity(0.12)
  //                                   : const Color(0xFF993C1D).withOpacity(0.10),
  //                               borderRadius: BorderRadius.circular(5),
  //                             ),
  //                             child: Text(
  //                               log.isIn ? 'IN' : 'OUT',
  //                               style: TextStyle(
  //                                 fontSize: 10,
  //                                 fontWeight: FontWeight.w700,
  //                                 letterSpacing: 0.5,
  //                                 color: log.isIn
  //                                     ? const Color(0xFF1D9E75)
  //                                     : const Color(0xFF993C1D),
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const Spacer(),
  //                       Text(
  //                         log.time,
  //                         style: const TextStyle(
  //                           fontSize: 13,
  //                           fontWeight: FontWeight.w500,
  //                           color: Color(0xFF888780),
  //                           fontFeatures: [FontFeature.tabularFigures()],
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 if (!isLast)
  //                   const Divider(
  //                     height: 1,
  //                     color: Color(0xFFF0EEE8),
  //                     indent: 16,
  //                     endIndent: 16,
  //                   ),
  //               ],
  //             );
  //           }),
  //       ],
  //     ),
  //   );
  // }
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
