import 'package:flutter/material.dart';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/screens/admin/admin_users_screen.dart';
import 'package:aurat_ride/screens/admin/admin_rides_screen.dart';
import 'package:aurat_ride/screens/admin/admin_analytics_screen.dart';
import 'package:aurat_ride/screens/admin/admin_support_screen.dart';
import 'package:aurat_ride/screens/admin/admin_settings_screen.dart';
import 'package:aurat_ride/screens/login/login_screen/login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? dashboardData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final token = await UserService.getToken();
      if (token == null) {
        setState(() {
          error = 'No authentication token found';
          isLoading = false;
        });
        return;
      }

      final response = await ApiService.getAdminDashboard(token);
      
      if (response['status'] == true) {
        setState(() {
          dashboardData = response['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = response['message'] ?? 'Failed to load dashboard data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading dashboard: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await UserService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: kPrimaryWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kPrimaryGreen,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: kPrimaryWhite),
            onPressed: _loadDashboardData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: kPrimaryWhite),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadDashboardData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildOverviewCards(),
                        const SizedBox(height: 24),
                        _buildQuickActions(),
                        const SizedBox(height: 24),
                        _buildRecentActivity(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildOverviewCards() {
    if (dashboardData == null) return const SizedBox();

    final overview = dashboardData!['overview'] as Map<String, dynamic>;
    final today = dashboardData!['today'] as Map<String, dynamic>;
    final thisMonth = dashboardData!['this_month'] as Map<String, dynamic>;
    final growth = dashboardData!['growth'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              'Total Users',
              overview['total_users'].toString(),
              Icons.people,
              kPrimaryGreen,
            ),
            _buildStatCard(
              'Total Rides',
              overview['total_rides'].toString(),
              Icons.local_taxi,
              Colors.blue,
            ),
            _buildStatCard(
              'Total Earnings',
              'Rs. ${overview['total_earnings'].toString()}',
              Icons.attach_money,
              Colors.orange,
            ),
            _buildStatCard(
              'Today\'s Rides',
              today['rides'].toString(),
              Icons.today,
              Colors.purple,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'This Month Rides',
                thisMonth['rides'].toString(),
                Icons.calendar_month,
                Colors.teal,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'This Month Earnings',
                'Rs. ${thisMonth['earnings'].toString()}',
                Icons.trending_up,
                Colors.indigo,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildGrowthCard(
                'Ride Growth',
                '${growth['rides_growth'].toString()}%',
                growth['rides_growth'] >= 0 ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildGrowthCard(
                'Earnings Growth',
                '${growth['earnings_growth'].toString()}%',
                growth['earnings_growth'] >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                color == Colors.green ? Icons.trending_up : Icons.trending_down,
                color: color,
                size: 24,
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              'Manage Users',
              Icons.people,
              kPrimaryGreen,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminUsersScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Manage Rides',
              Icons.local_taxi,
              Colors.blue,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminRidesScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Analytics',
              Icons.analytics,
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminAnalyticsScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Support Messages',
              Icons.support_agent,
              Colors.purple,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminSupportScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Settings',
              Icons.settings,
              Colors.teal,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminSettingsScreen(),
                ),
              ),
            ),
            _buildActionCard(
              'Refresh Data',
              Icons.refresh,
              Colors.indigo,
              _loadDashboardData,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    if (dashboardData == null) return const SizedBox();

    final recentRides = dashboardData!['recent_rides'] as List<dynamic>;
    final recentUsers = dashboardData!['recent_users'] as List<dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActivitySection('Recent Rides', recentRides, Icons.local_taxi),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActivitySection('Recent Users', recentUsers, Icons.person_add),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivitySection(String title, List<dynamic> items, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.take(5).map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: kPrimaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title == 'Recent Rides' 
                        ? 'Ride #${item['id']} - ${item['status']}'
                        : '${item['name']} (${item['role']})',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
