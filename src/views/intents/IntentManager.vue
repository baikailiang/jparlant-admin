<template>
  <!-- 根容器 -->
  <div class="intent-manager min-h-screen transition-colors duration-500 bg-gradient-to-br from-gray-50 via-white to-blue-50/30 dark:from-[#0f172a] dark:via-[#1e293b] dark:to-[#0f172a] px-8 py-8">
    <div class="flex items-center justify-between mb-10">
      <div class="flex items-center space-x-5 animate-fade-in">
        <n-button 
          @click="router.push('/agents')" 
          quaternary 
          circle 
          size="large" 
          class="hover:bg-blue-50 dark:hover:bg-slate-800 transition-all duration-300 shadow-sm bg-white dark:bg-slate-900"
        >
          <template #icon>
            <n-icon size="24" class="text-gray-700 dark:text-slate-200">
              <svg viewBox="0 0 24 24"><path fill="currentColor" d="M20 11H7.83l5.59-5.59L12 4l-8 8l8 8l1.41-1.41L7.83 13H20v-2z"/></svg>
            </n-icon>
          </template>
        </n-button>
        <div>
          <h1
            class="flex items-center text-3xl font-bold tracking-tight 
                  bg-gradient-to-r from-blue-600 to-purple-600 
                  bg-clip-text text-transparent"
          >
            <span>意图管理</span>
            <!-- 后面新增的装饰性图标方块 -->
            <div
              class="ml-4 flex items-center justify-center 
                    w-10 h-10 rounded-2xl
                    bg-gradient-to-tr from-blue-600 to-indigo-600
                    shadow-lg shadow-blue-300/40
                    text-white
                    transition-all duration-300
                    hover:scale-110 hover:rotate-3"
            >
              <n-icon size="24">
                <svg viewBox="0 0 24 24">
                  <path fill="currentColor" d="M12 2c-5.52 0-10 4.48-10 10s4.48 10 10 10s10-4.48 10-10s-4.48-10-10-10zm0 18c-4.42 0-8-3.58-8-8s3.58-8 8-8s8 3.58 8 8s-3.58 8-8 8zm.5-13h-1v6l5.2 3.2l.8-1.3l-4.5-2.7V7z"/>
                </svg>
              </n-icon>
            </div>
          </h1>
          
          <!-- 1. 优化后的身份标识与描述 -->
          <div class="mt-3 flex items-center space-x-3 text-sm">
            <div class="flex items-center bg-white dark:bg-slate-800 px-3 py-1.5 rounded-full shadow-sm border border-gray-100 dark:border-slate-700">
              <span class="relative flex h-2 w-2 mr-2">
                <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                <span class="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
              </span>
              <span class="font-bold text-gray-700 dark:text-slate-200">{{ currentAgent?.name }}</span>
            </div>
            <div class="h-4 w-px bg-gray-300 dark:bg-slate-700"></div>
            <div class="flex items-center text-gray-500 dark:text-slate-400 font-medium">
              <n-icon class="mr-1.5 text-blue-500" size="18">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8s8 3.59 8 8s-3.59 8-8 8zm.5-13H11v6l5.2 3.2l.8-1.3l-4.5-2.7V7z"/></svg>
              </n-icon>
              意图识别与流程配置中心
            </div>
          </div>
        </div>
      </div>
      <n-button
        type="primary"
        size="large"
        @click="handleCreateIntent"
        class="shadow-xl shadow-blue-500/20 hover:shadow-blue-500/40 transition-all duration-300 hover:-translate-y-1"
        style="height: 52px; border-radius: 14px; background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%); border: none; font-weight: 700; padding: 0 28px;"
      >
        <template #icon>
          <n-icon size="20"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.477 2 2 6.477 2 12s4.477 10 10 10s10-4.477 10-10S17.523 2 12 2m5 11h-4v4h-2v-4H7v-2h4V7h2v4h4z"/></svg></n-icon>
        </template>
        创建新意图
      </n-button>
    </div>

    <!-- 意图卡片列表 -->
    <div class="grid grid-cols-1 lg:grid-cols-2 xl:grid-cols-3 gap-8 animate-slide-up">
      <n-card
        v-for="intent in intents"
        :key="intent.id"
        class="intent-card group cursor-pointer"
        style="border-radius: 20px; overflow: hidden;"
        @click="handleViewSteps(intent)" 
      >
        <!-- 2. 全卡片点击跳转逻辑已绑定在 @click -->
        
        <template #header>
          <div class="flex items-center justify-between">
            <div class="flex items-center space-x-3">
              <div class="relative">
                <div class="w-3 h-3 rounded-full"
                     :class="intent.enabled ? 'bg-green-500 shadow-lg shadow-green-500/50' : 'bg-gray-400'"
                ></div>
                <div v-if="intent.enabled" class="absolute inset-0 w-3 h-3 rounded-full bg-green-500 animate-ping opacity-75"></div>
              </div>
              <span class="font-bold text-lg text-gray-900 dark:text-slate-100 group-hover:text-blue-600 dark:group-hover:text-blue-400 transition-colors duration-300">{{ intent.name }}</span>
            </div>
            <n-tag
              :type="getFlowTypeTag(intent.flowType)"
              size="small"
              round
              :bordered="false"
              class="font-bold px-3"
            >
              {{ getFlowTypeLabel(intent.flowType) }}
            </n-tag>
          </div>
        </template>

        <div class="space-y-6">
          <n-tooltip trigger="hover" :disabled="!intent.description || intent.description.length <= 100">
            <template #trigger>
              <p class="text-[14px] text-gray-500 dark:text-slate-400 line-clamp-3 min-h-[60px] leading-relaxed">
                {{ intent.description || '暂无详细描述信息' }}
              </p>
            </template>
            {{ intent.description }}
          </n-tooltip>

          <div class="flex items-center justify-between pt-5 border-t border-gray-100 dark:border-slate-800">
            <div class="flex flex-col">
              <span class="text-[10px] uppercase tracking-wider text-gray-400 font-bold mb-1">Created At</span>
              <span class="text-xs text-gray-600 dark:text-slate-500 font-medium">
                {{ formatDate(intent.createdAt) }}
              </span>
            </div>
            
            <!-- 3. 重新设计的按钮组 -->
            <div class="flex space-x-3" @click.stop> <!-- 阻止冒泡，避免触发卡片点击 -->
              <n-button
                @click="handleTestChat(intent)"
                class="test-btn"
                style="border-radius: 10px; font-weight: 800; border: none;"
              >
                <template #icon>
                  <n-icon><svg viewBox="0 0 24 24"><path fill="currentColor" d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2m0 14H5.2L4 17.2V4h16v12Z"/></svg></n-icon>
                </template>
                测试对话
              </n-button>
              
              <n-button
                type="primary"
                @click="handleViewSteps(intent)"
                class="flow-btn"
                style="border-radius: 10px; font-weight: 800; border: none;"
              >
                <template #icon>
                  <n-icon><svg viewBox="0 0 24 24"><path fill="currentColor" d="M13 11H9V8H5v8h4v-3h4v3h4V8h-4v3zm6-7H5c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2z"/></svg></n-icon>
                </template>
                流程编排
              </n-button>

              <n-dropdown
                trigger="click"
                :options="getDropdownOptions(intent)"
                @select="(key) => handleAction(key, intent)"
              >
                <n-button quaternary circle class="hover:bg-gray-100 dark:hover:bg-slate-800">
                  <template #icon>
                    <n-icon size="20"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 8c1.1 0 2-.9 2-2s-.9-2-2-2s-2 .9-2 2s.9 2 2 2m0 2c-1.1 0-2 .9-2 2s.9 2 2 2s2-.9 2-2s-.9-2-2-2m0 6c-1.1 0-2 .9-2 2s.9 2 2 2s2-.9 2-2s-.9-2-2-2"/></svg></n-icon>
                  </template>
                </n-button>
              </n-dropdown>
            </div>
          </div>
        </div>
      </n-card>
    </div>

    <!-- 空状态 -->
    <div v-if="intents.length === 0 && !loading" class="flex flex-col items-center justify-center py-32 animate-fade-in">
      <div class="w-24 h-24 bg-blue-50 dark:bg-slate-800 rounded-3xl flex items-center justify-center mb-6 shadow-inner">
        <span class="text-5xl">🎯</span>
      </div>
      <h3 class="text-2xl font-black text-gray-900 dark:text-white mb-2">配置您的第一个意图</h3>
      <p class="text-gray-500 dark:text-slate-400 mb-8">定义 Agent 如何理解用户需求并触发相应的业务逻辑</p>
      <n-button
        type="primary"
        size="large"
        @click="handleCreateIntent"
        class="px-10"
        style="height: 52px; border-radius: 14px; background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%); border: none; font-weight: 700;"
      >
        立即开始
      </n-button>
    </div>

    <!-- 创建/编辑意图 Modal -->
    <n-modal
        v-model:show="showCreateModal"
      :mask-closable="false"
      preset="card"
      :title="editingIntent ? '编辑意图' : '新建意图'"
      class="modern-modal animate-scale-in"
      style="width: 650px; border-radius: 28px; border: none; box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);"
    >
      <!-- 头部装饰 -->
      <template #header>
        <div class="flex items-center space-x-3">
          <div class="w-1.5 h-6 bg-gradient-to-b from-blue-600 to-purple-600 rounded-full"></div>
          <span class="text-xl font-black text-gray-900 dark:text-white tracking-tight">
            {{ editingIntent ? '编辑核心意图' : '定义新意图' }}
          </span>
        </div>
      </template>
      <n-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-placement="top"
        class="py-4 space-y-6"
      >
        <n-form-item label="意图名称" path="name">
          <template #label>
            <span class="text-sm font-bold text-gray-700 dark:text-gray-300 ml-1">意图名称</span>
          </template>
          <n-input 
            v-model:value="form.name" 
            placeholder="例如：查询订单、人工服务" 
            size="large" 
            style="border-radius: 14px;"
            class="hover:shadow-sm transition-all"
          />
        </n-form-item>

        <n-form-item label="语义描述" path="description">
          <template #label>
            <div class="flex items-center ml-1">
              <span class="text-sm font-bold text-gray-700 dark:text-gray-300">详细语义描述</span>
              <n-tooltip trigger="hover" placement="right">
                <template #trigger>
                  <n-icon size="14" class="ml-1 text-gray-400 cursor-help"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M11 18h2v-2h-2v2m1-16A10 10 0 0 0 2 12a10 10 0 0 0 10 10a10 10 0 0 0 10-10A10 10 0 0 0 12 2m0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8s8 3.59 8 8s-3.59 8-8 8m0-14a4 4 0 0 0-4 4h2a2 2 0 0 1 2-2a2 2 0 0 1 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5a4 4 0 0 0-4-4z"/></svg></n-icon>
                </template>
                描述此意图在什么场景下被触发，LLM 将通过此内容进行语义识别。
              </n-tooltip>
            </div>
          </template>
          <n-input 
            v-model:value="form.description" 
            type="textarea" 
            :rows="5" 
            placeholder="请详细描述该意图的覆盖场景..." 
            style="border-radius: 14px;"
            class="hover:shadow-sm transition-all"
          />
        </n-form-item>

        <!-- 状态开关：优化为胶囊样式容器 -->
        <div class="flex items-center justify-between p-5 bg-blue-50/40 dark:bg-slate-800/50 rounded-2xl border border-blue-100 dark:border-slate-700 transition-all hover:border-blue-200">
          <div class="flex flex-col">
            <span class="font-bold text-gray-800 dark:text-slate-200">启用此意图</span>
            <span class="text-xs text-gray-500 mt-0.5">关闭后，Agent 将不再识别和响应此意图</span>
          </div>
          <n-switch 
            v-model:value="form.enabled" 
            size="large"
            class="modern-switch"
          />
        </div>
      </n-form>
      <template #action>
        <div class="flex justify-end space-x-4">
          <n-button 
            @click="showCreateModal = false" 
            size="large"
            quaternary
            style="border-radius: 12px; font-weight: 700; padding: 0 24px;"
          >
            放弃修改
          </n-button>
          <n-button 
            type="primary" 
            @click="handleSave" 
            :loading="saving" 
            size="large"
            class="shadow-lg shadow-indigo-500/30 transition-all hover:-translate-y-0.5"
            style="height: 48px; border-radius: 12px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none; font-weight: 700; padding: 0 32px;"
          >
            {{ editingIntent ? '保存更新' : '立即创建' }}
          </n-button>
        </div>
      </template>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, h } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {
  NCard, NButton, NIcon, NTag, NDropdown, NModal, NForm, NFormItem, NInput, NSwitch, NSpace, NTooltip, useMessage, useDialog
} from 'naive-ui'
import { agentApi, intentApi } from '@/api'
import type { Agent, AgentIntent, FlowType } from '@/types'

