<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'role',
        'name',
        'email',
        'phone',
        'password',
        'cnic',
        'gender',
        'is_email_verified',
        'is_phone_verified',
        'is_profile_verified',
        'is_online',
        'profile_pic_url',
        'selfie',
        'google_id',
        'facebook_id',
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
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var array<int, string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * The attributes that should be cast to native types.
     *
     * @var array<string, string>
     */
    protected $casts = [
        'is_email_verified' => 'boolean',
        'is_phone_verified' => 'boolean',
        'is_profile_verified' => 'boolean',
        'is_online' => 'boolean',
        'email_verified_at' => 'datetime',
    ];

    // Relationships
    public function ridesAsRider()
    {
        return $this->hasMany(Ride::class, 'rider_id');
    }

    public function ridesAsDriver()
    {
        return $this->hasMany(Ride::class, 'driver_id');
    }

    public function contactMessages()
    {
        return $this->hasMany(ContactMessage::class);
    }

    public function ratings()
    {
        return $this->hasMany(Rating::class, 'rated_user_id');
    }

    public function givenRatings()
    {
        return $this->hasMany(Rating::class, 'rater_id');
    }
}
