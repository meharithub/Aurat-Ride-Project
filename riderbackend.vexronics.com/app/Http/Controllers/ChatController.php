<?php

namespace App\Http\Controllers;

use App\Models\Ride;
use App\Models\RideMessage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ChatController extends Controller
{
    /**
     * Get messages for a ride
     */
    public function getMessages(Request $request, $rideId)
    {
        $user = $request->user();
        $ride = Ride::find($rideId);

        if (!$ride) {
            return response()->json([
                'success' => false,
                'error' => 'Ride not found'
            ], 404);
        }

        // Check if user is part of this ride
        if ($ride->rider_id !== $user->id && $ride->driver_id !== $user->id) {
            return response()->json([
                'success' => false,
                'error' => 'Unauthorized access to ride messages'
            ], 403);
        }

        $messages = RideMessage::where('ride_id', $rideId)
            ->with('sender:id,name,profile_pic_url')
            ->orderBy('created_at', 'asc')
            ->get()
            ->map(function ($message) {
                return [
                    'id' => $message->id,
                    'message' => $message->message,
                    'type' => $message->type,
                    'metadata' => $message->metadata,
                    'is_read' => $message->is_read,
                    'created_at' => $message->created_at->toISOString(),
                    'sender' => [
                        'id' => $message->sender->id,
                        'name' => $message->sender->name,
                        'profile_pic_url' => $message->sender->profile_pic_url,
                    ],
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $messages
        ]);
    }

    /**
     * Send a message
     */
    public function sendMessage(Request $request, $rideId)
    {
        $validator = Validator::make($request->all(), [
            'message' => 'required|string|max:1000',
            'type' => 'in:text,image,location,system',
            'metadata' => 'nullable|array',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 400);
        }

        $user = $request->user();
        $ride = Ride::find($rideId);

        if (!$ride) {
            return response()->json([
                'success' => false,
                'error' => 'Ride not found'
            ], 404);
        }

        // Check if user is part of this ride
        if ($ride->rider_id !== $user->id && $ride->driver_id !== $user->id) {
            return response()->json([
                'success' => false,
                'error' => 'Unauthorized access to ride'
            ], 403);
        }

        $message = RideMessage::create([
            'ride_id' => $rideId,
            'sender_id' => $user->id,
            'message' => $request->message,
            'type' => $request->type ?? 'text',
            'metadata' => $request->metadata,
        ]);

        $message->load('sender:id,name,profile_pic_url');

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $message->id,
                'message' => $message->message,
                'type' => $message->type,
                'metadata' => $message->metadata,
                'is_read' => $message->is_read,
                'created_at' => $message->created_at->toISOString(),
                'sender' => [
                    'id' => $message->sender->id,
                    'name' => $message->sender->name,
                    'profile_pic_url' => $message->sender->profile_pic_url,
                ],
            ]
        ]);
    }

    /**
     * Mark messages as read
     */
    public function markAsRead(Request $request, $rideId)
    {
        $user = $request->user();
        $ride = Ride::find($rideId);

        if (!$ride) {
            return response()->json([
                'success' => false,
                'error' => 'Ride not found'
            ], 404);
        }

        // Check if user is part of this ride
        if ($ride->rider_id !== $user->id && $ride->driver_id !== $user->id) {
            return response()->json([
                'success' => false,
                'error' => 'Unauthorized access to ride'
            ], 403);
        }

        // Mark all unread messages as read
        RideMessage::where('ride_id', $rideId)
            ->where('sender_id', '!=', $user->id)
            ->where('is_read', false)
            ->update([
                'is_read' => true,
                'read_at' => now(),
            ]);

        return response()->json([
            'success' => true,
            'message' => 'Messages marked as read'
        ]);
    }

    /**
     * Get unread message count for a ride
     */
    public function getUnreadCount(Request $request, $rideId)
    {
        $user = $request->user();
        $ride = Ride::find($rideId);

        if (!$ride) {
            return response()->json([
                'success' => false,
                'error' => 'Ride not found'
            ], 404);
        }

        // Check if user is part of this ride
        if ($ride->rider_id !== $user->id && $ride->driver_id !== $user->id) {
            return response()->json([
                'success' => false,
                'error' => 'Unauthorized access to ride'
            ], 403);
        }

        $unreadCount = RideMessage::where('ride_id', $rideId)
            ->where('sender_id', '!=', $user->id)
            ->where('is_read', false)
            ->count();

        return response()->json([
            'success' => true,
            'data' => [
                'unread_count' => $unreadCount
            ]
        ]);
    }
}
