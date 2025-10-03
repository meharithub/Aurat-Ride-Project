<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        // Fix the driver_locations table by adding AUTO_INCREMENT to id and changing engine to InnoDB
        // First, drop the updated_at column (it's auto-generated and conflicts with AUTO_INCREMENT)
        DB::statement('ALTER TABLE driver_locations DROP COLUMN updated_at');
        
        // Add AUTO_INCREMENT to id and make it primary key
        DB::statement('ALTER TABLE driver_locations MODIFY COLUMN id bigint unsigned NOT NULL AUTO_INCREMENT PRIMARY KEY');
        
        // Change engine to InnoDB
        DB::statement('ALTER TABLE driver_locations ENGINE=InnoDB');
        
        // Re-add the updated_at column
        DB::statement('ALTER TABLE driver_locations ADD COLUMN updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP');
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        // Revert the changes
        DB::statement('ALTER TABLE driver_locations DROP PRIMARY KEY');
        DB::statement('ALTER TABLE driver_locations MODIFY COLUMN id bigint unsigned NOT NULL');
        DB::statement('ALTER TABLE driver_locations ENGINE=MyISAM');
    }
};