const route = useRoute()
const router = useRouter()
const message = useMessage()
const dialog = useDialog()

const currentAgent = ref<Agent>()
const intents = ref<AgentIntent[]>([])
const loading = ref(true)
const saving = ref(false)
const showCreateModal = ref(false)
const editingIntent = ref<AgentIntent>()

const form = ref<Partial<AgentIntent>>({
  name: '',
  description: '',
  flowType: 'LINEAR',
  enabled: true
})

const formRef = ref()
const rules = {
  name: { required: true, message: '请输入意图名称', trigger: 'blur' },
  description: { required: true, message: '请输入意图描述', trigger: 'blur' }
}

const agentId = computed(() => parseInt(route.params.id as string))

const loadAgent = async () => {
  try {
    const response = await agentApi.get(agentId.value)
    currentAgent.value = response.data
  } catch (error) { message.error('加载 Agent 失败') }
}

const loadIntents = async () => {
  loading.value = true
  try {
    const response = await intentApi.listByAgent(agentId.value)
    intents.value = response.data
  } catch (error) { message.error('加载意图失败') }
  finally { loading.value = false }
}

const getFlowTypeLabel = (flowType: FlowType) => {
  const labels = { LINEAR: '线性流程', CONDITIONAL: '条件分支', LOOP: '循环执行', INTERACTIVE: '交互式' }
  return labels[flowType] || flowType
}

