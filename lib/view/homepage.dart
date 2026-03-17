import 'package:flutter/material.dart';
import 'package:screen_arts_app/view/job_detail_screen.dart';

// ── Dummy Data ─────────────────────────────────────────────────────────────────

final List<Map<String, dynamic>> dummyJobs = [
  {
    'jobOrderId': 'JO-2024-001',
    'serviceType': 'Large Format Printing',
    'operation': 'Digital Print & Lamination',
    'status': 'In Progress',
    'itemName': 'Outdoor Flex Banner',
    'description': 'Full-colour outdoor banner with UV-resistant ink.',
    'copies': 50,
    'size': '10 ft × 4 ft',
    'material': 'Star Flex 270gsm',
    'colors': 'CMYK (Full Colour)',
    'totalCost': 5110.00,
    'startDate': '18 Mar 2024',
    'endDate': '21 Mar 2024',
    'employees': [
      {'name': 'Rajan Kumar', 'role': 'Print Operator'},
      {'name': 'Aisha Banu', 'role': 'Lamination Technician'},
      {'name': 'Dev Sharma', 'role': 'Quality Check'},
    ],
    'notes': 'Satin finish lamination on both sides. Eyelets every 2 ft.',
  },
  {
    'jobOrderId': 'JO-2024-002',
    'serviceType': 'Offset Printing',
    'operation': 'Sheet-fed Offset + UV Coating',
    'status': 'Pending',
    'itemName': 'Corporate Business Cards',
    'description': '400gsm matte board with spot UV on logo.',
    'copies': 500,
    'size': '90 mm × 55 mm',
    'material': 'Matt Art 400gsm',
    'colors': '4+0 (One Side)',
    'totalCost': 3204.00,
    'startDate': '20 Mar 2024',
    'endDate': '22 Mar 2024',
    'employees': [
      {'name': 'Rajan Kumar', 'role': 'Press Operator'},
      {'name': 'Priya Nair', 'role': 'UV Coating Specialist'},
    ],
    'notes': 'Embossed logo on front. Bleed 3mm on all sides.',
  },
  {
    'jobOrderId': 'JO-2024-003',
    'serviceType': 'Screen Printing',
    'operation': 'Multi-colour Screen Print',
    'status': 'Completed',
    'itemName': 'Promotional T-Shirts',
    'description': 'Front & back logo print on cotton tees.',
    'copies': 200,
    'size': 'A4 print area',
    'material': '100% Cotton 180gsm',
    'colors': 'Pantone 2 Colors',
    'totalCost': 12940.00,
    'startDate': '10 Mar 2024',
    'endDate': '15 Mar 2024',
    'employees': [
      {'name': 'Rajan Kumar', 'role': 'Screen Printer'},
      {'name': 'Aisha Banu', 'role': 'Colour Mixing'},
      {'name': 'Vijay Menon', 'role': 'Curing Operator'},
      {'name': 'Priya Nair', 'role': 'Packing'},
    ],
    'notes': 'Flash cure between passes. Deliver folded in polybag.',
  },
  {
    'jobOrderId': 'JO-2024-004',
    'serviceType': 'Digital Printing',
    'operation': 'Roll-to-Roll Print',
    'status': 'In Progress',
    'itemName': 'Window Vinyl Stickers',
    'description': 'Transparent vinyl with white base for windows.',
    'copies': 100,
    'size': '60 cm × 90 cm',
    'material': 'Clear Vinyl 80mic',
    'colors': 'CMYK + White',
    'totalCost': 7080.00,
    'startDate': '16 Mar 2024',
    'endDate': '18 Mar 2024',
    'employees': [
      {'name': 'Rajan Kumar', 'role': 'Machine Operator'},
      {'name': 'Dev Sharma', 'role': 'Finishing'},
    ],
    'notes': 'Apply cold laminate. Cut to shape with 2mm offset.',
  },
  {
    'jobOrderId': 'JO-2024-005',
    'serviceType': 'Finishing & Binding',
    'operation': 'Perfect Binding',
    'status': 'Pending',
    'itemName': 'Company Annual Report',
    'description': '100-page report with glossy cover.',
    'copies': 300,
    'size': 'A4 (210 × 297 mm)',
    'material': 'Book Wove 80gsm / Cover 300gsm',
    'colors': '4+4 (Full Both Sides)',
    'totalCost': 21040.00,
    'startDate': '22 Mar 2024',
    'endDate': '28 Mar 2024',
    'employees': [
      {'name': 'Rajan Kumar', 'role': 'Binding Operator'},
      {'name': 'Vijay Menon', 'role': 'Cover Lamination'},
    ],
    'notes': 'Glossy lamination on cover. Shrink-wrap in sets of 25.',
  },
];

// ── Homepage ───────────────────────────────────────────────────────────────────

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'In Progress', 'Pending', 'Completed'];

  // Refined Color Palette
  final Color primaryColor = const Color(0xFF6366F1); // Indigo
  final Color backgroundColor = const Color(0xFFF8FAFC);
  final Color cardColor = Colors.white;

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 'All') return dummyJobs;
    return dummyJobs.where((j) => j['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterBar(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              '${_filtered.length} Active Assignments',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) => _JobCard(
                      job: _filtered[index],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              JobDetailScreen(job: _filtered[index]),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: cardColor,
      elevation: 0,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.1),
            child: Text(
              "RK",
              style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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
              Text(
                'Rajan Kumar • Print Master',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      color: cardColor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final f = _filters[index];
          final isSelected = f == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: ChoiceChip(
              label: Text(f),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = f),
              selectedColor: const Color(0xFF1E293B),
              backgroundColor: const Color(0xFFF1F5F9),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF64748B),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              elevation: 0,
              pressElevation: 0,
              side: BorderSide.none,
            ),
          );
        },
      ),
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
}

class _JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
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
    final statusColor = _getStatusColor(job['status']);

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
                      job['jobOrderId'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  _StatusBadge(status: job['status'], color: statusColor),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                job['itemName'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                job['serviceType'],
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
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
                    '${job['startDate']} - ${job['endDate']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Color(0xFF94A3B8),
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
