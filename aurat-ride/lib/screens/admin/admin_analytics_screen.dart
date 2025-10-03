import 'package:flutter/material.dart';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  Map<String, dynamic>? analyticsData;
  bool isLoading = true;
  String? error;
  int selectedPeriod = 30;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
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

      final response = await ApiService.getAdminAnalytics(
        token: token,
        period: selectedPeriod,
      );
      
      if (response['status'] == true) {
        setState(() {
          analyticsData = response['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = response['message'] ?? 'Failed to load analytics';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading analytics: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(
            color: kPrimaryWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kPrimaryGreen,
        elevation: 0,
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list, color: kPrimaryWhite),
            onSelected: (value) {
              setState(() {
                selectedPeriod = value;
              });
              _loadAnalytics();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 7,
                child: Text('Last 7 days'),
              ),
              const PopupMenuItem(
                value: 30,
                child: Text('Last 30 days'),
              ),
              const PopupMenuItem(
                value: 90,
                child: Text('Last 90 days'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: kPrimaryWhite),
            onPressed: _loadAnalytics,
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
                        onPressed: _loadAnalytics,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAnalytics,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPeriodSelector(),
                        const SizedBox(height: 24),
                        _buildRideAnalytics(),
                        const SizedBox(height: 24),
                        _buildUserAnalytics(),
                        const SizedBox(height: 24),
                        _buildDistributionCharts(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: kPrimaryGreen),
          const SizedBox(width: 8),
          Text(
            'Analytics for last $selectedPeriod days',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRideAnalytics() {
    if (analyticsData == null) return const SizedBox();

    final rideAnalytics = analyticsData!['ride_analytics'] as List<dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ride Analytics',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Rides & Earnings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${rideAnalytics.length} days',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (rideAnalytics.isEmpty)
                const Center(
                  child: Text(
                    'No data available for the selected period',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...rideAnalytics.map((data) => _buildRideDataRow(data)).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRideDataRow(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(data['date']),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              '${data['rides']} rides',
              style: const TextStyle(color: Colors.blue),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Rs. ${data['earnings']?.toStringAsFixed(0) ?? '0'}',
              style: const TextStyle(color: Colors.green),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAnalytics() {
    if (analyticsData == null) return const SizedBox();

    final userAnalytics = analyticsData!['user_analytics'] as List<dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'User Registration Analytics',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: kPrimaryGreen,
          ),
        ),
        const SizedBox(height: 16),
        Container(
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
            children: [
              const Text(
                'Daily User Registrations by Role',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (userAnalytics.isEmpty)
                const Center(
                  child: Text(
                    'No data available for the selected period',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              else
                ...userAnalytics.map((data) => _buildUserDataRow(data)).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserDataRow(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              _formatDate(data['date']),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Riders: ${data['count']}',
                style: const TextStyle(
                  color: Colors.blue,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Drivers: ${data['count']}',
                style: const TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionCharts() {
    if (analyticsData == null) return const SizedBox();

    final rideStatusDistribution = analyticsData!['ride_status_distribution'] as List<dynamic>;
    final userRoleDistribution = analyticsData!['user_role_distribution'] as List<dynamic>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribution Charts',
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
              child: _buildDistributionCard(
                'Ride Status Distribution',
                rideStatusDistribution,
                _getStatusColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDistributionCard(
                'User Role Distribution',
                userRoleDistribution,
                _getRoleColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDistributionCard(
    String title,
    List<dynamic> data,
    Color Function(String) colorFunction,
  ) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (data.isEmpty)
            const Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...data.map((item) => _buildDistributionItem(
              item['status'] ?? item['role'],
              item['count'],
              colorFunction(item['status'] ?? item['role']),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildDistributionItem(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 12),
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'started':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.red;
      case 'Driver':
        return Colors.blue;
      case 'Rider':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}';
    } catch (e) {
      return dateString;
    }
  }
}
