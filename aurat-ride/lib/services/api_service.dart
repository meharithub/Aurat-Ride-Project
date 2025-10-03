import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URLs
  static const String baseUrlLocal = 'http://192.168.18.67:8000/api';
  //static const String baseUrlLocalhost = 'http://localhost:8000/api';
  static const String baseUrlLive = 'https://riderbackend.vexronics.com/api';
  
  // Use local URL for development, change to baseUrlLive for production
  static const String baseUrl = baseUrlLocal;
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> getAuthHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  // ==================== AUTHENTICATION ====================
  
  /// Register a new user
  /// Valid roles: 'Rider', 'Driver'
  /// Valid genders: 'Male', 'Female'
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role, // 'Rider' or 'Driver'
    required String cnic,
    required String gender, // 'Male' or 'Female'
    String? selfie, // For multipart upload
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: defaultHeaders,
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
        'cnic': cnic,
        'gender': gender,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Login user
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: defaultHeaders,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Check authentication status
  static Future<Map<String, dynamic>> checkAuth(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/check'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Send OTP
  static Future<Map<String, dynamic>> sendOtp({
    required String type,
    required String recipient,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/otp/send'),
      headers: defaultHeaders,
      body: jsonEncode({
        'type': type,
        'recipient': recipient,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Verify OTP
  static Future<Map<String, dynamic>> verifyOtp({
    required String recipient,
    required String code,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/otp/verify'),
      headers: defaultHeaders,
      body: jsonEncode({
        'recipient': recipient,
        'code': code,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Logout user
  static Future<Map<String, dynamic>> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Reset password
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/password/reset'),
      headers: defaultHeaders,
      body: jsonEncode({
        'email': email,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Change password
  static Future<Map<String, dynamic>> changePassword({
    required String token,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/password/change'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Refresh token
  static Future<Map<String, dynamic>> refreshToken(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Google login
  static Future<Map<String, dynamic>> googleLogin({
    required String googleId,
    required String email,
    required String name,
    String? profilePicture,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: defaultHeaders,
      body: jsonEncode({
        'google_id': googleId,
        'email': email,
        'name': name,
        if (profilePicture != null) 'profile_picture': profilePicture,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Facebook login
  static Future<Map<String, dynamic>> facebookLogin({
    required String facebookId,
    required String email,
    required String name,
    String? profilePicture,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/facebook'),
      headers: defaultHeaders,
      body: jsonEncode({
        'facebook_id': facebookId,
        'email': email,
        'name': name,
        if (profilePicture != null) 'profile_picture': profilePicture,
      }),
    );
    
    return _handleResponse(response);
  }

  // ==================== APP CONFIG ====================
  
  /// Get app configuration
  static Future<Map<String, dynamic>> getAppConfig() async {
    final response = await http.get(
      Uri.parse('$baseUrl/app/config'),
      headers: defaultHeaders,
    );
    
    return _handleResponse(response);
  }
  
  /// Get terms and conditions
  static Future<Map<String, dynamic>> getTerms() async {
    final response = await http.get(
      Uri.parse('$baseUrl/content/terms'),
      headers: defaultHeaders,
    );
    
    return _handleResponse(response);
  }
  
  /// Get privacy policy
  static Future<Map<String, dynamic>> getPrivacy() async {
    final response = await http.get(
      Uri.parse('$baseUrl/content/privacy'),
      headers: defaultHeaders,
    );
    
    return _handleResponse(response);
  }

  // ==================== PROFILE ====================
  
  /// Get user profile
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/me'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? name,
    String? email,
    String? phone,
    String? password,
    String? cnic,
    String? gender,
    String? profilePicUrl,
    String? selfie,
  }) async {
    final Map<String, dynamic> body = {};
    if (name != null) body['name'] = name;
    if (email != null) body['email'] = email;
    if (phone != null) body['phone'] = phone;
    if (password != null) body['password'] = password;
    if (cnic != null) body['cnic'] = cnic;
    if (gender != null) body['gender'] = gender;
    if (profilePicUrl != null) body['profile_pic_url'] = profilePicUrl;
    if (selfie != null) body['selfie'] = selfie;
    
    final response = await http.put(
      Uri.parse('$baseUrl/user/me'),
      headers: getAuthHeaders(token),
      body: jsonEncode(body),
    );
    
    return _handleResponse(response);
  }
  
  /// Update user gender
  static Future<Map<String, dynamic>> updateGender({
    required String token,
    required String gender,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/gender'),
      headers: getAuthHeaders(token),
      body: jsonEncode({'gender': gender}),
    );
    
    return _handleResponse(response);
  }

  // ==================== RIDE BOOKING ====================
  
  /// Get ride quote
  static Future<Map<String, dynamic>> getRideQuote({
    required double pickupLat,
    required double pickupLng,
    required double dropoffLat,
    required double dropoffLng,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rides/quote'),
      headers: defaultHeaders,
      body: jsonEncode({
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'dropoff_lat': dropoffLat,
        'dropoff_lng': dropoffLng,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Request a ride
  static Future<Map<String, dynamic>> requestRide({
    required String token,
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String dropoffAddress,
    String? polyline,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rides/request'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'pickup_address': pickupAddress,
        'dropoff_lat': dropoffLat,
        'dropoff_lng': dropoffLng,
        'dropoff_address': dropoffAddress,
        if (polyline != null) 'polyline': polyline,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Get all rides
  static Future<Map<String, dynamic>> getRides(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rides'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Get specific ride
  static Future<Map<String, dynamic>> getRide({
    required String token,
    required String rideId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rides/$rideId'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Cancel ride
  static Future<Map<String, dynamic>> cancelRide({
    required String token,
    required String rideId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rides/$rideId/cancel'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Start ride (Driver)
  static Future<Map<String, dynamic>> startRide({
    required String token,
    required String rideId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rides/$rideId/start'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Complete ride (Driver)
  static Future<Map<String, dynamic>> completeRide({
    required String token,
    required String rideId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rides/$rideId/complete'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Get live tracking
  static Future<Map<String, dynamic>> getLiveTracking({
    required String token,
    required String rideId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rides/$rideId/live'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }

  // ==================== DRIVER ====================
  
  /// Go online/offline
  static Future<Map<String, dynamic>> updateDriverStatus({
    required String token,
    required bool isOnline,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/driver/online'),
      headers: getAuthHeaders(token),
      body: jsonEncode({'is_online': isOnline}),
    );
    
    return _handleResponse(response);
  }
  
  /// Update driver location
  static Future<Map<String, dynamic>> updateDriverLocation({
    required String token,
    required double lat,
    required double lng,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/driver/location'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'lat': lat,
        'lng': lng,
      }),
    );
    
    return _handleResponse(response);
  }

  // ==================== RATING ====================
  
  /// Rate a ride
  static Future<Map<String, dynamic>> rateRide({
    required String token,
    required String rideId,
    required int rating,
    String? comment,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rides/$rideId/rate'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'rating': rating,
        if (comment != null) 'comment': comment,
      }),
    );
    
    return _handleResponse(response);
  }

  // ==================== SUPPORT ====================
  
  /// Contact support
  static Future<Map<String, dynamic>> contactSupport({
    required String subject,
    required String message,
    String? name,
    String? email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/support/contact'),
      headers: defaultHeaders,
      body: jsonEncode({
        'subject': subject,
        'message': message,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
      }),
    );
    
    return _handleResponse(response);
  }

  // ==================== PAYMENT ====================
  
  /// Get payment methods
  static Future<Map<String, dynamic>> getPaymentMethods(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/payment-methods'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Add payment method
  static Future<Map<String, dynamic>> addPaymentMethod({
    required String token,
    required String type,
    required String details,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/payment-methods'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'type': type,
        'details': details,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Process payment
  static Future<Map<String, dynamic>> processPayment({
    required String token,
    required String rideId,
    required String paymentMethodId,
    required double amount,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments/process'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'ride_id': rideId,
        'payment_method_id': paymentMethodId,
        'amount': amount,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Get wallet balance
  static Future<Map<String, dynamic>> getWalletBalance(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/wallet'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Add money to wallet
  static Future<Map<String, dynamic>> addToWallet({
    required String token,
    required double amount,
    required String paymentMethodId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/wallet'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'amount': amount,
        'payment_method_id': paymentMethodId,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Get transaction history
  static Future<Map<String, dynamic>> getTransactionHistory(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/transactions'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }

  // ==================== ENHANCED DRIVER ====================
  
  /// Get driver earnings
  static Future<Map<String, dynamic>> getDriverEarnings(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/driver/earnings'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Get driver statistics
  static Future<Map<String, dynamic>> getDriverStats(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/driver/stats'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Get nearby drivers
  static Future<Map<String, dynamic>> getNearbyDrivers({
    required double lat,
    required double lng,
    double radius = 5.0,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/drivers/nearby?lat=$lat&lng=$lng&radius=$radius'),
      headers: defaultHeaders,
    );
    
    return _handleResponse(response);
  }

  // ==================== LOCATION MANAGEMENT ====================
  
  /// Get favorite locations
  static Future<Map<String, dynamic>> getFavoriteLocations(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/favorites'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Add favorite location
  static Future<Map<String, dynamic>> addFavoriteLocation({
    required String token,
    required String name,
    required double lat,
    required double lng,
    required String address,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/favorites'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'name': name,
        'lat': lat,
        'lng': lng,
        'address': address,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Get recent locations
  static Future<Map<String, dynamic>> getRecentLocations(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/recent-locations'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }

  // ==================== NOTIFICATIONS ====================
  
  /// Get notifications
  static Future<Map<String, dynamic>> getNotifications(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/notifications'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Mark notification as read
  static Future<Map<String, dynamic>> markNotificationRead({
    required String token,
    required String notificationId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/notifications/$notificationId/read'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }

  // ==================== SAFETY & SECURITY ====================
  
  /// Send emergency SOS
  static Future<Map<String, dynamic>> sendEmergencySOS({
    required String token,
    required double lat,
    required double lng,
    String? message,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/emergency/sos'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'lat': lat,
        'lng': lng,
        if (message != null) 'message': message,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Report safety issue
  static Future<Map<String, dynamic>> reportSafetyIssue({
    required String token,
    required String rideId,
    required String issueType,
    required String description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/safety/report'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'ride_id': rideId,
        'issue_type': issueType,
        'description': description,
      }),
    );
    
    return _handleResponse(response);
  }

  // ==================== CHAT ====================
  
  /// Get messages for a ride
  static Future<Map<String, dynamic>> getRideMessages({
    required String token,
    required String rideId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rides/$rideId/messages'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Send a message
  static Future<Map<String, dynamic>> sendRideMessage({
    required String token,
    required String rideId,
    required String message,
    String type = 'text',
    Map<String, dynamic>? metadata,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rides/$rideId/messages'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'message': message,
        'type': type,
        if (metadata != null) 'metadata': metadata,
      }),
    );
    
    return _handleResponse(response);
  }
  
  /// Mark messages as read
  static Future<Map<String, dynamic>> markRideMessagesAsRead({
    required String token,
    required String rideId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rides/$rideId/messages/read'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }
  
  /// Get unread message count
  static Future<Map<String, dynamic>> getRideUnreadCount({
    required String token,
    required String rideId,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/rides/$rideId/messages/unread-count'),
      headers: getAuthHeaders(token),
    );
    
    return _handleResponse(response);
  }

  // ==================== HELPER METHODS ====================
  
  /// Handle HTTP response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          'success': true,
          'statusCode': response.statusCode,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'error': data['message'] ?? 'Unknown error occurred',
          'data': data,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'statusCode': response.statusCode,
        'error': 'Failed to parse response: $e',
        'data': null,
      };
    }
  }
  
  /// Switch between local and live URLs
  static void switchToLocal() {
    // This would require making baseUrl non-const
    // For now, manually change baseUrl constant above
  }
  
  static void switchToLive() {
    // This would require making baseUrl non-const
    // For now, manually change baseUrl constant above
  }

  // ==================== DRIVER METHODS ====================
  
  /// Set driver online/offline status
  static Future<Map<String, dynamic>> setDriverOnline({
    required String token,
    required bool isOnline,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/driver/set-online'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'is_online': isOnline,
      }),
    );

    return jsonDecode(response.body);
  }

  /// Accept a ride request
  static Future<Map<String, dynamic>> acceptRide({
    required String token,
    required String rideId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/driver/accept-ride'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'ride_id': rideId,
      }),
    );

    return jsonDecode(response.body);
  }

  // ==================== ADMIN API METHODS ====================

  /// Get admin dashboard statistics
  static Future<Map<String, dynamic>> getAdminDashboard(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard'),
      headers: getAuthHeaders(token),
    );
    return jsonDecode(response.body);
  }

  /// Get all users with pagination and filters
  static Future<Map<String, dynamic>> getAdminUsers({
    required String token,
    int page = 1,
    int perPage = 15,
    String? role,
    String? search,
    String? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    
    if (role != null) queryParams['role'] = role;
    if (search != null) queryParams['search'] = search;
    if (status != null) queryParams['status'] = status;

    final uri = Uri.parse('$baseUrl/admin/users').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(uri, headers: getAuthHeaders(token));
    return jsonDecode(response.body);
  }

  /// Get user details by ID
  static Future<Map<String, dynamic>> getAdminUserDetails(String token, int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users/$userId'),
      headers: getAuthHeaders(token),
    );
    return jsonDecode(response.body);
  }

  /// Update user status
  static Future<Map<String, dynamic>> updateUserStatus({
    required String token,
    required int userId,
    bool? isProfileVerified,
    bool? isOnline,
    bool? isEmailVerified,
    bool? isPhoneVerified,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/users/$userId/status'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        if (isProfileVerified != null) 'is_profile_verified': isProfileVerified,
        if (isOnline != null) 'is_online': isOnline,
        if (isEmailVerified != null) 'is_email_verified': isEmailVerified,
        if (isPhoneVerified != null) 'is_phone_verified': isPhoneVerified,
      }),
    );
    return jsonDecode(response.body);
  }

  /// Delete user
  static Future<Map<String, dynamic>> deleteUser(String token, int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/users/$userId'),
      headers: getAuthHeaders(token),
    );
    return jsonDecode(response.body);
  }

  /// Get all rides with pagination and filters
  static Future<Map<String, dynamic>> getAdminRides({
    required String token,
    int page = 1,
    int perPage = 15,
    String? status,
    String? dateFrom,
    String? dateTo,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    
    if (status != null) queryParams['status'] = status;
    if (dateFrom != null) queryParams['date_from'] = dateFrom;
    if (dateTo != null) queryParams['date_to'] = dateTo;

    final uri = Uri.parse('$baseUrl/admin/rides').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(uri, headers: getAuthHeaders(token));
    return jsonDecode(response.body);
  }

  /// Get ride details by ID
  static Future<Map<String, dynamic>> getAdminRideDetails(String token, int rideId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/rides/$rideId'),
      headers: getAuthHeaders(token),
    );
    return jsonDecode(response.body);
  }

  /// Update ride status
  static Future<Map<String, dynamic>> updateRideStatus({
    required String token,
    required int rideId,
    required String status,
    String? canceledBy,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/rides/$rideId/status'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'status': status,
        if (canceledBy != null) 'canceled_by': canceledBy,
      }),
    );
    return jsonDecode(response.body);
  }

  /// Get analytics data
  static Future<Map<String, dynamic>> getAdminAnalytics({
    required String token,
    int period = 30,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/analytics?period=$period'),
      headers: getAuthHeaders(token),
    );
    return jsonDecode(response.body);
  }

  /// Get support messages
  static Future<Map<String, dynamic>> getAdminSupportMessages({
    required String token,
    int page = 1,
    int perPage = 15,
    String? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    
    if (status != null) queryParams['status'] = status;

    final uri = Uri.parse('$baseUrl/admin/support-messages').replace(
      queryParameters: queryParams,
    );

    final response = await http.get(uri, headers: getAuthHeaders(token));
    return jsonDecode(response.body);
  }

  /// Update support message
  static Future<Map<String, dynamic>> updateSupportMessage({
    required String token,
    required int messageId,
    required String status,
    String? adminResponse,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/support-messages/$messageId'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'status': status,
        if (adminResponse != null) 'admin_response': adminResponse,
      }),
    );
    return jsonDecode(response.body);
  }

  /// Get app settings
  static Future<Map<String, dynamic>> getAdminSettings(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/settings'),
      headers: getAuthHeaders(token),
    );
    return jsonDecode(response.body);
  }

  /// Update app settings
  static Future<Map<String, dynamic>> updateAdminSettings({
    required String token,
    required Map<String, dynamic> settings,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/settings'),
      headers: getAuthHeaders(token),
      body: jsonEncode(settings),
    );
    return jsonDecode(response.body);
  }

  /// Register a new driver by admin
  static Future<Map<String, dynamic>> registerDriver({
    required String token,
    required String name,
    required String email,
    required String phone,
    required String password,
    required String gender,
    required String cnic,
    required String drivingLicense,
    required String vehicleModel,
    required String vehicleNumber,
    int? vehicleYear,
    String? vehicleColor,
    // File uploads would be handled separately with multipart requests
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/drivers/register'),
      headers: getAuthHeaders(token),
      body: jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'gender': gender,
        'cnic': cnic,
        'driving_license': drivingLicense,
        'vehicle_model': vehicleModel,
        'vehicle_number': vehicleNumber,
        if (vehicleYear != null) 'vehicle_year': vehicleYear,
        if (vehicleColor != null) 'vehicle_color': vehicleColor,
      }),
    );
    return jsonDecode(response.body);
  }
}
