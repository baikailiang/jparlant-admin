<template>
  <div class="agent-list px-6 py-8 min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
    <!-- 顶部操作栏 -->
    <div class="flex items-center justify-between mb-8 animate-fade-in">
      <div class="space-y-3">
        <h1 class="text-3xl font-bold text-gray-900 tracking-tight bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
          Agent 管理
        </h1>
        <div class="flex items-center space-x-2">
          <div class="w-1 h-4 bg-blue-500 rounded-full shadow-sm"></div>
          <p class="text-base text-gray-500 font-medium tracking-wide">管理和配置您的智能代理</p>
        </div>
      </div>
      <n-button
        type="primary"
        @click="handleCreate"
        size="large"
        class="create-button shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-105"
        style="border-radius: 12px; padding: 0 24px; height: 48px; font-weight: 600; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none;"
      >
        <template #icon>
          <n-icon size="20">
            <svg viewBox="0 0 24 24">
              <path fill="currentColor" d="M12 2C6.477 2 2 6.477 2 12s4.477 10 10 10s10-4.477 10-10S17.523 2 12 2m5 11h-4v4h-2v-4H7v-2h4V7h2v4h4z"/>
            </svg>
          </n-icon>
        </template>
        创建 Agent
      </n-button>
    </div>

    <!-- 数据表格卡片 -->
    <n-card
      class="table-card shadow-2xl border-0 animate-slide-up"
      style="border-radius: 16px; overflow: hidden; backdrop-filter: blur(10px); background: rgba(255, 255, 255, 0.95);"
      :bordered="false"
    >
      <n-data-table
        :columns="columns"
        :data="agents"
        :loading="loading"
        :pagination="pagination"
        remote
        @update:page="handlePageChange"
        :scroll-x="1600"
        :row-props="rowProps"
        style="--n-th-padding: 16px 12px; --n-td-padding: 16px 12px; --n-font-size: 14px;"
      />
    </n-card>

    <!-- 创建/编辑模态框 -->
    <n-modal
      v-model:show="showCreateModal"
      preset="dialog"
      :title="isEditing ? '编辑 Agent' : '创建 Agent'"
      :style="{ width: '640px', borderRadius: '20px', overflow: 'hidden' }"
      class="modal-theme-custom modal-animate"
    >
      <n-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="110px"
        label-placement="left"
        class="mt-6 space-y-1"
        style="padding: 0 8px;"
      >
        <n-form-item label="名称" path="name" class="form-item-enhanced">
          <n-input
            v-model:value="form.name"
            placeholder="请输入Agent名称"
            size="large"
            class="input-enhanced"
            style="border-radius: 10px;"
          />
        </n-form-item>

        <n-form-item label="描述" path="description" class="form-item-enhanced">
          <n-input
            v-model:value="form.description"
            type="textarea"
            :rows="3"
            placeholder="请输入Agent描述"
            size="large"
            class="input-enhanced"
            style="border-radius: 10px;"
          />
        </n-form-item>

        <n-form-item label="系统指令" path="instructions" class="form-item-enhanced">
          <n-input
            v-model:value="form.instructions"
            type="textarea"
            :rows="6"
            placeholder="请输入系统指令"
            size="large"
            class="input-enhanced"
            style="border-radius: 10px;"
          />
        </n-form-item>

        <n-form-item label="关键词" path="keywords" class="form-item-enhanced">
          <n-dynamic-tags
            v-model:value="keywordArray"
            :max="10"
            class="input-enhanced"
          />
        </n-form-item>

        <n-form-item label="状态" path="status" class="form-item-enhanced">
          <n-switch
            v-model:value="form.status"
            size="large"
            class="switch-theme-custom"
            style="--n-rail-height: 28px; --n-rail-width: 56px; --n-button-width: 24px; --n-button-height: 24px;"
          />
        </n-form-item>
      </n-form>
      <template #action>
        <n-space size="large" justify="end" style="padding-top: 16px;">
          <n-button
            @click="showCreateModal = false"
            size="large"
            class="cancel-button"
            style="border-radius: 10px; padding: 0 24px; height: 44px; font-weight: 500;"
          >
            取消
          </n-button>
          <n-button
            type="primary"
            @click="handleSave"
            :loading="saving"
            size="large"
            class="save-button"
            style="border-radius: 10px; padding: 0 32px; height: 44px; font-weight: 600; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none; box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);"
          >
            保存
          </n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, h, computed } from 'vue'
