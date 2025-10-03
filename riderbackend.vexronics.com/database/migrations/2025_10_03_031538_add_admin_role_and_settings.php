<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Insert default settings
        DB::table('settings')->insert([
            [
                'key' => 'base_fare',
                'value' => '50',
                'type' => 'number',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'key' => 'per_km_rate',
                'value' => '25',
                'type' => 'number',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'key' => 'per_minute_rate',
                'value' => '2',
                'type' => 'number',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'key' => 'minimum_fare',
                'value' => '100',
                'type' => 'number',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'key' => 'maximum_fare',
                'value' => '2000',
                'type' => 'number',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'key' => 'app_version',
                'value' => '1.0.0',
                'type' => 'string',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'key' => 'maintenance_mode',
                'value' => 'false',
                'type' => 'boolean',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'key' => 'driver_commission_percentage',
                'value' => '80',
                'type' => 'number',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'key' => 'support_email',
                'value' => 'support@auratride.com',
                'type' => 'string',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'key' => 'support_phone',
                'value' => '+92-300-1234567',
                'type' => 'string',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        // Create a default admin user
        DB::table('users')->insert([
            'role' => 'Admin',
            'name' => 'Admin User',
            'email' => 'admin@auratride.com',
            'phone' => '+92-300-0000000',
            'password' => bcrypt('admin123'),
            'cnic' => '12345-1234567-1',
            'gender' => 'Male',
            'is_email_verified' => true,
            'is_phone_verified' => true,
            'is_profile_verified' => true,
            'is_online' => false,
            'created_at' => now(),
            'updated_at' => now(),
        ]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Remove default settings
        DB::table('settings')->whereIn('key', [
            'base_fare',
            'per_km_rate',
            'per_minute_rate',
            'minimum_fare',
            'maximum_fare',
            'app_version',
            'maintenance_mode',
            'driver_commission_percentage',
            'support_email',
            'support_phone',
        ])->delete();

        // Remove default admin user
        DB::table('users')->where('email', 'admin@auratride.com')->delete();
    }
};