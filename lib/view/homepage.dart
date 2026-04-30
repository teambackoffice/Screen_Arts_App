import 'package:flutter/material.dart';
import 'package:screen_arts_app/view/checkin/check_in.dart';
import 'package:screen_arts_app/view/job_orders.dart';

class MainHomepage extends StatefulWidget {
  const MainHomepage({super.key});

  @override
  State<MainHomepage> createState() => _MainHomepageState();
}

class _MainHomepageState extends State<MainHomepage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
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
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildTopBar()),
                SliverToBoxAdapter(child: _buildStatusStrip()),
                SliverToBoxAdapter(
                  child: _buildSectionHeader('Management hub'),
                ),
                SliverToBoxAdapter(child: _buildActionGrid(context)),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Top Bar ──────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning,',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Alex Sterling',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF185FA5),
                  border: Border.all(color: Colors.white, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF185FA5).withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'AS',
                    style: TextStyle(
                      color: Color(0xFFE6F1FB),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Status Strip ─────────────────────────────────────────────────────────
  Widget _buildStatusStrip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E6E0), width: 0.5),
        ),
        child: Row(
          children: [
            _PulseDot(),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF888780),
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  TextSpan(text: 'Status: '),
                  TextSpan(
                    text: 'Checked In',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(text: ' · 08:42 AM'),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE1F5EE),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: const Color(0xFF9FE1CB), width: 0.5),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F6E56),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ───────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF888780),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ── Stats Row ────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'Open orders',
              value: '14',
              badge: '+3 today',
              badgePositive: true,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'Completed',
              value: '87',
              badge: 'This month',
              badgePositive: false,
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Grid ──────────────────────────────────────────────────────────
  Widget _buildActionGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _ActionCard(
              title: 'Job Order',
              subtitle: 'Add new order',
              icon: Icons.grid_view_rounded,
              iconBg: const Color(0xFFEEEDFE),
              iconColor: const Color(0xFF534AB7),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JobOrders()),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionCard(
              title: 'Check In / Out',
              subtitle: 'Update status',
              icon: Icons.schedule_rounded,
              iconBg: const Color(0xFFFAECE7),
              iconColor: const Color(0xFF993C1D),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckInOut()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pulse Dot ─────────────────────────────────────────────────────────────
class _PulseDot extends StatefulWidget {
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
      end: 0.35,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFF1D9E75),
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String badge;
  final bool badgePositive;

  const _StatCard({
    required this.label,
    required this.value,
    required this.badge,
    required this.badgePositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEDE6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF888780),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: badgePositive
                  ? const Color(0xFFE1F5EE)
                  : const Color(0xFFE8E6E0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: badgePositive
                    ? const Color(0xFF0F6E56)
                    : const Color(0xFF5F5E5A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action Card ───────────────────────────────────────────────────────────
class _ActionCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 155,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8E6E0), width: 0.5),
          ),
          child: Stack(
            children: [
              // Arrow top-right
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F4F1),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: const Icon(
                    Icons.arrow_outward_rounded,
                    size: 13,
                    color: Color(0xFF888780),
                  ),
                ),
              ),
              // Content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: widget.iconBg,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(widget.icon, color: widget.iconColor, size: 20),
                  ),
                  const Spacer(),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888780),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
