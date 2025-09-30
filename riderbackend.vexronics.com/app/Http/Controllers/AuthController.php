<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\OtpCode;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use App\Mail\OtpMail;
use Illuminate\Support\Facades\Mail;
use Carbon\Carbon;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:150',
            'email' => 'nullable|email|unique:users',
            'phone' => 'nullable|string|max:30|unique:users',
            'password' => 'required|min:6',
            'role' => 'required|in:Rider,Driver,admin',
            'gender' => 'required|in:Male,Female',
            'cnic' => 'nullable|string|max:50',
            'selfie' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:5120',
        ]);

        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }

        $selfieUrl = null;
        if ($request->hasFile('selfie')) {
            $path = $request->file('selfie')->store('selfies', 'public');
            $selfieUrl = asset('storage/' . $path);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'role' => $request->role,
            'password' => Hash::make($request->password),
            'cnic' => $request->cnic,
            'gender' => $request->gender,
            'selfie' => $selfieUrl,
        ]);

        return response()->json(['message' => 'User registered successfully. Please verify via OTP.', 'user' => $user], 201);
    }

    public function login(Request $request)
    {
        $field = filter_var($request->input('email'), FILTER_VALIDATE_EMAIL) ? 'email' : 'phone';
        $user = User::where($field, $request->input('email') ?? $request->input('phone'))->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['message' => 'Invalid credentials'], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json(['token' => $token, 'user' => $user]);
    }


    public function sendOtp(Request $request)
    {
        $request->validate([
            'type' => 'required|in:phone,email',
            'recipient' => 'required|string'
        ]);

        $code = rand(100000, 999999);

        $expiresAt = Carbon::now()->addMinutes(5);

        $otp = OtpCode::create([
            'recipient' => $request->recipient,
            'code' => $code,
            'type' => $request->type,
            'expires_at' => $expiresAt,
            'is_used' => false,
        ]);

        if ($request->type === 'email') {
            Mail::to($request->recipient)->send(new OtpMail($code));
        }

        return response()->json([
            'message' => 'OTP sent',
            'expires_at' => $expiresAt->toDateTimeString()
        ]);
    }


    public function verifyOtp(Request $request)
    {
        $request->validate([
            'recipient' => 'required|string',
            'code' => 'required|string'
        ]);

        $otp = OtpCode::where('recipient', $request->recipient)
            ->where('code', $request->code)
            ->where('is_used', false)
            ->latest()
            ->first();

        if (!$otp) {
            return response()->json(['message' => 'Invalid OTP'], 400);
        }

        if (Carbon::now()->gt($otp->expires_at)) {
            return response()->json(['message' => 'OTP expired'], 400);
        }

        $otp->update(['is_used' => true]);

        $user = User::where('email', $request->recipient)
            ->orWhere('phone', $request->recipient)
            ->first();

        if ($user) {
            if ($otp->type === 'email') {
                $user->is_email_verified = true;
                $user->email_verified_at = now();
            }
            if ($otp->type === 'phone') {
                $user->is_phone_verified = true;
            }
            $user->save();
        }

        return response()->json(['message' => 'OTP verified', 'user' => $user]);
    }

    public function checkAuth(Request $request)
    {
        return response()->json([
            'authenticated' => true,
            'user' => $request->user(),
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Logged out']);
    }

    /**
     * Reset password
     */
    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|exists:users',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 400);
        }

        // Send OTP for password reset
        $code = rand(100000, 999999);
        $expiresAt = Carbon::now()->addMinutes(10);

        OtpCode::create([
            'recipient' => $request->email,
            'code' => $code,
            'type' => 'password_reset',
            'expires_at' => $expiresAt,
            'is_used' => false,
        ]);

        // In production, send email
        Mail::to($request->email)->send(new OtpMail($code));

        return response()->json([
            'success' => true,
            'message' => 'Password reset code sent to your email',
            'expires_at' => $expiresAt->toDateTimeString()
        ]);
    }

    /**
     * Change password
     */
    public function changePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required',
            'new_password' => 'required|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 400);
        }

        $user = $request->user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'error' => 'Current password is incorrect'
            ], 400);
        }

        $user->update([
            'password' => Hash::make($request->new_password)
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Password changed successfully'
        ]);
    }

    /**
     * Refresh token
     */
    public function refreshToken(Request $request)
    {
        $user = $request->user();
        
        // Delete current token
        $request->user()->currentAccessToken()->delete();
        
        // Create new token
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'token' => $token,
            'user' => $user
        ]);
    }

    /**
     * Social login (Google)
     */
    public function googleLogin(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'google_id' => 'required|string',
            'email' => 'required|email',
            'name' => 'required|string',
            'profile_picture' => 'nullable|url',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 400);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            // Create new user
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'google_id' => $request->google_id,
                'profile_pic_url' => $request->profile_picture,
                'role' => 'Rider',
                'is_email_verified' => true,
                'email_verified_at' => now(),
                'password' => Hash::make(uniqid()), // Random password
            ]);
        } else {
            // Update existing user
            $user->update([
                'google_id' => $request->google_id,
                'profile_pic_url' => $request->profile_picture,
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'token' => $token,
            'user' => $user
        ]);
    }

    /**
     * Social login (Facebook)
     */
    public function facebookLogin(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'facebook_id' => 'required|string',
            'email' => 'required|email',
            'name' => 'required|string',
            'profile_picture' => 'nullable|url',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 400);
        }

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            // Create new user
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'facebook_id' => $request->facebook_id,
                'profile_pic_url' => $request->profile_picture,
                'role' => 'Rider',
                'is_email_verified' => true,
                'email_verified_at' => now(),
                'password' => Hash::make(uniqid()), // Random password
            ]);
        } else {
            // Update existing user
            $user->update([
                'facebook_id' => $request->facebook_id,
                'profile_pic_url' => $request->profile_picture,
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'token' => $token,
            'user' => $user
        ]);
    }
}
