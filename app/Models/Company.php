<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Notifications\Notifiable; // If you added this earlier

class Company extends Model
{
    use Notifiable;

    protected $fillable = [
        'name',
        'email',
        'logo',
        'website',
    ];

    // ... any relationships you might have down here
}