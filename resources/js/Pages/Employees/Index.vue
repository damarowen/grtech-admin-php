<script setup>
import { ref } from 'vue';
import { router, useForm } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { message } from 'ant-design-vue';

const props = defineProps({
    employees: Object,
    companies: Array, // We passed this from the controller for the dropdown
});

// --- Table Configuration ---
const columns = [
    { title: 'No', dataIndex: 'index', key: 'index', width: 60 },
    { title: 'Full Name', dataIndex: 'full_name', key: 'full_name' },
    { title: 'Company', dataIndex: 'company', key: 'company' },
    { title: 'Email', dataIndex: 'email', key: 'email' },
    { title: 'Phone', dataIndex: 'phone', key: 'phone' },
    { title: 'Action', key: 'action', width: 150 },
];

const handleTableChange = (pagination) => {
    router.get(route('employees.index'), { page: pagination.current }, {
        preserveState: true,
        preserveScroll: true,
    });
};

// --- Form Modal State ---
const isModalVisible = ref(false);
const isEditing = ref(false);
const currentEmployeeId = ref(null);

const form = useForm({
    first_name: '',
    last_name: '',
    company_id: null,
    email: '',
    phone: '',
});

// --- Company Details Modal State ---
const isCompanyModalVisible = ref(false);
const selectedCompany = ref(null);

const showCompanyDetails = (company) => {
    selectedCompany.value = company;
    isCompanyModalVisible.value = true;
};

// --- Actions ---
const showCreateModal = () => {
    isEditing.value = false;
    form.reset();
    form.clearErrors();
    isModalVisible.value = true;
};

const showEditModal = (record) => {
    isEditing.value = true;
    currentEmployeeId.value = record.id;
    form.clearErrors();
    
    // Populate form
    form.first_name = record.first_name;
    form.last_name = record.last_name;
    form.company_id = record.company_id;
    form.email = record.email;
    form.phone = record.phone;
    
    isModalVisible.value = true;
};

const closeModal = () => {
    isModalVisible.value = false;
    form.reset();
};

const submitForm = () => {
    if (isEditing.value) {
        form.put(route('employees.update', currentEmployeeId.value), {
            preserveScroll: true,
            onSuccess: () => {
                closeModal();
                message.success('Employee updated successfully!');
            },
        });
    } else {
        form.post(route('employees.store'), {
            preserveScroll: true,
            onSuccess: () => {
                closeModal();
                message.success('Employee created successfully!');
            },
        });
    }
};

const handleDelete = (id) => {
    router.delete(route('employees.destroy', id), {
        preserveScroll: true,
        onSuccess: () => message.success('Employee deleted successfully!'),
    });
};
</script>

<template>
    <AuthenticatedLayout>
        <template #header>
            <div class="flex justify-between items-center">
                <h2 class="font-semibold text-xl text-gray-800 leading-tight">Employees Management</h2>
                <a-button type="primary" @click="showCreateModal">Add New Employee</a-button>
            </div>
        </template>

        <div class="py-12 max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
                
                <a-table 
                    :dataSource="employees.data" 
                    :columns="columns"
                    rowKey="id"
                    :pagination="{
                        current: employees.meta.current_page,
                        total: employees.meta.total,
                        pageSize: employees.meta.per_page,
                        showSizeChanger: false,
                    }"
                    @change="handleTableChange"
                    bordered
                >
                    <template #bodyCell="{ column, record, index }">
                        <template v-if="column.key === 'index'">
                            {{ (employees.meta.current_page - 1) * employees.meta.per_page + index + 1 }}
                        </template>
                        
                        <template v-else-if="column.key === 'company'">
                            <a v-if="record.company" @click.prevent="showCompanyDetails(record.company)" class="text-blue-600 hover:underline cursor-pointer">
                                {{ record.company.name }}
                            </a>
                            <span v-else class="text-gray-400 italic">No Company</span>
                        </template>

                        <template v-else-if="column.key === 'action'">
                            <div class="flex space-x-2">
                                <a-button size="small" @click="showEditModal(record)">Edit</a-button>
                                
                                <a-popconfirm
                                    title="Are you sure you want to delete this employee?"
                                    ok-text="Yes, Delete"
                                    cancel-text="Cancel"
                                    @confirm="handleDelete(record.id)"
                                >
                                    <a-button danger size="small">Delete</a-button>
                                </a-popconfirm>
                            </div>
                        </template>
                    </template>
                </a-table>
            </div>
        </div>

        <a-modal 
            v-model:open="isModalVisible" 
            :title="isEditing ? 'Edit Employee' : 'Add New Employee'" 
            @ok="submitForm"
            @cancel="closeModal"
            :confirmLoading="form.processing"
        >
            <a-form layout="vertical" class="mt-4">
                
                <div class="grid grid-cols-2 gap-4">
                    <a-form-item label="First Name" :validate-status="form.errors.first_name ? 'error' : ''" :help="form.errors.first_name">
                        <a-input v-model:value="form.first_name" placeholder="John" />
                    </a-form-item>

                    <a-form-item label="Last Name" :validate-status="form.errors.last_name ? 'error' : ''" :help="form.errors.last_name">
                        <a-input v-model:value="form.last_name" placeholder="Doe" />
                    </a-form-item>
                </div>

                <a-form-item label="Company" :validate-status="form.errors.company_id ? 'error' : ''" :help="form.errors.company_id">
                    <a-select
                        v-model:value="form.company_id"
                        placeholder="Select a company"
                        show-search
                        option-filter-prop="label"
                        :options="companies.map(c => ({ value: c.id, label: c.name }))"
                    />
                </a-form-item>

                <a-form-item label="Email Address" :validate-status="form.errors.email ? 'error' : ''" :help="form.errors.email">
                    <a-input v-model:value="form.email" type="email" placeholder="john.doe@example.com" />
                </a-form-item>

                <a-form-item label="Phone Number" :validate-status="form.errors.phone ? 'error' : ''" :help="form.errors.phone">
                    <a-input v-model:value="form.phone" placeholder="+1 234 567 890" />
                </a-form-item>

            </a-form>
        </a-modal>

        <a-modal 
            v-model:open="isCompanyModalVisible" 
            title="Company Details" 
            :footer="null" 
            @cancel="isCompanyModalVisible = false"
        >
            <div v-if="selectedCompany" class="space-y-4 mt-4">
                <div>
                    <span class="font-bold text-gray-700">Name:</span> 
                    <p class="text-gray-900">{{ selectedCompany.name }}</p>
                </div>
                <div>
                    <span class="font-bold text-gray-700">Email:</span> 
                    <p class="text-gray-900">{{ selectedCompany.email || 'N/A' }}</p>
                </div>
                <div>
                    <span class="font-bold text-gray-700">Website:</span> 
                    <p>
                        <a v-if="selectedCompany.website" :href="selectedCompany.website" target="_blank" class="text-blue-600 hover:underline">
                            {{ selectedCompany.website }}
                        </a>
                        <span v-else class="text-gray-900">N/A</span>
                    </p>
                </div>
            </div>
        </a-modal>
    </AuthenticatedLayout>
</template>