import { useRouter } from 'vue-router'
import {
  NCard,
  NButton,
  NDataTable,
  NDynamicTags,
  NModal,
  NForm,
  NFormItem,
  NInput,
  NSwitch,
  NSpace,
  NIcon,
  NTag,
  useMessage,
  useDialog
} from 'naive-ui'
import { agentApi } from '@/api'
import type { Agent } from '@/types'

const router = useRouter()
const message = useMessage()
const dialog = useDialog()

const agents = ref<Agent[]>([])
const loading = ref(false)
const saving = ref(false)
const showCreateModal = ref(false)
const isEditing = ref(false)

const form = ref<Partial<Agent>>({
  name: '',
  description: '',
  instructions: '',
  keywords: '',
  status: true
})

const formRef = ref()

// 将 form.keywords 字符串与标签数组进行双向绑定
const keywordArray = computed({
  get: () => {
    if (!form.value.keywords) return []
    return form.value.keywords.split(/[，,]/).filter(t => t.trim() !== '')
  },
  set: (val: string[]) => {
    form.value.keywords = val.join(',')
  }
})

const rules = {
  name: { required: true, message: '请输入Agent名称', trigger: 'blur' },
  description: { required: true, message: '请输入Agent描述', trigger: 'blur' },
  instructions: { required: true, message: '请输入系统指令', trigger: 'blur' }
}

const pagination = ref({
  page: 1,
  pageSize: 10,
  itemCount: 0
})

// 表格行属性 - 添加悬停效果
const rowProps = () => ({
  style: 'transition: all 0.3s ease; cursor: pointer;',
  onMouseenter: (e: MouseEvent) => {
    const target = e.currentTarget as HTMLElement
    target.style.transform = 'scale(1.002)'
    target.style.boxShadow = '0 4px 12px rgba(0, 0, 0, 0.08)'
  },
  onMouseleave: (e: MouseEvent) => {
    const target = e.currentTarget as HTMLElement
    target.style.transform = 'scale(1)'
    target.style.boxShadow = 'none'
  }
})