const getFlowTypeTag = (flowType: FlowType) => {
  const tags = { LINEAR: 'info', CONDITIONAL: 'warning', LOOP: 'error', INTERACTIVE: 'success' }
  return tags[flowType] || 'default'
}

const formatDate = (dateStr?: string) => dateStr ? new Date(dateStr).toLocaleDateString() : '-'

const getDropdownOptions = (intent: AgentIntent) => [
  { label: '基础编辑', key: 'edit', icon: () => '✏️' },
  { label: intent.enabled ? '立即禁用' : '激活启用', key: 'toggle', icon: () => intent.enabled ? '🚫' : '✅' },
  { label: '彻底删除', key: 'delete', icon: () => '🗑️' }
]

const handleCreateIntent = () => {
  editingIntent.value = undefined
  form.value = { name: '', description: '', flowType: 'LINEAR', enabled: true }
  showCreateModal.value = true
}

const handleEditIntent = (intent: AgentIntent) => {
  editingIntent.value = intent
  form.value = { ...intent }
  showCreateModal.value = true
}

const handleViewSteps = (intent: AgentIntent) => {
  router.push({ path: `/agents/${agentId.value}/flows`, query: { intentId: intent.id } })
}

const handleTestChat = (intent: AgentIntent) => {
  router.push({ path: `/agents/${agentId.value}/intents/${intent.id}/chat` })
}

