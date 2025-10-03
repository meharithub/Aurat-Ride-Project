import 'package:flutter/material.dart';
import 'package:aurat_ride/services/api_service.dart';
import 'package:aurat_ride/services/user_service.dart';
import 'package:aurat_ride/utlils/theme/colors.dart';
import 'package:aurat_ride/utlils/helper_functions/helper_function.dart';
import 'package:aurat_ride/screens/admin/admin_register_driver_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  String? error;
  int currentPage = 1;
  int totalPages = 1;
  String? selectedRole;
  String? selectedStatus;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({bool refresh = false}) async {
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

      final response = await ApiService.getAdminUsers(
        token: token,
        page: currentPage,
        role: selectedRole,
        search: searchQuery.isNotEmpty ? searchQuery : null,
        status: selectedStatus,
      );
      
      if (response['status'] == true) {
        setState(() {
          if (refresh) {
            users = response['data']['data'] as List<dynamic>;
          } else {
            users.addAll(response['data']['data'] as List<dynamic>);
          }
          totalPages = response['data']['last_page'] as int;
          isLoading = false;
        });
      } else {
        setState(() {
          error = response['message'] ?? 'Failed to load users';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error loading users: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _searchUsers() async {
    setState(() {
      searchQuery = searchController.text;
      currentPage = 1;
    });
    await _loadUsers(refresh: true);
  }

  Future<void> _updateUserStatus(int userId, Map<String, bool> updates) async {
    try {
      final token = await UserService.getToken();
      if (token == null) return;

      final response = await ApiService.updateUserStatus(
        token: token,
        userId: userId,
        isProfileVerified: updates['isProfileVerified'],
        isOnline: updates['isOnline'],
        isEmailVerified: updates['isEmailVerified'],
        isPhoneVerified: updates['isPhoneVerified'],
      );

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User status updated successfully')),
        );
        _loadUsers(refresh: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to update user')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user: $e')),
      );
    }
  }

  Future<void> _deleteUser(int userId) async {
    try {
      final token = await UserService.getToken();
      if (token == null) return;

      final response = await ApiService.deleteUser(token, userId);

      if (response['status'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
        _loadUsers(refresh: true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Failed to delete user')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
    }
  }

  Future<void> _navigateToRegisterDriver() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminRegisterDriverScreen(),
      ),
    );
    
    // Refresh users list if a driver was successfully registered
    if (result == true) {
      _loadUsers(refresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryWhite,
      appBar: AppBar(
        title: const Text(
          'Manage Users',
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
            icon: const Icon(Icons.person_add, color: kPrimaryWhite),
            onPressed: _navigateToRegisterDriver,
            tooltip: 'Register Driver',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: kPrimaryWhite),
            onPressed: () => _loadUsers(refresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: isLoading && users.isEmpty
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
                              onPressed: () => _loadUsers(refresh: true),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : users.isEmpty
                        ? const Center(
                            child: Text(
                              'No users found',
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _loadUsers(refresh: true),
                            child: ListView.builder(
                              itemCount: users.length + (currentPage < totalPages ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == users.length) {
                                  return Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            currentPage++;
                                          });
                                          _loadUsers();
                                        },
                                        child: const Text('Load More'),
                                      ),
                                    ),
                                  );
                                }
                                return _buildUserCard(users[index]);
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
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchController.clear();
                  _searchUsers();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => _searchUsers(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Roles')),
                    DropdownMenuItem(value: 'Rider', child: Text('Rider')),
                    DropdownMenuItem(value: 'Driver', child: Text('Driver')),
                    DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRole = value;
                    });
                    _loadUsers(refresh: true);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Status')),
                    DropdownMenuItem(value: 'verified', child: Text('Verified')),
                    DropdownMenuItem(value: 'unverified', child: Text('Unverified')),
                    DropdownMenuItem(value: 'online', child: Text('Online')),
                    DropdownMenuItem(value: 'offline', child: Text('Offline')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                    _loadUsers(refresh: true);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRoleColor(user['role']),
          child: Text(
            user['name'][0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          user['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${user['email']} • ${user['phone']}',
              overflow: TextOverflow.ellipsis,
            ),
            Text('Role: ${user['role']}'),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _buildStatusChip('Profile', user['is_profile_verified']),
                _buildStatusChip('Email', user['is_email_verified']),
                _buildStatusChip('Phone', user['is_phone_verified']),
                _buildStatusChip('Online', user['is_online']),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditUserDialog(user);
            } else if (value == 'delete') {
              _showDeleteUserDialog(user);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, bool status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
      decoration: BoxDecoration(
        color: status ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: ${status ? 'Yes' : 'No'}',
        style: TextStyle(
          fontSize: 9,
          color: status ? Colors.green[800] : Colors.red[800],
        ),
      ),
    );
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

  void _showEditUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${user['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Profile Verified'),
              value: user['is_profile_verified'] ?? false,
              onChanged: (value) {
                _updateUserStatus(user['id'], {'isProfileVerified': value});
                Navigator.pop(context);
              },
            ),
            SwitchListTile(
              title: const Text('Email Verified'),
              value: user['is_email_verified'] ?? false,
              onChanged: (value) {
                _updateUserStatus(user['id'], {'isEmailVerified': value});
                Navigator.pop(context);
              },
            ),
            SwitchListTile(
              title: const Text('Phone Verified'),
              value: user['is_phone_verified'] ?? false,
              onChanged: (value) {
                _updateUserStatus(user['id'], {'isPhoneVerified': value});
                Navigator.pop(context);
              },
            ),
            SwitchListTile(
              title: const Text('Online Status'),
              value: user['is_online'] ?? false,
              onChanged: (value) {
                _updateUserStatus(user['id'], {'isOnline': value});
                Navigator.pop(context);
              },
            ),
          ],
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

  void _showDeleteUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user['id']);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