const columns = [
  {
    title: '名称',
    key: 'name',
    width: 150,
    fixed: 'left',
    render: (row: Agent) => h('div', {
      class: 'font-semibold text-gray-900 dark:text-slate-100 text-base flex items-center',
      style: 'transition: color 0.3s ease;'
    }, [
      h('span', {
        class: 'inline-block w-2 h-2 rounded-full mr-3 animate-pulse',
        style: `background: ${row.status ? 'linear-gradient(135deg, #10b981, #059669)' : 'linear-gradient(135deg, #ef4444, #dc2626)'};`
      }),
      row.name
    ])
  },
  {
    title: '描述',
    key: 'description',
    width: 200,
    // 优化：描述列的弹窗提示框与系统指令保持一致
    ellipsis: {
      tooltip: {
        inverted: false,
        scrollable: true,
        style: {
          maxWidth: '600px',
          maxHeight: '450px'
        },
        class: 'instruction-tooltip-custom'
      }
    },
    render: (row: Agent) => h('span', {
      class: 'text-gray-600 text-sm'
    }, row.description)
  },
  {
    title: '系统指令',
    key: 'instructions',
    width: 250,
    ellipsis: {
      tooltip: {
        inverted: false, 
        scrollable: true,
        style: {
          maxWidth: '600px',
          maxHeight: '450px'
        },
        class: 'instruction-tooltip-custom'
      }
    },
    render: (row: Agent) => h('span', {
      class: 'text-gray-600 text-sm'
    }, row.instructions)
  },
  {
    title: '关键词',
    key: 'keywords',
    width: 200,
    render: (row: Agent) => {
      if (!row.keywords) return h('span', { class: 'text-gray-400 italic text-sm' }, '-')
      const tags = row.keywords.split(/[，,]/).filter(t => t.trim() !== '')
      return h(NSpace, { size: [6, 6] }, {
        default: () => tags.map((tag, index) => h(NTag, {
          size: 'small',
          bordered: false,
          type: 'info',
          round: true,
          style: `
            background: linear-gradient(135deg, ${['#e0e7ff', '#ddd6fe', '#fce7f3', '#dbeafe'][index % 4]}, ${['#c7d2fe', '#ddd6fe', '#fbcfe8', '#bfdbfe'][index % 4]});
            color: ${['#4f46e5', '#7c3aed', '#db2777', '#2563eb'][index % 4]};
            font-weight: 600;
            padding: 4px 12px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.08);
            transition: all 0.3s ease;
            cursor: pointer;
          `,
          onMouseenter: (e: MouseEvent) => {
            const target = e.currentTarget as HTMLElement
            target.style.transform = 'translateY(-2px)'
            target.style.boxShadow = '0 4px 8px rgba(0, 0, 0, 0.12)'
          },
          onMouseleave: (e: MouseEvent) => {
            const target = e.currentTarget as HTMLElement
            target.style.transform = 'translateY(0)'
            target.style.boxShadow = '0 2px 4px rgba(0, 0, 0, 0.08)'
          }
        }, () => tag))
      })
    }
  },
  {
    title: '状态',
    key: 'status',
    width: 100,
    align: 'center',
    render: (row: Agent) => h(NTag, {
      type: row.status ? 'success' : 'error',
      round: true,
      size: 'medium',
      style: `
        font-weight: 700;
        padding: 6px 16px;
        color: #FFFFFF;
        text-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        box-shadow: 0 4px 8px ${row.status ? 'rgba(16, 185, 129, 0.2)' : 'rgba(239, 68, 68, 0.2)'};
        background: ${row.status ? 'linear-gradient(135deg, #10b981, #059669)' : 'linear-gradient(135deg, #ef4444, #dc2626)'};
        border: none;
        transition: all 0.3s ease;
      `
    }, () => row.status ? '启用' : '禁用')
  },
  {
    title: '创建时间',
    key: 'createdAt',
    width: 170,
    render: (row: Agent) => h('span', {
      class: 'text-gray-500 text-sm font-medium'
    }, new Date(row.createdAt || '').toLocaleString())
  },
  {
    title: '操作',
    key: 'actions',
    width: 420,
    fixed: 'right',
    align: 'center',
    render: (row: Agent) => h(NSpace, { 
      size: 'small',
      justify: 'center'
    }, {
      default: () => [
        h(NButton, {
          size: 'small',
          strong: true,
          secondary: true,
          type: 'info',
          style: `border-radius: 8px; padding: 0 14px; height: 32px; font-weight: 500;`,
          onClick: (e) => { e.stopPropagation(); router.push(`/agents/${row.id}/intents`) }
        }, () => '意图管理'),
        h(NButton, {
          size: 'small',
          strong: true,
          secondary: true,
          type: 'info',
          style: `border-radius: 8px; padding: 0 14px; height: 32px; font-weight: 500;`,
          onClick: (e) => { e.stopPropagation(); router.push(`/agents/${row.id}/compliance`) }
        }, () => '合规规则'),
        h(NButton, {
          size: 'small',
          strong: true,
          secondary: true,
          type: 'info',
          style: `border-radius: 8px; padding: 0 14px; height: 32px; font-weight: 500;`,
          onClick: (e) => { e.stopPropagation(); router.push(`/agents/${row.id}/glossary`) }
        }, () => '术语库'),
        h(NButton, {
          size: 'small',
          strong: true,
          secondary: true,
          type: 'primary',
          style: `border-radius: 8px; padding: 0 14px; height: 32px; font-weight: 600;`,
          onClick: (e) => { e.stopPropagation(); handleEdit(row) }
        }, () => '编辑'),
        h(NButton, {
          size: 'small',
          strong: true,
          secondary: true,
          type: row.status ? 'error' : 'success',
          style: `border-radius: 8px; padding: 0 14px; height: 32px; font-weight: 600;`,
          onClick: (e) => { e.stopPropagation(); handleToggleStatus(row) }
        }, () => row.status ? '禁用' : '启用')
      ]
    })
  }
]

const loadAgents = async () => {
  loading.value = true
  try {
    const response = await agentApi.list()
    agents.value = response.data
    pagination.value.itemCount = response.data.length
  } catch (error) {
    message.error('加载 Agent 列表失败')
  } finally {
    loading.value = false
  }
}

const handleCreate = () => {
  form.value = { name: '', description: '', instructions: '', keywords: '', status: true }
  isEditing.value = false
  showCreateModal.value = true
}

const handlePageChange = (page: number) => {
  pagination.value.page = page
  loadAgents()
}