const handleAction = async (key: string, intent: AgentIntent) => {
  if (key === 'edit') handleEditIntent(intent)
  else if (key === 'toggle') {
    try {
      await intentApi.update(intent.id!, { enabled: !intent.enabled })
      message.success('状态更新成功')
      await loadIntents()
    } catch (e) { message.error('操作失败') }
  } else if (key === 'delete') {
    dialog.warning({
      title: '确认删除意图',
      content: `意图 "${intent.name}" 被删除后，相关的流程配置也将无法生效。`,
      positiveText: '确认',
      onPositiveClick: async () => {
        try {
          await intentApi.delete(intent.id!)
          message.success('删除成功')
          await loadIntents()
        } catch (e) { message.error('删除失败') }
      }
    })
  }
}

const handleSave = async () => {
  try {
    await formRef.value?.validate()
    saving.value = true
    const intentData = { ...form.value, agentId: agentId.value }
    if (editingIntent.value) await intentApi.update(editingIntent.value.id!, intentData)
    else await intentApi.create(intentData as any)
    message.success('保存成功')
    showCreateModal.value = false
    await loadIntents()
  } catch (e) { } finally { saving.value = false }
}

onMounted(async () => {
  await loadAgent()
  await loadIntents()
})
</script>

<style scoped>
/* 开关激活时的颜色 */
.modern-switch.n-switch--active :deep(.n-switch__rail) {
  background-color: #764ba2 !important;
}

