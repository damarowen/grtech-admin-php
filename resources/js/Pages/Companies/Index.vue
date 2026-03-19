<script setup>
import { ref } from 'vue';
import { router, useForm } from '@inertiajs/vue3';
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { message } from 'ant-design-vue';

const props = defineProps({
    companies: Object,
});

// --- Table Configuration ---
const columns = [
    { title: 'No', dataIndex: 'index', key: 'index', width: 60 },
    { title: 'Logo', dataIndex: 'logo_url', key: 'logo_url', width: 80 },
    { title: 'Name', dataIndex: 'name', key: 'name' },
    { title: 'Email', dataIndex: 'email', key: 'email' },
    { title: 'Website', dataIndex: 'website', key: 'website' },
    { title: 'Action', key: 'action', width: 150 },
];

const handleTableChange = (pagination) => {
    router.get(route('companies.index'), { page: pagination.current }, {
        preserveState: true,
        preserveScroll: true,
    });
};

// --- Modal & Form State ---
const isModalVisible = ref(false);
const isEditing = ref(false);
const currentCompanyId = ref(null);
// Control Ant Design Upload's file list to ensure it resets properly
const uploadFileList = ref([]);

// Inertia useForm makes handling validation errors and file uploads a breeze
const form = useForm({
    name: '',
    email: '',
    website: '',
    logo: null,
    _method: 'post', // Default to post. We change this to 'put' for updates.
});

// --- Actions ---
const showCreateModal = () => {
    isEditing.value = false;
    form.reset();
    form.clearErrors();
    form._method = 'post';
    form.logo = null;
    uploadFileList.value = [];
    isModalVisible.value = true;
};

const showEditModal = (record) => {
    isEditing.value = true;
    currentCompanyId.value = record.id;
    form.clearErrors();
    
    // Populate form
    form.name = record.name;
    form.email = record.email;
    form.website = record.website;
    form.logo = null; // Reset logo input, they only upload if they want to change it
    form._method = 'put'; // Crucial for file uploads during an update in Laravel
    uploadFileList.value = [];
    
    isModalVisible.value = true;
};

const closeModal = () => {
    isModalVisible.value = false;
    form.reset();
    form.logo = null;
    uploadFileList.value = [];
};

// Capture the file manually to prevent Ant Design from trying to auto-upload it
const handleLogoUpload = (file) => {
    form.logo = file;
    uploadFileList.value = [file];
    return false; // Prevents AntD's default upload action
};

const handleLogoRemove = () => {
    form.logo = null;
    uploadFileList.value = [];
};

const submitForm = () => {
    if (isEditing.value) {
        // When updating with a file, Laravel requires POST with _method spoofing
        form.post(route('companies.update', currentCompanyId.value), {
            preserveScroll: true,
            onSuccess: () => {
                closeModal();
                message.success('Company updated successfully!');
            },
        });
    } else {
        form.post(route('companies.store'), {
            preserveScroll: true,
            onSuccess: () => {
                closeModal();
                message.success('Company created successfully!');
            },
        });
    }
};

const handleDelete = (id) => {
    router.delete(route('companies.destroy', id), {
        preserveScroll: true,
        onSuccess: () => message.success('Company deleted successfully!'),
    });
};
</script>

<template>
    <AuthenticatedLayout>
        <template #header>
            <div class="flex justify-between items-center">
                <h2 class="font-semibold text-xl text-gray-800 leading-tight">Companies Management</h2>
                <a-button type="primary" @click="showCreateModal">Add New Company</a-button>
            </div>
        </template>

        <div class="py-12 max-w-7xl mx-auto sm:px-6 lg:px-8">
            <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg p-6">
                
                <a-table 
                    :dataSource="companies.data" 
                    :columns="columns"
                    rowKey="id"
                    :pagination="{
                        current: companies.meta.current_page,
                        total: companies.meta.total,
                        pageSize: companies.meta.per_page,
                        showSizeChanger: false,
                    }"
                    @change="handleTableChange"
                    bordered
                >
                    <template #bodyCell="{ column, record, index }">
                        <template v-if="column.key === 'index'">
                            {{ (companies.meta.current_page - 1) * companies.meta.per_page + index + 1 }}
                        </template>
                        
                        <template v-else-if="column.key === 'logo_url'">
                            <img v-if="record.logo_url" :src="record.logo_url" alt="Logo" class="h-10 w-10 object-cover rounded shadow-sm border" />
                            <span v-else class="text-gray-400 text-xs italic">No Logo</span>
                        </template>

                        <template v-else-if="column.key === 'website'">
                            <a v-if="record.website" :href="record.website" target="_blank" class="text-blue-600 hover:underline">
                                {{ record.website }}
                            </a>
                        </template>

                        <template v-else-if="column.key === 'action'">
                            <div class="flex space-x-2">
                                <a-button size="small" @click="showEditModal(record)">Edit</a-button>
                                
                                <a-popconfirm
                                    title="Are you sure you want to delete this company?"
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
            :title="isEditing ? 'Edit Company' : 'Add New Company'" 
            @ok="submitForm"
            @cancel="closeModal"
            :confirmLoading="form.processing"
        >
            <a-form layout="vertical" class="mt-4">
                
                <a-form-item label="Company Name" :validate-status="form.errors.name ? 'error' : ''" :help="form.errors.name">
                    <a-input v-model:value="form.name" placeholder="Enter company name" />
                </a-form-item>

                <a-form-item label="Email Address" :validate-status="form.errors.email ? 'error' : ''" :help="form.errors.email">
                    <a-input v-model:value="form.email" type="email" placeholder="contact@company.com" />
                </a-form-item>

                <a-form-item label="Website URL" :validate-status="form.errors.website ? 'error' : ''" :help="form.errors.website">
                    <a-input v-model:value="form.website" placeholder="https://www.company.com" />
                </a-form-item>

                <a-form-item label="Company Logo (Optional)" :validate-status="form.errors.logo ? 'error' : ''" :help="form.errors.logo">
                    <a-upload
                        :before-upload="handleLogoUpload"
                        :file-list="uploadFileList"
                        :on-remove="handleLogoRemove"
                        :max-count="1"
                        list-type="picture"
                        accept="image/*"
                    >
                        <a-button>
                            <upload-outlined></upload-outlined>
                            Click to Select Image
                        </a-button>
                    </a-upload>
                    <p v-if="isEditing" class="text-xs text-gray-500 mt-2">
                        Leave blank to keep the current logo. Min 100x100px.
                    </p>
                </a-form-item>

            </a-form>
        </a-modal>
    </AuthenticatedLayout>
</template>