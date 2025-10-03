<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Driver-specific fields
            $table->string('driving_license')->nullable()->after('selfie');
            $table->string('vehicle_model')->nullable()->after('driving_license');
            $table->string('vehicle_number')->nullable()->after('vehicle_model');
            $table->integer('vehicle_year')->nullable()->after('vehicle_number');
            $table->string('vehicle_color')->nullable()->after('vehicle_year');
            
            // Document URLs
            $table->string('cnic_front_url')->nullable()->after('vehicle_color');
            $table->string('cnic_back_url')->nullable()->after('cnic_front_url');
            $table->string('driving_license_url')->nullable()->after('cnic_back_url');
            $table->string('vehicle_registration_url')->nullable()->after('driving_license_url');
            $table->string('insurance_certificate_url')->nullable()->after('vehicle_registration_url');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'driving_license',
                'vehicle_model',
                'vehicle_number',
                'vehicle_year',
                'vehicle_color',
                'cnic_front_url',
                'cnic_back_url',
                'driving_license_url',
                'vehicle_registration_url',
                'insurance_certificate_url',
            ]);
        });
    }
};