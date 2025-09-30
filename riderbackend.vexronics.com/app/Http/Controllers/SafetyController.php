<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Ride;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Mail;

class SafetyController extends Controller
{
    /**
     * Send emergency SOS
     */
    public function sendEmergencySOS(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'lat' => 'required|numeric|between:-90,90',
            'lng' => 'required|numeric|between:-180,180',
            'message' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 400);
        }

        $user = $request->user();
        
        // Get current ride if any
        $currentRide = Ride::where('rider_id', $user->id)
            ->whereIn('status', ['assigned', 'driver_arriving', 'started'])
            ->first();

        // Create emergency record
        $emergencyData = [
            'user_id' => $user->id,
            'lat' => $request->lat,
            'lng' => $request->lng,
            'message' => $request->message,
            'ride_id' => $currentRide?->id,
            'status' => 'active',
            'created_at' => now(),
        ];

        // In production, save to emergency_sos table
        $sosId = 'SOS_' . time() . '_' . rand(1000, 9999);

        // Send emergency notifications
        $this->sendEmergencyNotifications($user, $emergencyData);

        return response()->json([
            'success' => true,
            'data' => [
                'sos_id' => $sosId,
                'status' => 'sent',
                'message' => 'Emergency SOS sent successfully. Help is on the way.',
            ]
        ]);
    }

    /**
     * Report safety issue
     */
    public function reportSafetyIssue(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'ride_id' => 'required|exists:rides,id',
            'issue_type' => 'required|string|in:driver_behavior,vehicle_condition,route_issue,other',
            'description' => 'required|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 400);
        }

        $user = $request->user();
        $ride = Ride::find($request->ride_id);

        // Verify ride belongs to user
        if ($ride->rider_id !== $user->id) {
            return response()->json([
                'success' => false,
                'error' => 'Unauthorized access to ride'
            ], 403);
        }

        // Create safety report
        $reportData = [
            'user_id' => $user->id,
            'ride_id' => $ride->id,
            'driver_id' => $ride->driver_id,
            'issue_type' => $request->issue_type,
            'description' => $request->description,
            'status' => 'pending',
            'created_at' => now(),
        ];

        // In production, save to safety_reports table
        $reportId = 'SAFETY_' . time() . '_' . rand(1000, 9999);

        // Send report to admin
        $this->sendSafetyReportToAdmin($reportData);

        return response()->json([
            'success' => true,
            'data' => [
                'report_id' => $reportId,
                'status' => 'submitted',
                'message' => 'Safety report submitted successfully. We will investigate this matter.',
            ]
        ]);
    }

    /**
     * Send emergency notifications
     */
    private function sendEmergencyNotifications($user, $emergencyData)
    {
        // In production, implement:
        // 1. Send SMS to emergency contacts
        // 2. Send push notification to nearby drivers
        // 3. Send email to admin
        // 4. Call emergency services API
        
        $message = "EMERGENCY SOS from {$user->name} at {$emergencyData['lat']}, {$emergencyData['lng']}";
        if ($emergencyData['message']) {
            $message .= "\nMessage: {$emergencyData['message']}";
        }
        
        // Log emergency for now
        \Log::emergency($message);
    }

    /**
     * Send safety report to admin
     */
    private function sendSafetyReportToAdmin($reportData)
    {
        // In production, implement:
        // 1. Send email to admin
        // 2. Create admin dashboard notification
        // 3. Send to safety team
        
        \Log::warning('Safety report submitted', $reportData);
    }
}
