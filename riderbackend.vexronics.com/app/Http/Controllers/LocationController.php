<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\FavoriteLocation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class LocationController extends Controller
{
    /**
     * Get favorite locations
     */
    public function getFavoriteLocations(Request $request)
    {
        $user = $request->user();
        
        $favorites = FavoriteLocation::where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->get()
            ->map(function ($location) {
                return [
                    'id' => $location->id,
                    'name' => $location->name,
                    'address' => $location->address,
                    'lat' => $location->lat,
                    'lng' => $location->lng,
                    'type' => $location->type,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $favorites
        ]);
    }

    /**
     * Add favorite location
     */
    public function addFavoriteLocation(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'lat' => 'required|numeric|between:-90,90',
            'lng' => 'required|numeric|between:-180,180',
            'address' => 'required|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'error' => 'Validation failed',
                'details' => $validator->errors()
            ], 400);
        }

        $user = $request->user();

        $favorite = FavoriteLocation::create([
            'user_id' => $user->id,
            'name' => $request->name,
            'address' => $request->address,
            'lat' => $request->lat,
            'lng' => $request->lng,
            'type' => 'custom',
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $favorite->id,
                'name' => $favorite->name,
                'address' => $favorite->address,
                'lat' => $favorite->lat,
                'lng' => $favorite->lng,
                'type' => $favorite->type,
                'created_at' => $favorite->created_at->toISOString(),
            ],
            'message' => 'Favorite location added successfully'
        ]);
    }

    /**
     * Get recent locations
     */
    public function getRecentLocations(Request $request)
    {
        $user = $request->user();
        
        // Mock recent locations - implement actual recent_locations table
        $recent = [
            [
                'id' => 1,
                'address' => 'Gulshan-e-Iqbal, Karachi',
                'lat' => 24.8607,
                'lng' => 67.0011,
                'used_at' => now()->subHours(2)->toISOString(),
            ],
            [
                'id' => 2,
                'address' => 'DHA Phase 5, Karachi',
                'lat' => 24.8607,
                'lng' => 67.0011,
                'used_at' => now()->subDays(1)->toISOString(),
            ],
            [
                'id' => 3,
                'address' => 'Clifton, Karachi',
                'lat' => 24.8607,
                'lng' => 67.0011,
                'used_at' => now()->subDays(2)->toISOString(),
            ],
        ];

        return response()->json([
            'success' => true,
            'data' => $recent
        ]);
    }
}