/* 弹窗缩放动画 */
@keyframes scaleIn {
  from { opacity: 0; transform: scale(0.95); }
  to { opacity: 1; transform: scale(1); }
}
.animate-scale-in {
  animation: scaleIn 0.3s cubic-bezier(0.16, 1, 0.3, 1);
}

/* 覆盖 Naive UI 弹窗内部边距 */
:deep(.modern-modal.n-card > .n-card__footer),
:deep(.modern-modal.n-card > .n-card__action) {
  padding: 24px 32px 32px !important;
  background-color: transparent;
}
:deep(.modern-modal.n-card > .n-card__content) {
  padding: 12px 32px !important;
}
:deep(.modern-modal.n-card-header) {
  padding: 32px 32px 20px !important;
}

.intent-card {
  transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1);
  border: 1px solid #f1f5f9;
  background: white;
}
.intent-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 20px 25px -5px rgba(59, 130, 246, 0.1), 0 10px 10px -5px rgba(59, 130, 246, 0.04);
  border-color: #bfdbfe;
}

/* 按钮样式优化 */
.test-btn {
  color: #16a34a !important;
  background: #f0fdf4 !important;
  height: 40px !important;
  padding: 0 16px !important;
}
.test-btn:hover {
  background: #dcfce7 !important;
  transform: translateY(-1px);
}

.flow-btn {
  background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%) !important;
  box-shadow: 0 4px 12px rgba(37, 99, 235, 0.2);
  height: 40px !important;
  padding: 0 16px !important;
}
.flow-btn:hover {
  box-shadow: 0 6px 16px rgba(37, 99, 235, 0.3);
  transform: translateY(-1px);
}

@media (prefers-color-scheme: dark) {
  .intent-card {
    background: #1e293b;
    border-color: #334155;
  }
  .test-btn {
    background: rgba(22, 163, 74, 0.1) !important;
  }
}

.line-clamp-3 {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

@keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
.animate-fade-in { animation: fadeIn 0.4s ease-out; }
.animate-slide-up { animation: slideUp 0.5s ease-out; }

:deep(.n-card-header) {
  padding: 24px 24px 16px 24px;
}
</style>