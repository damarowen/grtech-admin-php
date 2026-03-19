<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Admin user
        $admin = User::firstOrNew(['email' => 'admin@grtech.com']);
        $admin->name = 'Admin User';
        $admin->password = Hash::make('password');
        $admin->role = 'admin';
        $admin->save();

        // Standard user
        $user = User::firstOrNew(['email' => 'user@grtech.com']);
        $user->name = 'Standard User';
        $user->password = Hash::make('password');
        $user->role = 'user';
        $user->save();
    }
}
