<?php

namespace App\Http\Controllers;

use App\Models\Company;
use App\Models\Employee;
use Inertia\Inertia;
use App\Http\Resources\EmployeeResource;
use App\Http\Requests\EmployeeRequest;
use App\Notifications\NewEmployeeNotification;
use Illuminate\Support\Facades\Notification;

class EmployeeController extends Controller
{
    public function index()
    {
        // Eager load the company to avoid N+1 query problems
        $employees = Employee::with('company')->latest()->paginate(10);
        
        // We also need the list of companies to populate the <select> dropdown in the Create/Edit modal
        $companies = Company::select('id', 'name')->orderBy('name')->get();

        return Inertia::render('Employees/Index', [
            'employees' => EmployeeResource::collection($employees),
            'companies' => $companies, 
        ]);
    }

    public function store(EmployeeRequest $request)
    {
        $employee = Employee::create($request->validated());

        // BONUS QUESTION: Send notification to the company
        // We must ensure the company actually has an email address before sending
        if ($employee->company && $employee->company->email) {
            Notification::route('mail', $employee->company->email)
                        ->notify(new NewEmployeeNotification($employee));
        }

        return redirect()->route('employees.index')->with('success', 'Employee created successfully.');
    }

    public function update(EmployeeRequest $request, Employee $employee)
    {
        $employee->update($request->validated());

        return redirect()->route('employees.index')->with('success', 'Employee updated successfully.');
    }

    public function destroy(Employee $employee)
    {
        $employee->delete();

        return redirect()->route('employees.index')->with('success', 'Employee deleted successfully.');
    }
}