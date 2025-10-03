<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use App\Models\Ride;
use App\Models\Rating;
use App\Models\Transaction;
use App\Models\ContactMessage;
use App\Models\DriverLocation;
use App\Models\Setting;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AdminController extends Controller
{
    // ==================== DASHBOARD STATISTICS ====================
    
    public function getDashboardStats(Request $request)
    {
        try {
            $user = $request->user();
            if ($user->role !== 'Admin') {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $today = Carbon::today();
            $thisMonth = Carbon::now()->startOfMonth();
            $lastMonth = Carbon::now()->subMonth()->startOfMonth();

            // Basic counts
            $totalUsers = User::count();
            $totalRiders = User::where('role', 'Rider')->count();
            $totalDrivers = User::where('role', 'Driver')->count();
            $totalRides = Ride::count();
            $totalEarnings = Transaction::where('type', 'ride_payment')->sum('amount');

            // Today's stats
            $todayRides = Ride::whereDate('created_at', $today)->count();
            $todayEarnings = Transaction::where('type', 'ride_payment')
                ->whereDate('created_at', $today)
                ->sum('amount');

            // This month's stats
            $monthRides = Ride::where('created_at', '>=', $thisMonth)->count();
            $monthEarnings = Transaction::where('type', 'ride_payment')
                ->where('created_at', '>=', $thisMonth)
                ->sum('amount');

            // Last month's stats
            $lastMonthRides = Ride::whereBetween('created_at', [
                $lastMonth, 
                $thisMonth
            ])->count();
            $lastMonthEarnings = Transaction::where('type', 'ride_payment')
                ->whereBetween('created_at', [$lastMonth, $thisMonth])
                ->sum('amount');

            // Growth calculations
            $rideGrowth = $lastMonthRides > 0 ? 
                (($monthRides - $lastMonthRides) / $lastMonthRides) * 100 : 0;
            $earningsGrowth = $lastMonthEarnings > 0 ? 
                (($monthEarnings - $lastMonthEarnings) / $lastMonthEarnings) * 100 : 0;

            // Recent activities
            $recentRides = Ride::with(['rider', 'driver'])
                ->orderBy('created_at', 'desc')
                ->limit(10)
                ->get();

            $recentUsers = User::orderBy('created_at', 'desc')
                ->limit(10)
                ->get();

            return response()->json([
                'status' => true,
                'data' => [
                    'overview' => [
                        'total_users' => $totalUsers,
                        'total_riders' => $totalRiders,
                        'total_drivers' => $totalDrivers,
                        'total_rides' => $totalRides,
                        'total_earnings' => $totalEarnings,
                    ],
                    'today' => [
                        'rides' => $todayRides,
                        'earnings' => $todayEarnings,
                    ],
                    'this_month' => [
                        'rides' => $monthRides,
                        'earnings' => $monthEarnings,
                    ],
                    'growth' => [
                        'rides_growth' => round($rideGrowth, 2),
                        'earnings_growth' => round($earningsGrowth, 2),
                    ],
                    'recent_rides' => $recentRides,
                    'recent_users' => $recentUsers,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // ==================== USER MANAGEMENT ====================

    public function getUsers(Request $request)
    {
        try {
            $user = $request->user();
            if ($user->role !== 'Admin') {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $perPage = $request->get('per_page', 15);
            $role = $request->get('role');
            $search = $request->get('search');
            $status = $request->get('status');

            $query = User::query();

            if ($role) {
                $query->where('role', $role);
            }

            if ($search) {
                $query->where(function($q) use ($search) {
                    $q->where('name', 'like', "%{$search}%")
                      ->orWhere('email', 'like', "%{$search}%")
                      ->orWhere('phone', 'like', "%{$search}%");
                });
            }

            if ($status) {
                if ($status === 'verified') {
                    $query->where('is_profile_verified', true);
                } elseif ($status === 'unverified') {
                    $query->where('is_profile_verified', false);
                } elseif ($status === 'online') {
                    $query->where('is_online', true);
                } elseif ($status === 'offline') {
                    $query->where('is_online', false);
                }
            }

            $users = $query->orderBy('created_at', 'desc')
                ->paginate($perPage);

            return response()->json([
                'status' => true,
                'data' => $users
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    public function getUserDetails(Request $request, $id)
    {
        try {
            $user = $request->user();
            if ($user->role !== 'Admin') {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $userDetails = User::with(['ridesAsRider', 'ridesAsDriver'])
                ->findOrFail($id);

            // Get user statistics
            $totalRides = $userDetails->ridesAsRider->count() + $userDetails->ridesAsDriver->count();
            $completedRides = $userDetails->ridesAsRider->where('status', 'completed')->count() + 
                             $userDetails->ridesAsDriver->where('status', 'completed')->count();
            $totalEarnings = $userDetails->ridesAsDriver->where('status', 'completed')->sum('final_fare');

            return response()->json([
                'status' => true,
                'data' => [
                    'user' => $userDetails,
                    'stats' => [
                        'total_rides' => $totalRides,
                        'completed_rides' => $completedRides,
                        'total_earnings' => $totalEarnings,
                    ]
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    public function updateUserStatus(Request $request, $id)
    {
        try {
            $user = $request->user();
            if ($user->role !== 'Admin') {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $validator = Validator::make($request->all(), [
                'is_profile_verified' => 'boolean',
                'is_online' => 'boolean',
                'is_email_verified' => 'boolean',
                'is_phone_verified' => 'boolean',
            ]);

            if ($validator->fails()) {
                return response()->json(['errors' => $validator->errors()], 422);
            }

            $targetUser = User::findOrFail($id);
            $targetUser->update($request->only([
                'is_profile_verified',
                'is_online',
                'is_email_verified',
                'is_phone_verified'
            ]));

            return response()->json([
                'status' => true,
                'message' => 'User status updated successfully',
                'data' => $targetUser
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    public function deleteUser(Request $request, $id)
    {
        try {
            $user = $request->user();
            if ($user->role !== 'Admin') {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $targetUser = User::findOrFail($id);
            
            // Don't allow admin to delete themselves
            if ($targetUser->id === $user->id) {
                return response()->json(['message' => 'Cannot delete your own account'], 400);
            }

            $targetUser->delete();

            return response()->json([
                'status' => true,
                'message' => 'User deleted successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // ==================== RIDE MANAGEMENT ====================

    public function getRides(Request $request)
    {
        try {
            $user = $request->user();
            if ($user->role !== 'Admin') {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $perPage = $request->get('per_page', 15);
            $status = $request->get('status');
            $dateFrom = $request->get('date_from');
            $dateTo = $request->get('date_to');

            $query = Ride::with(['rider', 'driver']);

            if ($status) {
                $query->where('status', $status);
            }

            if ($dateFrom) {
                $query->whereDate('created_at', '>=', $dateFrom);
            }

            if ($dateTo) {
                $query->whereDate('created_at', '<=', $dateTo);
            }

            $rides = $query->orderBy('created_at', 'desc')
                ->paginate($perPage);

            return response()->json([
                'status' => true,
                'data' => $rides
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    public function getRideDetails(Request $request, $id)
    {
        try {
            $user = $request->user();
            if ($user->role !== 'Admin') {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $ride = Ride::with(['rider', 'driver', 'ratings'])
                ->findOrFail($id);

            return response()->json([
                'status' => true,
                'data' => $ride
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    public function updateRideStatus(Request $request, $id)
    {
        try {
            $user = $request->user();
            if ($user->role !== 'Admin') {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $validator = Validator::make($request->all(), [
                'status' => 'required|in:pending,accepted,started,completed,canceled',
                'canceled_by' => 'required_if:status,canceled|in:rider,driver,admin',
            ]);

            if ($validator->fails()) {
                return response()->json(['errors' => $validator->errors()], 422);
            }

            $ride = Ride::findOrFail($id);
            $ride->update($request->only(['status', 'canceled_by']));

            if ($request->status === 'canceled') {
                $ride->update(['canceled_at' => now()]);
            }

            return response()->json([
                'status' => true,
                'message' => 'Ride status updated successfully',
                'data' => $ride
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // ==================== ANALYTICS ====================

    public function getAnalytics(Request $request)
    {
        try {
            $user = $request->user();
            if ($user->role !== 'Admin') {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $period = $request->get('period', '30'); // days
            $startDate = Carbon::now()->subDays($period);

            // Ride analytics
            $rideAnalytics = Ride::where('created_at', '>=', $startDate)
                ->selectRaw('DATE(created_at) as date, COUNT(*) as rides, SUM(final_fare) as earnings')
                ->groupBy('date')
                ->orderBy('date')
                ->get();

            // User registration analytics
            $userAnalytics = User::where('created_at', '>=', $startDate)
                ->selectRaw('DATE(created_at) as date, role, COUNT(*) as count')
                ->groupBy('date', 'role')
                ->orderBy('date')
                ->get();

            // Status distribution
            $rideStatusDistribution = Ride::selectRaw('status, COUNT(*) as count')
                ->groupBy('status')
                ->get();

            $userRoleDistribution = User::selectRaw('role, COUNT(*) as count')
                ->groupBy('role')
                ->get();

            return response()->json([
                'status' => true,
                'data' => [
                    'ride_analytics' => $rideAnalytics,
                    'user_analytics' => $userAnalytics,
                    'ride_status_distribution' => $rideStatusDistribution,
                    'user_role_distribution' => $userRoleDistribution,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // ==================== SUPPORT MESSAGES ====================

    public function getSupportMessages(Request $request)
    {
        try {
            $user = $request->user();
            if ($user->role !== 'Admin') {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $perPage = $request->get('per_page', 15);
            $status = $request->get('status');

            $query = ContactMessage::with('user');

            if ($status) {
                $query->where('status', $status);
            }

            $messages = $query->orderBy('created_at', 'desc')
                ->paginate($perPage);

            return response()->json([
                'status' => true,
                'data' => $messages
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    public function updateSupportMessage(Request $request, $id)
    {
        try {
            $user = $request->user();
            if ($user->role !== 'Admin') {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $validator = Validator::make($request->all(), [
                'status' => 'required|in:pending,resolved,closed',
                'admin_response' => 'string|nullable',
            ]);

            if ($validator->fails()) {
                return response()->json(['errors' => $validator->errors()], 422);
            }

            $message = ContactMessage::findOrFail($id);
            $message->update($request->only(['status', 'admin_response']));

            return response()->json([
                'status' => true,
                'message' => 'Support message updated successfully',
                'data' => $message
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // ==================== SETTINGS ====================

    public function getSettings(Request $request)
    {
        try {
            $user = $request->user();
            if ($user->role !== 'Admin') {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $settings = Setting::all()->keyBy('key');

            return response()->json([
                'status' => true,
                'data' => $settings
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    public function updateSettings(Request $request)
    {
        try {
            $user = $request->user();
            if ($user->role !== 'Admin') {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $validator = Validator::make($request->all(), [
                'base_fare' => 'numeric|min:0',
                'per_km_rate' => 'numeric|min:0',
                'per_minute_rate' => 'numeric|min:0',
                'minimum_fare' => 'numeric|min:0',
                'maximum_fare' => 'numeric|min:0',
                'app_version' => 'string',
                'maintenance_mode' => 'boolean',
            ]);

            if ($validator->fails()) {
                return response()->json(['errors' => $validator->errors()], 422);
            }

            foreach ($request->all() as $key => $value) {
                Setting::updateOrCreate(
                    ['key' => $key],
                    ['value' => $value]
                );
            }

            return response()->json([
                'status' => true,
                'message' => 'Settings updated successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error: ' . $e->getMessage()], 500);
        }
    }

    // ==================== DRIVER REGISTRATION ====================
    
    /**
     * Register a new driver by admin
     */
    public function registerDriver(Request $request)
    {
        try {
            $user = $request->user();
            if ($user->role !== 'Admin') {
                return response()->json(['message' => 'Forbidden'], 403);
            }

            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:150',
                'email' => 'required|email|unique:users',
                'phone' => 'required|string|max:30|unique:users',
                'password' => 'required|min:6',
                'gender' => 'required|in:Male,Female',
                'cnic' => 'required|string|max:50|unique:users',
                'driving_license' => 'required|string|max:100',
                'vehicle_model' => 'required|string|max:100',
                'vehicle_number' => 'required|string|max:20',
                'vehicle_year' => 'nullable|integer|min:1990|max:' . date('Y'),
                'vehicle_color' => 'nullable|string|max:50',
                'selfie' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
                'cnic_front' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
                'cnic_back' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
                'driving_license_image' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
                'vehicle_registration' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
                'insurance_certificate' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Handle file uploads
            $selfieUrl = null;
            if ($request->hasFile('selfie')) {
                $path = $request->file('selfie')->store('drivers/selfies', 'public');
                $selfieUrl = asset('storage/' . $path);
            }

            $cnicFrontUrl = null;
            if ($request->hasFile('cnic_front')) {
                $path = $request->file('cnic_front')->store('drivers/documents/cnic', 'public');
                $cnicFrontUrl = asset('storage/' . $path);
            }

            $cnicBackUrl = null;
            if ($request->hasFile('cnic_back')) {
                $path = $request->file('cnic_back')->store('drivers/documents/cnic', 'public');
                $cnicBackUrl = asset('storage/' . $path);
            }

            $drivingLicenseUrl = null;
            if ($request->hasFile('driving_license_image')) {
                $path = $request->file('driving_license_image')->store('drivers/documents/license', 'public');
                $drivingLicenseUrl = asset('storage/' . $path);
            }

            $vehicleRegistrationUrl = null;
            if ($request->hasFile('vehicle_registration')) {
                $path = $request->file('vehicle_registration')->store('drivers/documents/vehicle', 'public');
                $vehicleRegistrationUrl = asset('storage/' . $path);
            }

            $insuranceUrl = null;
            if ($request->hasFile('insurance_certificate')) {
                $path = $request->file('insurance_certificate')->store('drivers/documents/insurance', 'public');
                $insuranceUrl = asset('storage/' . $path);
            }

            // Create the driver user
            $driver = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'password' => Hash::make($request->password),
                'role' => 'Driver',
                'cnic' => $request->cnic,
                'gender' => $request->gender,
                'selfie' => $selfieUrl,
                'is_email_verified' => true, // Admin verified
                'is_phone_verified' => true, // Admin verified
                'is_profile_verified' => true, // Admin verified
                'is_online' => false,
                'email_verified_at' => now(),
            ]);

            // Store additional driver information in user meta or create a separate driver profile table
            // For now, we'll store it in a JSON field or use the existing user fields
            $driver->update([
                'driving_license' => $request->driving_license,
                'vehicle_model' => $request->vehicle_model,
                'vehicle_number' => $request->vehicle_number,
                'vehicle_year' => $request->vehicle_year,
                'vehicle_color' => $request->vehicle_color,
                'cnic_front_url' => $cnicFrontUrl,
                'cnic_back_url' => $cnicBackUrl,
                'driving_license_url' => $drivingLicenseUrl,
                'vehicle_registration_url' => $vehicleRegistrationUrl,
                'insurance_certificate_url' => $insuranceUrl,
            ]);

            return response()->json([
                'status' => true,
                'message' => 'Driver registered successfully',
                'data' => [
                    'user' => $driver,
                    'driver_info' => [
                        'driving_license' => $request->driving_license,
                        'vehicle_model' => $request->vehicle_model,
                        'vehicle_number' => $request->vehicle_number,
                        'vehicle_year' => $request->vehicle_year,
                        'vehicle_color' => $request->vehicle_color,
                    ]
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'status' => false,
                'message' => 'Error registering driver: ' . $e->getMessage()
            ], 500);
        }
    }
}
