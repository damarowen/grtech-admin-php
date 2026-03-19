<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreCompanyRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // We return true here because our 'admin' middleware in routes/web.php 
        // is already protecting this endpoint from unauthorized users.
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name' => ['required', 'string', 'max:255'],
            'email' => ['nullable', 'email', 'max:255'],
            // Ensures the file is an actual image, limits size to 2MB, and sets minimum dimensions
            'logo' => ['nullable', 'image', 'mimes:jpeg,png,jpg,gif,svg', 'max:2048', 'dimensions:min_width=100,min_height=100'],
            'website' => ['nullable', 'url', 'max:255'],
        ];
    }
    
    /**
     * Custom error messages (Optional but good for UX)
     */
    public function messages(): array
    {
        return [
            'logo.dimensions' => 'The logo must be at least 100x100 pixels.',
            'logo.max' => 'The logo size must not exceed 2MB.',
        ];
    }
}