const handleSave = async () => {
  try {
    await formRef.value?.validate()
    saving.value = true
    if (isEditing.value && form.value.id) {
      await agentApi.update(form.value.id, form.value)
      message.success('更新成功')
    } else {
      await agentApi.create(form.value as Omit<Agent, 'id'>)
      message.success('创建成功')
    }
    showCreateModal.value = false
    await loadAgents()
  } catch (error) {
    console.error('Validation failed', error)
  } finally {
    saving.value = false
  }
}

const handleEdit = (agent: Agent) => {
  form.value = { ...agent }
  isEditing.value = true
  showCreateModal.value = true
}

const handleToggleStatus = async (agent: Agent) => {
  const action = agent.status ? '禁用' : '启用'
  const newStatus = agent.status ? 0 : 1
  dialog.warning({
    title: `确认${action}`,
    content: `确定要${action} Agent "${agent.name}" 吗？`,
    positiveText: '确定',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await agentApi.updateStatus(agent.id!, newStatus)
        message.success(`${action}成功`)
        await loadAgents()
      } catch (error) {
        message.error(`${action}失败`)
      }
    }
  })
}

onMounted(() => {
  loadAgents()
})
</script>

<style scoped>
@keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
@keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.5; } }
.animate-fade-in { animation: fadeIn 0.6s ease-out; }
.animate-slide-up { animation: slideUp 0.8s ease-out; }
.animate-pulse { animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite; }

:deep(.modal-theme-custom.n-dialog) .n-dialog__icon,
:deep(.modal-theme-custom.n-dialog) .n-base-icon,
:deep(.modal-theme-custom.n-dialog) .n-base-icon svg {
  color: #764ba2 !important;
  fill: #764ba2 !important;
}
:deep(.modal-theme-custom.n-dialog) .n-dialog__icon svg path { fill: #764ba2 !important; }
:deep(.modal-theme-custom .n-dialog__header) { font-weight: 700 !important; }

.form-item-enhanced { margin-bottom: 24px; transition: all 0.3s ease; }
.form-item-enhanced:hover { transform: translateX(4px); }
.input-enhanced:hover :deep(.n-input__border) { border-color: #667eea !important; }
.input-enhanced:focus-within :deep(.n-input__border) {
  border-color: #764ba2 !important;
  box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.2) !important;
}
.input-enhanced:focus-within :deep(.n-input__state-border) { border-color: #764ba2 !important; }

.switch-theme-custom.n-switch--active :deep(.n-switch__rail) { background-color: #764ba2 !important; }

.create-button:hover {
  transform: scale(1.05) translateY(-2px);
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4) !important;
}
.table-card:hover { transform: translateY(-2px); box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15) !important; }

.cancel-button:hover { background-color: #f3f4f6; transform: translateY(-1px); }
.save-button:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5) !important; }

:deep(.n-data-table-th) {
  background: linear-gradient(to bottom, #f9fafb, #f3f4f6) !important;
  font-weight: 700 !important;
  color: #374151 !important;
  border-bottom: 2px solid #e5e7eb !important;
  text-transform: uppercase;
}

@media (prefers-color-scheme: dark) {
  .agent-list { background: linear-gradient(to bottom right, #111827, #1e1b4b); }
  :deep(.n-card) { background-color: rgba(30, 41, 59, 0.95) !important; }
}

:deep(.n-pagination-item--active) {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
}
</style>

<style>
/* 全局样式：用于修改 body 下的弹出层 */
.n-tooltip.instruction-tooltip-custom {
  background-color: #ffffff !important;
  border: 1px solid #e2e8f0 !important;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1) !important;
  padding: 16px !important;
  border-radius: 12px !important;
}
.n-tooltip.instruction-tooltip-custom .n-tooltip__arrow {
  background-color: #ffffff !important;
  border-bottom: 1px solid #e2e8f0 !important;
  border-right: 1px solid #e2e8f0 !important;
}
.instruction-tooltip-custom {
  color: #334155 !important;
  line-height: 1.7 !important;
  font-size: 14px !important;
  white-space: pre-wrap !important;
  word-break: break-all !important;
  font-family: system-ui, -apple-system, sans-serif !important;
}

:deep(.n-dynamic-tags .n-tag) {
  border-radius: 6px;
  font-weight: 500;
}
:deep(.n-dynamic-tags .n-button) {
  border-radius: 6px;
}
</style>