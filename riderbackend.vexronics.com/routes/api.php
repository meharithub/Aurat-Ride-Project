<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\AppController;
use App\Http\Controllers\UserController;
use App\Http\Controllers\RideController;
use App\Http\Controllers\DriverController;
use App\Http\Controllers\RatingController;
use App\Http\Controllers\SupportController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});


// ====================================== AUTHENTICATION API'S ==============================================================
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/otp/send', [AuthController::class, 'sendOtp']);
    Route::post('/otp/verify', [AuthController::class, 'verifyOtp']);
    Route::post('/password/reset', [AuthController::class, 'resetPassword']);
    Route::post('/google', [AuthController::class, 'googleLogin']);
    Route::post('/facebook', [AuthController::class, 'facebookLogin']);
});


Route::middleware('auth:sanctum')->get('/auth/check', [AuthController::class, 'checkAuth']);
Route::middleware('auth:sanctum')->post('/auth/logout', [AuthController::class, 'logout']);
Route::middleware('auth:sanctum')->post('/auth/password/change', [AuthController::class, 'changePassword']);
Route::middleware('auth:sanctum')->post('/auth/refresh', [AuthController::class, 'refreshToken']);

// ====================================== APP / SPLASH ==============================================================
Route::get('/app/config', [AppController::class, 'config']);
Route::get('/content/terms', [AppController::class, 'terms']);
Route::get('/content/privacy', [AppController::class, 'privacy']);

// ====================================== RIDES (PUBLIC) ==============================================================
Route::post('/rides/quote', [RideController::class, 'quote']);

// ====================================== USER ==============================================================
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user/me', [UserController::class, 'me']);
    Route::put('/user/me', [UserController::class, 'updateMe']);
    Route::post('/user/gender', [UserController::class, 'updateGender']);
    
    // Rides
    Route::post('/rides/request', [RideController::class, 'requestRide']);
    Route::get('/rides', [RideController::class, 'list']);
    Route::get('/rides/{ride}', [RideController::class, 'show']);
    Route::post('/rides/{ride}/cancel', [RideController::class, 'cancel']);
    Route::post('/rides/{ride}/start', [RideController::class, 'start']); // driver only
    Route::post('/rides/{ride}/complete', [RideController::class, 'complete']); // driver only

    // Driver live
    Route::post('/driver/online', [DriverController::class, 'setOnline']);
    Route::post('/driver/location', [DriverController::class, 'updateLocation']);
    Route::get('/rides/{ride}/live', [DriverController::class, 'rideLive']);

    // Rating
    Route::post('/rides/{ride}/rate', [RatingController::class, 'rate']);

    // Support
    Route::post('/support/contact', [SupportController::class, 'contact']);
    
    // Payment routes
    Route::get('/user/payment-methods', [App\Http\Controllers\PaymentController::class, 'getPaymentMethods']);
    Route::post('/user/payment-methods', [App\Http\Controllers\PaymentController::class, 'addPaymentMethod']);
    Route::post('/payments/process', [App\Http\Controllers\PaymentController::class, 'processPayment']);
    Route::get('/user/wallet', [App\Http\Controllers\PaymentController::class, 'getWalletBalance']);
    Route::post('/user/wallet', [App\Http\Controllers\PaymentController::class, 'addToWallet']);
    Route::get('/user/transactions', [App\Http\Controllers\PaymentController::class, 'getTransactionHistory']);
    
    // Enhanced driver routes
    Route::get('/driver/earnings', [App\Http\Controllers\EnhancedDriverController::class, 'getDriverEarnings']);
    Route::get('/driver/stats', [App\Http\Controllers\EnhancedDriverController::class, 'getDriverStats']);
    
    // Location management routes
    Route::get('/user/favorites', [App\Http\Controllers\LocationController::class, 'getFavoriteLocations']);
    Route::post('/user/favorites', [App\Http\Controllers\LocationController::class, 'addFavoriteLocation']);
    Route::get('/user/recent-locations', [App\Http\Controllers\LocationController::class, 'getRecentLocations']);
    
    // Notification routes
    Route::get('/user/notifications', [App\Http\Controllers\NotificationController::class, 'getNotifications']);
    Route::post('/user/notifications/{notificationId}/read', [App\Http\Controllers\NotificationController::class, 'markNotificationRead']);
    
    // Safety and emergency routes
    Route::post('/emergency/sos', [App\Http\Controllers\SafetyController::class, 'sendEmergencySOS']);
    Route::post('/safety/report', [App\Http\Controllers\SafetyController::class, 'reportSafetyIssue']);
    
    // Chat routes
    Route::get('/rides/{rideId}/messages', [App\Http\Controllers\ChatController::class, 'getMessages']);
    Route::post('/rides/{rideId}/messages', [App\Http\Controllers\ChatController::class, 'sendMessage']);
    Route::post('/rides/{rideId}/messages/read', [App\Http\Controllers\ChatController::class, 'markAsRead']);
    Route::get('/rides/{rideId}/messages/unread-count', [App\Http\Controllers\ChatController::class, 'getUnreadCount']);
});

// Public routes
Route::get('/drivers/nearby', [App\Http\Controllers\EnhancedDriverController::class, 'getNearbyDrivers']);