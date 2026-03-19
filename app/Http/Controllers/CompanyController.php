<?php

namespace App\Http\Controllers;

use App\Models\Company;
use Inertia\Inertia;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use App\Http\Resources\CompanyResource;
use App\Http\Requests\StoreCompanyRequest;

class CompanyController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        // Fetch companies with server-side pagination (10 per page)
        $companies = Company::latest()->paginate(10);

        return Inertia::render('Companies/Index', [
            // Format the API response using the Laravel Resource
            'companies' => CompanyResource::collection($companies),
        ]);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        // Not needed for SPA with modals, handled on the Index page
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreCompanyRequest $request)
    {
        $validated = $request->validated();

        // Handle the logo file upload
        if ($request->hasFile('logo')) {
            // Stores the file in storage/app/public/logos
            $validated['logo'] = $request->file('logo')->store('logos', 'public');
        }

        Company::create($validated);

        // Redirect back to the index page with a success state
        return redirect()->route('companies.index')->with('success', 'Company created successfully.');
    }

    /**
     * Display the specified resource.
     */
    public function show(Company $company)
    {
        // Not explicitly needed for this exact requirement, but available
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Company $company)
    {
        // Not needed for SPA with modals, handled on the Index page
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(StoreCompanyRequest $request, Company $company)
    {
        $validated = $request->validated();

        // Handle the logo file upload and deletion of the old logo
        if ($request->hasFile('logo')) {
            // Delete the old logo from storage if it exists
            if ($company->logo) {
                Storage::disk('public')->delete($company->logo);
            }
            
            // Store the new logo
            $validated['logo'] = $request->file('logo')->store('logos', 'public');
        } else {
            // Ensure we don't overwrite existing logo with null when not uploading a new one
            unset($validated['logo']);
        }

        $company->update($validated);

        return redirect()->route('companies.index')->with('success', 'Company updated successfully.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Company $company)
    {
        // Delete the logo file from storage if it exists
        if ($company->logo) {
            Storage::disk('public')->delete($company->logo);
        }

        $company->delete();

        return redirect()->route('companies.index')->with('success', 'Company deleted successfully.');
    }
}