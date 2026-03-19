<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Employee extends Model
{

    protected $fillable = [
        'first_name',
        'last_name',
        'company_id',
        'email',
        'phone',
    ];

    // Define the relationship to the Company (if you haven't already)
    public function company()
    {
        return $this->belongsTo(Company::class);
    }
}