<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Ride;
use App\Models\DriverLocation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class EnhancedDriverController extends Controller
{
    /**
     * Get driver earnings
     */
    public function getDriverEarnings(Request $request)
    {
        $user = $request->user();
        
        // Get earnings for different time periods
        $today = Ride::where('driver_id', $user->id)
            ->where('status', 'completed')
            ->whereDate('completed_at', today())
            ->sum('final_fare');

        $thisWeek = Ride::where('driver_id', $user->id)
            ->where('status', 'completed')
            ->whereBetween('completed_at', [now()->startOfWeek(), now()->endOfWeek()])
            ->sum('final_fare');

        $thisMonth = Ride::where('driver_id', $user->id)
            ->where('status', 'completed')
            ->whereMonth('completed_at', now()->month)
            ->whereYear('completed_at', now()->year)
            ->sum('final_fare');

        $totalEarnings = Ride::where('driver_id', $user->id)
            ->where('status', 'completed')
            ->sum('final_fare');

        return response()->json([
            'success' => true,
            'data' => [
                'today' => $today ?? 0,
                'this_week' => $thisWeek ?? 0,
                'this_month' => $thisMonth ?? 0,
                'total' => $totalEarnings ?? 0,
                'currency' => 'PKR',
            ]
        ]);
    }

    /**
     * Get driver statistics
     */
    public function getDriverStats(Request $request)
    {
        $user = $request->user();
        
        $totalRides = Ride::where('driver_id', $user->id)->count();
        $completedRides = Ride::where('driver_id', $user->id)
            ->where('status', 'completed')
            ->count();
        $cancelledRides = Ride::where('driver_id', $user->id)
            ->where('status', 'canceled')
            ->count();
        
        $averageRating = DB::table('ratings')
            ->where('driver_id', $user->id)
            ->avg('rating');

        $onlineHours = $this->calculateOnlineHours($user->id);

        return response()->json([
            'success' => true,
            'data' => [
                'total_rides' => $totalRides,
                'completed_rides' => $completedRides,
                'cancelled_rides' => $cancelledRides,
                'completion_rate' => $totalRides > 0 ? round(($completedRides / $totalRides) * 100, 2) : 0,
                'average_rating' => round($averageRating ?? 0, 2),
                'online_hours_today' => $onlineHours,
                'total_earnings' => Ride::where('driver_id', $user->id)
                    ->where('status', 'completed')
                    ->sum('final_fare'),
            ]
        ]);
    }

    /**
     * Get nearby drivers
     */
    public function getNearbyDrivers(Request $request)
    {
        $lat = $request->query('lat');
        $lng = $request->query('lng');
        $radius = $request->query('radius', 5.0);

        if (!$lat || !$lng) {
            return response()->json([
                'success' => false,
                'error' => 'Latitude and longitude are required'
            ], 400);
        }

        // Get online drivers within radius
        $drivers = DriverLocation::select('driver_locations.*', 'users.name', 'users.phone')
            ->join('users', 'driver_locations.driver_id', '=', 'users.id')
            ->where('users.role', 'Driver')
            ->whereRaw("
                (6371 * acos(cos(radians(?)) 
                * cos(radians(lat)) 
                * cos(radians(lng) - radians(?)) 
                + sin(radians(?)) 
                * sin(radians(lat)))) <= ?
            ", [$lat, $lng, $lat, $radius])
            ->orderByRaw("
                (6371 * acos(cos(radians(?)) 
                * cos(radians(lat)) 
                * cos(radians(lng) - radians(?)) 
                + sin(radians(?)) 
                * sin(radians(lat))))
            ", [$lat, $lng, $lat])
            ->limit(10)
            ->get();

        return response()->json([
            'success' => true,
            'data' => $drivers->map(function ($driver) use ($lat, $lng) {
                $distance = $this->calculateDistance($lat, $lng, $driver->lat, $driver->lng);
                return [
                    'id' => $driver->driver_id,
                    'name' => $driver->name,
                    'phone' => $driver->phone,
                    'lat' => $driver->lat,
                    'lng' => $driver->lng,
                    'distance_km' => round($distance, 2),
                    'last_updated' => $driver->updated_at,
                ];
            })
        ]);
    }

    /**
     * Calculate distance between two points
     */
    private function calculateDistance($lat1, $lng1, $lat2, $lng2)
    {
        $earthRadius = 6371; // km

        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);

        $a = sin($dLat/2) * sin($dLat/2) +
             cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
             sin($dLng/2) * sin($dLng/2);
        $c = 2 * atan2(sqrt($a), sqrt(1-$a));

        return $earthRadius * $c;
    }

    /**
     * Calculate online hours for today
     */
    private function calculateOnlineHours($driverId)
    {
        // This is a simplified calculation
        // In production, you'd track online/offline timestamps
        $onlineRides = Ride::where('driver_id', $driverId)
            ->whereDate('created_at', today())
            ->whereIn('status', ['assigned', 'driver_arriving', 'started'])
            ->get();

        $totalMinutes = 0;
        foreach ($onlineRides as $ride) {
            if ($ride->started_at) {
                $endTime = $ride->completed_at ?? now();
                $totalMinutes += $ride->started_at->diffInMinutes($endTime);
            }
        }

        return round($totalMinutes / 60, 2);
    }
}
