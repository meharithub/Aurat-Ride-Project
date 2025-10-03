import 'package:flutter/material.dart';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';

class AdminSupportScreen extends StatefulWidget {
  const AdminSupportScreen({super.key});

  @override
  State<AdminSupportScreen> createState() => _AdminSupportScreenState();
}

class _AdminSupportScreenState extends State<AdminSupportScreen> {
  List<dynamic> messages = [];
  bool isLoading = true;
  String? error;
  int currentPage = 1;
  int totalPages = 1;
  String? selectedStatus;
  final TextEditingController responseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    responseController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages({bool refresh = false}) async {
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

      final response = await ApiService.getAdminSupportMessages(
        token: token,
        page: currentPage,
        status: selectedStatus,
      );
      
      if (response['status'] == true) {
        setState(() {
          if (refresh) {
            messages = response['data']['data'] as List<dynamic>;
          } else {
            messages.addAll(response['data']['data'] as List<dynamic>);
          }
          totalPages = response['data']['last_page'] as int;
          isLoading = false;
        });
      } else {
        setState(() {
          error = response['message'] ?? 'Failed to load support messages';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading support messages: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _updateMessageStatus(int messageId, String status, {String? adminResponse}) async {
    try {
      final token = await UserService.getToken();
      if (token == null) return;

      final response = await ApiService.updateSupportMessage(
        token: token,
        messageId: messageId,
        status: status,
        adminResponse: adminResponse,
      );

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message status updated successfully')),
        );
        _loadMessages(refresh: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update message')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        title: const Text(
          'Support Messages',
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
            onPressed: () => _loadMessages(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: isLoading && messages.isEmpty
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
                              onPressed: () => _loadMessages(refresh: true),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : messages.isEmpty
                        ? const Center(
                            child: Text(
                              'No support messages found',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _loadMessages(refresh: true),
                            child: ListView.builder(
                              itemCount: messages.length + (currentPage < totalPages ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == messages.length) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            currentPage++;
                                          });
                                          _loadMessages();
                                        },
                                        child: const Text('Load More'),
                                      ),
                                    ),
                                  );
                                }
                                return _buildMessageCard(messages[index]);
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
      child: Row(
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
                DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                DropdownMenuItem(value: 'closed', child: Text('Closed')),
              ],
              onChanged: (value) {
                setState(() {
                  selectedStatus = value;
                });
                _loadMessages(refresh: true);
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedStatus = null;
              });
              _loadMessages(refresh: true);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard(Map<String, dynamic> message) {
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
                  'Message #${message['id']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(message['status']),
              ],
            ),
            const SizedBox(height: 8),
            if (message['user'] != null)
              Text(
                'From: ${message['user']['name']} (${message['user']['email']})',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'Subject: ${message['subject'] ?? 'No Subject'}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message['message'],
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Received: ${_formatDate(message['created_at'])}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            if (message['admin_response'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Response:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      message['admin_response'],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _showMessageDetails(message),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('View Details'),
                ),
                ElevatedButton(
                  onPressed: () => _showResponseDialog(message),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Respond'),
                ),
                ElevatedButton(
                  onPressed: () => _showStatusDialog(message),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Update Status'),
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
      case 'resolved':
        color = Colors.green;
        break;
      case 'closed':
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

  void _showMessageDetails(Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Message #${message['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('From', message['user']?['name'] ?? 'Unknown'),
              _buildDetailRow('Email', message['user']?['email'] ?? 'N/A'),
              _buildDetailRow('Subject', message['subject'] ?? 'No Subject'),
              _buildDetailRow('Status', message['status']),
              _buildDetailRow('Received', _formatDate(message['created_at'])),
              const SizedBox(height: 16),
              const Text(
                'Message:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(message['message']),
              if (message['admin_response'] != null) ...[
                const SizedBox(height: 16),
                const Text(
                  'Admin Response:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(message['admin_response']),
                ),
              ],
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

  void _showResponseDialog(Map<String, dynamic> message) {
    responseController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Respond to Message #${message['id']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: responseController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Your Response',
                border: OutlineInputBorder(),
                hintText: 'Type your response here...',
              ),
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
              if (responseController.text.isNotEmpty) {
                Navigator.pop(context);
                _updateMessageStatus(
                  message['id'],
                  'resolved',
                  adminResponse: responseController.text,
                );
              }
            },
            child: const Text('Send Response'),
          ),
        ],
      ),
    );
  }

  void _showStatusDialog(Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Message #${message['id']} Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Pending'),
              leading: Radio<String>(
                value: 'pending',
                groupValue: message['status'],
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateMessageStatus(message['id'], 'pending');
                },
              ),
            ),
            ListTile(
              title: const Text('Resolved'),
              leading: Radio<String>(
                value: 'resolved',
                groupValue: message['status'],
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateMessageStatus(message['id'], 'resolved');
                },
              ),
            ),
            ListTile(
              title: const Text('Closed'),
              leading: Radio<String>(
                value: 'closed',
                groupValue: message['status'],
                onChanged: (value) {
                  Navigator.pop(context);
                  _updateMessageStatus(message['id'], 'closed');
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
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
