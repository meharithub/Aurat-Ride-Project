import 'package:flutter/material.dart';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';

class AdminRidesScreen extends StatefulWidget {
  const AdminRidesScreen({super.key});

  @override
  State<AdminRidesScreen> createState() => _AdminRidesScreenState();
}

class _AdminRidesScreenState extends State<AdminRidesScreen> {
  List<dynamic> rides = [];
  bool isLoading = true;
  String? error;
  int currentPage = 1;
  int totalPages = 1;
  String? selectedStatus;
  String? dateFrom;
  String? dateTo;
  final TextEditingController dateFromController = TextEditingController();
  final TextEditingController dateToController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRides();
  }

  @override
  void dispose() {
    dateFromController.dispose();
    dateToController.dispose();
    super.dispose();
  }

  Future<void> _loadRides({bool refresh = false}) async {
    try {
      if (refresh) {
        setState(() {
          currentPage = 1;
          isLoading = true;
          error = null;
        });
      }

      final token = await UserService.getToken();
      if (token == null) {
        setState(() {
          error = 'No authentication token found';
          isLoading = false;
        });
        return;
      }

      final response = await ApiService.getAdminRides(
        token: token,
        page: currentPage,
        status: selectedStatus,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );
      
      if (response['status'] == true) {
        setState(() {
          if (refresh) {
            rides = response['data']['data'] as List<dynamic>;
          } else {
            rides.addAll(response['data']['data'] as List<dynamic>);
          }
          totalPages = response['data']['last_page'] as int;
          isLoading = false;
        });
      } else {
        setState(() {
          error = response['message'] ?? 'Failed to load rides';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading rides: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _updateRideStatus(int rideId, String status, {String? canceledBy}) async {
    try {
      final token = await UserService.getToken();
      if (token == null) return;

      final response = await ApiService.updateRideStatus(
        token: token,
        rideId: rideId,
        status: status,
        canceledBy: canceledBy,
      );

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ride status updated successfully')),
        );
        _loadRides(refresh: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update ride')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating ride: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        title: const Text(
          'Manage Rides',
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
            onPressed: () => _loadRides(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: isLoading && rides.isEmpty
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
                              onPressed: () => _loadRides(refresh: true),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : rides.isEmpty
                        ? const Center(
                            child: Text(
                              'No rides found',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _loadRides(refresh: true),
                            child: ListView.builder(
                              itemCount: rides.length + (currentPage < totalPages ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == rides.length) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            currentPage++;
                                          });
                                          _loadRides();
                                        },
                                        child: const Text('Load More'),
                                      ),
                                    ),
                                  );
                                }
                                return _buildRideCard(rides[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Status')),
                    DropdownMenuItem(value: 'pending', child: Text('Pending')),
                    DropdownMenuItem(value: 'accepted', child: Text('Accepted')),
                    DropdownMenuItem(value: 'started', child: Text('Started')),
                    DropdownMenuItem(value: 'completed', child: Text('Completed')),
                    DropdownMenuItem(value: 'canceled', child: Text('Canceled')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                    _loadRides(refresh: true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: dateFromController,
                  decoration: const InputDecoration(
                    labelText: 'From Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      dateFromController.text = date.toIso8601String().split('T')[0];
                      setState(() {
                        dateFrom = date.toIso8601String().split('T')[0];
                      });
                      _loadRides(refresh: true);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: dateToController,
                  decoration: const InputDecoration(
                    labelText: 'To Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      dateToController.text = date.toIso8601String().split('T')[0];
                      setState(() {
                        dateTo = date.toIso8601String().split('T')[0];
                      });
                      _loadRides(refresh: true);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedStatus = null;
                    dateFrom = null;
                    dateTo = null;
                    dateFromController.clear();
                    dateToController.clear();
                  });
                  _loadRides(refresh: true);
                },
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRideCard(Map<String, dynamic> ride) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ride #${ride['id']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(ride['status']),
              ],
            ),
            const SizedBox(height: 8),
            if (ride['rider'] != null)
              Text('Rider: ${ride['rider']['name']} (${ride['rider']['phone']})'),
            if (ride['driver'] != null)
              Text('Driver: ${ride['driver']['name']} (${ride['driver']['phone']})'),
            const SizedBox(height: 8),
            Text('From: ${ride['pickup_address'] ?? 'N/A'}'),
            Text('To: ${ride['dropoff_address'] ?? 'N/A'}'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('Distance: ${ride['distance_km']?.toStringAsFixed(2) ?? 'N/A'} km'),
                ),
                Text('Fare: Rs. ${ride['final_fare']?.toString() ?? ride['estimated_fare']?.toString() ?? 'N/A'}'),
              ],
            ),
            const SizedBox(height: 8),
            Text('Created: ${_formatDate(ride['created_at'])}'),
            if (ride['started_at'] != null)
              Text('Started: ${_formatDate(ride['started_at'])}'),
            if (ride['completed_at'] != null)
              Text('Completed: ${_formatDate(ride['completed_at'])}'),
            if (ride['canceled_at'] != null)
              Text('Canceled: ${_formatDate(ride['canceled_at'])}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showStatusDialog(ride),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Update Status'),
                ),
                ElevatedButton(
                  onPressed: () => _showRideDetails(ride),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'pending':
        color = Colors.orange;
        break;
      case 'accepted':
        color = Colors.blue;
        break;
      case 'started':
        color = Colors.purple;
        break;
      case 'completed':
        color = Colors.green;
        break;
      case 'canceled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  void _showStatusDialog(Map<String, dynamic> ride) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Ride #${ride['id']} Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Pending'),
              leading: Radio<String>(
                value: 'pending',
                groupValue: ride['status'],
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateRideStatus(ride['id'], 'pending');
                },
              ),
            ),
            ListTile(
              title: const Text('Accepted'),
              leading: Radio<String>(
                value: 'accepted',
                groupValue: ride['status'],
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateRideStatus(ride['id'], 'accepted');
                },
              ),
            ),
            ListTile(
              title: const Text('Started'),
              leading: Radio<String>(
                value: 'started',
                groupValue: ride['status'],
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateRideStatus(ride['id'], 'started');
                },
              ),
            ),
            ListTile(
              title: const Text('Completed'),
              leading: Radio<String>(
                value: 'completed',
                groupValue: ride['status'],
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateRideStatus(ride['id'], 'completed');
                },
              ),
            ),
            ListTile(
              title: const Text('Canceled'),
              leading: Radio<String>(
                value: 'canceled',
                groupValue: ride['status'],
                onChanged: (value) {
                  Navigator.pop(context);
                  _showCancelReasonDialog(ride['id']);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCancelReasonDialog(int rideId) {
    String? cancelReason;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Ride'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select cancellation reason:'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: cancelReason,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'rider', child: Text('Rider Canceled')),
                DropdownMenuItem(value: 'driver', child: Text('Driver Canceled')),
                DropdownMenuItem(value: 'admin', child: Text('Admin Canceled')),
              ],
              onChanged: (value) {
                cancelReason = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (cancelReason != null) {
                Navigator.pop(context);
                _updateRideStatus(rideId, 'canceled', canceledBy: cancelReason);
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showRideDetails(Map<String, dynamic> ride) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ride #${ride['id']} Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Status', ride['status']),
              _buildDetailRow('Rider', ride['rider']?['name'] ?? 'N/A'),
              _buildDetailRow('Driver', ride['driver']?['name'] ?? 'N/A'),
              _buildDetailRow('Pickup', ride['pickup_address'] ?? 'N/A'),
              _buildDetailRow('Dropoff', ride['dropoff_address'] ?? 'N/A'),
              _buildDetailRow('Distance', '${ride['distance_km']?.toStringAsFixed(2) ?? 'N/A'} km'),
              _buildDetailRow('Estimated Fare', 'Rs. ${ride['estimated_fare']?.toString() ?? 'N/A'}'),
              _buildDetailRow('Final Fare', 'Rs. ${ride['final_fare']?.toString() ?? 'N/A'}'),
              _buildDetailRow('Payment Method', ride['payment_method'] ?? 'N/A'),
              _buildDetailRow('Payment Status', ride['payment_status'] ?? 'N/A'),
              _buildDetailRow('Created', _formatDate(ride['created_at'])),
              if (ride['started_at'] != null)
                _buildDetailRow('Started', _formatDate(ride['started_at'])),
              if (ride['completed_at'] != null)
                _buildDetailRow('Completed', _formatDate(ride['completed_at'])),
              if (ride['canceled_at'] != null)
                _buildDetailRow('Canceled', _formatDate(ride['canceled_at'])),
              if (ride['canceled_by'] != null)
                _buildDetailRow('Canceled By', ride['canceled_by']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
