<template>
  <div class="compliance-manager px-6 py-8 min-h-screen bg-gradient-to-br from-gray-50 to-blue-50 relative overflow-hidden">
    <!-- 背景氛围装饰：淡淡的几何网格 -->
    <div class="absolute top-0 left-0 w-full h-64 opacity-5 pointer-events-none" 
         style="background-image: radial-gradient(#3b82f6 1px, transparent 1px); background-size: 24px 24px;"></div>

    <!-- 顶部操作栏 -->
    <div class="flex items-center justify-between mb-8 animate-fade-in relative z-10">
      <div class="flex items-center space-x-5">
        <!-- 返回按钮 -->
        <n-button @click="router.push('/agents')" quaternary circle class="bg-white shadow-sm hover:shadow-md transition-all duration-300">
          <template #icon>
            <n-icon size="20" class="text-gray-600"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M20 11H7.83l5.59-5.59L12 4l-8 8l8 8l1.41-1.41L7.83 13H20v-2z"/></svg></n-icon>
          </template>
        </n-button>

        <div class="space-y-2">
          <div class="flex items-center">
            <h1 class="text-3xl font-extrabold text-gray-900 tracking-tight bg-gradient-to-r from-slate-800 to-blue-900 bg-clip-text text-transparent">
              合规规则管理
            </h1>
            <div class="ml-4 flex items-center justify-center w-9 h-9 rounded-xl bg-gradient-to-tr from-blue-600 to-indigo-600 shadow-lg shadow-blue-200 text-white transition-transform duration-300 hover:scale-110">
              <n-icon size="20">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12c5.16-1.26 9-6.45 9-12V5l-9-4m-2 16l-4-4l1.41-1.41L10 14.17l6.59-6.59L18 9l-8 8Z"/></svg>
              </n-icon>
            </div>
          </div>
          <div class="flex items-center">
            <p class="text-[14px] text-gray-500 font-medium flex items-center">
              <span class="mr-2 inline-flex items-center px-3 py-1 bg-white border border-blue-100 rounded-lg shadow-sm group transition-all duration-300 hover:border-blue-300">
                <n-icon size="16" class="text-blue-600 mr-2">
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7v8H3v-8a7 7 0 0 1 7-7h1V5.73c-.6-.34-1-.99-1-1.73a2 2 0 0 1 2-2M10 10v2h4v-2h-4m-3 4v2h2v-2H7m8 0v2h2v-2h-2z"/></svg>
                </n-icon>
                <span class="text-blue-800 font-bold tracking-wide">{{ currentAgent?.name }}</span>
              </span>
              <span class="text-gray-400">的输入输出校验规则库</span>
            </p>
          </div>
        </div>
      </div>

      <n-button
        type="primary"
        @click="handleCreate"
        size="large"
        class="create-button shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-105"
        style="border-radius: 12px; padding: 0 24px; height: 44px; font-weight: 600; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none;"
      >
        <template #icon>
          <n-icon size="20"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.477 2 2 6.477 2 12s4.477 10 10 10s10-4.477 10-10S17.523 2 12 2m5 11h-4v4h-2v-4H7v-2h4V7h2v4h4z"/></svg></n-icon>
        </template>
        新增规则
      </n-button>
    </div>

    <!-- 规则列表 -->
    <n-card
      class="table-card shadow-2xl border-0 animate-slide-up"
      style="border-radius: 16px; overflow: hidden; backdrop-filter: blur(10px); background: rgba(255, 255, 255, 0.95);"
      :bordered="false"
    >
      <n-data-table
        :columns="columns"
        :data="rules"
        :loading="loading"
        :pagination="pagination"
        remote
        @update:page="handlePageChange"
        :row-props="rowProps"
        style="--n-th-padding: 16px 12px; --n-td-padding: 16px 12px; --n-font-size: 14px;"
      />
    </n-card>

    <!-- 创建/编辑规则 Modal -->
    <n-modal
      v-model:show="showCreateModal"
      preset="dialog"
      title="合规策略配置"
      class="w-5xl modal-theme-custom modal-animate"
      :style="{ width: '1100px', borderRadius: '24px', overflow: 'hidden' }"
      :mask-closable="false"
    >
      <n-form
        ref="formRef"
        :model="form"
        :rules="formRules"
        label-width="120px"
        label-placement="top"
        class="mt-4"
      >
        <!-- 基础配置全宽展示 -->
        <div class="grid grid-cols-12 gap-6 mb-6 bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
           <n-form-item label="规则名称" path="name" class="col-span-4">
              <n-input v-model:value="form.name" placeholder="为这条规则命名" size="large" />
           </n-form-item>
           <n-form-item label="规则简述" path="description" class="col-span-8">
              <n-input v-model:value="form.description" type="textarea" :rows="2" placeholder="描述该规则的拦截意图和业务场景" size="large" />
           </n-form-item>
        </div>

        <div class="grid grid-cols-12 gap-6">
          <!-- 左侧：执行策略 -->
          <div class="col-span-4 space-y-4 bg-gray-50/50 p-6 rounded-2xl border border-gray-100">
            <h3 class="text-sm font-bold text-gray-400 uppercase tracking-wider mb-4 flex items-center">
               <n-icon class="mr-2 text-blue-500"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 22C6.477 22 2 17.523 2 12S6.477 2 12 2s10 4.477 10 10s-4.477 10-10 10zm0-2a8 8 0 1 0 0-16a8 8 0 0 0 0 16zm-1-5h2v2h-2v-2zm0-8h2v6h-2V7z"/></svg></n-icon>
               执行策略
            </h3>
            
            <n-form-item label="检查范围" path="scope">
              <n-select v-model:value="form.scope" :options="scopeOptions" :consistent-menu-width="false" size="large" />
            </n-form-item>

            <n-form-item label="优先级" path="priority">
              <n-input-number v-model:value="form.priority" :min="1" :max="999" style="width: 100%" size="large" />
              <template #feedback>
                 <span class="text-blue-500 font-medium text-xs">提示：数字越小，该规则越先被触发执行</span>
              </template>
            </n-form-item>

            <n-form-item label="拦截提示语" path="blockedResponse">
              <n-input v-model:value="form.blockedResponse" type="textarea" :rows="4" placeholder="规则触发时，直接显示给用户的消息" />
            </n-form-item>

            <n-form-item label="规则启用状态">
              <n-switch v-model:value="form.enabled" size="large" class="switch-theme-custom" />
            </n-form-item>
          </div>

          <!-- 右侧：整合后的匹配逻辑容器 -->
          <div class="col-span-8 p-6 rounded-2xl border border-blue-100 bg-blue-50/30">
            <div class="mb-6 p-4 bg-white/60 border-l-4 border-blue-500 rounded-r-xl shadow-sm">
              <h3 class="text-base font-black text-gray-800 mb-3">合规校验逻辑配置</h3>
              <div class="flex items-center space-x-2 text-sm text-blue-700 font-bold bg-blue-100/50 py-2 px-3 rounded-lg border border-blue-200 mb-4 inline-flex">
                <template v-for="(item, index) in logicSteps" :key="item">
                  <span
                    :class="index === logicSteps.length - 1 ? 'text-blue-900 bg-blue-300/50 px-2 rounded' : ''"
                  >
                    {{ index + 1 }}.{{ item }}
                  </span>
                  <n-icon v-if="index !== logicSteps.length - 1">
                    <svg viewBox="0 0 24 24">
                      <path fill="currentColor"
                        d="M8.59 16.59L13.17 12L8.59 7.41L10 6l6 6l-6 6l-1.41-1.41z"/>
                    </svg>
                  </n-icon>
                </template>
              </div>
              <div class="flex items-center px-3 py-2 bg-amber-100/80 border border-amber-300 rounded-lg">
                  <n-icon class="text-amber-600 mr-2 animate-pulse" size="18"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg></n-icon>
                  <span class="text-amber-700 text-xs font-black">执行逻辑：系统按顺序扫描，命中任何一级则立即停止后续校验。</span>
              </div>
            </div>

            <div class="space-y-6">
              <!-- 1. 关键词配置 -->
              <div class="p-4 bg-white/50 rounded-xl border border-blue-200 shadow-sm">
                <n-form-item>
                  <template #label>
                    <div class="flex items-center">
                      <span class="font-bold text-gray-800">1. 关键词黑名单</span>
                      <n-tooltip trigger="hover" placement="top">
                        <template #trigger>
                          <n-icon class="ml-1 text-gray-400 cursor-help" size="16">
                            <svg viewBox="0 0 24 24"><path fill="currentColor" d="M11 18h2v-2h-2v2m1-16A10 10 0 0 0 2 12a10 10 0 0 0 10 10a10 10 0 0 0 10-10A10 10 0 0 0 12 2m0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8s8 3.59 8 8s-3.59 8-8 8m0-14a4 4 0 0 0-4 4h2a2 2 0 0 1 2-2a2 2 0 0 1 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5a4 4 0 0 0-4-4z"/></svg>
                          </n-icon>
                        </template>
                        {{ tooltipTexts.keyword }}
                      </n-tooltip>
                    </div>
                  </template>
                  <n-dynamic-tags 
                    v-model:value="keywords" 
                    size="large"
                    style="width: 100%;"
                    :input-props="{ 
                      placeholder: '输入敏感词并回车',
                      style: { width: '260px' }
                    }"
                  />


                </n-form-item>
              </div>
              
              <!-- 2. 正则配置 -->
              <div class="p-4 bg-white/50 rounded-xl border border-blue-200 shadow-sm">
                <n-form-item>
                  <template #label>
                    <div class="flex items-center">
                      <span class="font-bold text-gray-800">2. 正则表达式模式</span>
                      <n-tooltip trigger="hover" placement="top">
                        <template #trigger>
                          <n-icon class="ml-1 text-gray-400 cursor-help" size="16">
                            <svg viewBox="0 0 24 24"><path fill="currentColor" d="M11 18h2v-2h-2v2m1-16A10 10 0 0 0 2 12a10 10 0 0 0 10 10a10 10 0 0 0 10-10A10 10 0 0 0 12 2m0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8s8 3.59 8 8s-3.59 8-8 8m0-14a4 4 0 0 0-4 4h2a2 2 0 0 1 2-2a2 2 0 0 1 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5a4 4 0 0 0-4-4z"/></svg>
                          </n-icon>
                        </template>
                        {{ tooltipTexts.regex }}
                      </n-tooltip>
                    </div>
                  </template>

                  <n-dynamic-tags 
                    v-model:value="regexList" 
                    size="large"
                    style="width: 100%;"
                    :input-props="{
                      placeholder: '输入正则表达式并回车',
                      style: { width: '320px' }
                    }"
                  />
                </n-form-item>
              </div>

              <!-- 3. SpEL配置 -->
              <div class="p-4 bg-white/50 rounded-xl border border-blue-200 shadow-sm">
                <n-form-item>
                  <template #label>
                    <div class="flex items-center">
                      <span class="font-bold text-gray-800">3. SpEL 逻辑判断</span>
                      <n-tooltip trigger="hover" placement="top">
                        <template #trigger>
                          <n-icon class="ml-1 text-gray-400 cursor-help" size="16">
                            <svg viewBox="0 0 24 24"><path fill="currentColor" d="M11 18h2v-2h-2v2m1-16A10 10 0 0 0 2 12a10 10 0 0 0 10 10a10 10 0 0 0 10-10A10 10 0 0 0 12 2m0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8s8 3.59 8 8s-3.59 8-8 8m0-14a4 4 0 0 0-4 4h2a2 2 0 0 1 2-2a2 2 0 0 1 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5a4 4 0 0 0-4-4z"/></svg>
                          </n-icon>
                        </template>
                        {{ tooltipTexts.spel }}
                      </n-tooltip>
                    </div>
                  </template>
                  <div class="w-full space-y-3">
                    <div class="flex items-center gap-2">
                      <n-select
                        v-model:value="selectedVariable"
                        :options="variableOptions"
                        placeholder="选择变量插入"
                        size="small"
                        clearable
                        style="width: 200px;"
                        @update:value="handleVariableSelect"
                      />
                      <span class="text-xs text-gray-400">选择变量后自动插入到输入框</span>
                    </div>
                    <n-input
                      ref="spelInputRef"
                      v-model:value="form.conditionExpr"
                      type="textarea"
                      :autosize="{ minRows: 2, maxRows: 4 }"
                      placeholder="示例：#content.length() > 1000"
                    />
                  </div>
                </n-form-item>
              </div>

              <!-- 4. AI 审核层 -->
              <div v-if="form.scope === 'ALL' || form.scope === 'INPUT'" class="p-4 bg-white/50 rounded-xl border border-blue-200 shadow-sm">
                <div class="relative">
                  <n-form-item>
                  <template #label>
                    <div class="flex items-center justify-between w-full">
                      <div class="flex items-center">
                        <span class="font-bold text-gray-800">4. AI 智能审核指令</span>
                        <n-tooltip trigger="hover" placement="top">
                          <template #trigger>
                            <n-icon class="ml-1 text-gray-400 cursor-help" size="16">
                              <svg viewBox="0 0 24 24"><path fill="currentColor" d="M11 18h2v-2h-2v2m1-16A10 10 0 0 0 2 12a10 10 0 0 0 10 10a10 10 0 0 0 10-10A10 10 0 0 0 12 2m0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8s8 3.59 8 8s-3.59 8-8 8m0-14a4 4 0 0 0-4 4h2a2 2 0 0 1 2-2a2 2 0 0 1 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5a4 4 0 0 0-4-4z"/></svg>
                            </n-icon>
                          </template>
                          {{ tooltipTexts.ai }}
                        </n-tooltip>
                      </div>
                      
                    </div>
                  </template>
                  <n-input v-model:value="form.guidelinePrompt" type="textarea" :rows="4" placeholder="请详细描述 AI 应当如何判定内容是否违规。例如：'判断内容中是否包含任何针对特定品牌的负面评价或恶意对比。'" />
                </n-form-item>

                <div
                  v-if="form.scope === 'ALL'"
                    class="absolute top-0 right-0 flex items-center px-3 py-1 bg-red-50 border border-red-200 rounded shadow-sm"
                  >
                    <n-icon class="text-red-500 mr-1.5 animate-pulse">
                      <svg viewBox="0 0 24 24">
                        <path fill="currentColor"
                          d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/>
                      </svg>
                    </n-icon>
                    <span class="text-red-700 text-xs font-black">
                      提醒：仅支持对【用户输入】进行检查
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </n-form>
      <template #action>
        <n-space justify="end" size="large" style="padding-top: 16px;">
          <n-button @click="handleCancel" size="large" class="cancel-button">放弃配置</n-button>
          <n-button
            type="primary"
            @click="handleSave"
            :loading="saving"
            size="large"
            class="save-button"
          >
            {{ editingRule ? '同步更新' : '立即发布' }}
          </n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed, h, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {
  NCard, NButton, NDataTable, NModal, NForm, NFormItem, NInput, NInputNumber,
  NSelect, NSwitch, NDynamicTags, NSpace, NIcon, NTag, useMessage, useDialog, NTooltip
} from 'naive-ui'
import { agentApi, complianceApi, intentApi, variableApi } from '@/api'
import type { Agent, ComplianceRule } from '@/types'

const route = useRoute()
const router = useRouter()
const message = useMessage()
const dialog = useDialog()

const currentAgent = ref<Agent>()
const rules = ref<ComplianceRule[]>([])
const loading = ref(false)
const saving = ref(false)
const showCreateModal = ref(false)
const editingRule = ref<ComplianceRule>()

const form = ref<any>({
  name: '',
  description: '',
  scope: 'ALL',
  priority: 1,
  enabled: true,
  blockedResponse: '',
  conditionExpr: '',
  guidelinePrompt: ''
})

const keywords = ref<string[]>([])
const categories = ref<string[]>([])
const regexList = ref<string[]>([])
const formRef = ref()
const spelInputRef = ref<any>(null)

// 变量选择器相关
const flowVariables = ref<Array<{ name: string; description: string }>>([])
const selectedVariable = ref<string | null>(null)

// 变量选项（含 content 变量）
const variableOptions = computed(() => {
  const options = [
    { label: 'content (输入输出内容)', value: 'content' }
  ]
  flowVariables.value.forEach(v => {
    options.push({
      label: `${v.name} (${v.description || '流程变量'})`,
      value: v.name
    })
  })
  return options
})

// 加载 Agent 下所有 Intent 的变量
const loadFlowVariables = async () => {
  try {
    const intentsResponse = await intentApi.listByAgent(agentId.value)
    const intents = intentsResponse.data
    const allVariables: Array<{ name: string; description: string }> = []
    const variableNames = new Set<string>()

    for (const intent of intents) {
      const varsResponse = await variableApi.listByIntent(intent.id!)
      const vars = varsResponse.data || []
      vars.forEach((v: any) => {
        if (!variableNames.has(v.name)) {
          variableNames.add(v.name)
          allVariables.push({ name: v.name, description: v.description || '' })
        }
      })
    }

    flowVariables.value = allVariables
  } catch (error) {
    console.error('加载流程变量失败:', error)
  }
}

// 处理变量选择
const handleVariableSelect = (value: string | null) => {
  if (!value) return

  const inputComponent = spelInputRef.value
  let textarea: HTMLTextAreaElement | null = null
  if (inputComponent) {
    textarea = inputComponent.$el?.querySelector('textarea') || 
               inputComponent.textareaElRef || null
  }

  const currentValue = form.value.conditionExpr || ''
  const variableName = `#${value}`

  if (textarea) {
    const start = textarea.selectionStart || 0
    const end = textarea.selectionEnd || 0

    // 1. 处理前缀空格逻辑
    let prefix = ""
    if (start > 0) {
      const textBefore = currentValue.substring(0, start)
      if (textBefore.endsWith("  ")) {
        prefix = "" // 已经有两个空格，不补
      } else if (textBefore.endsWith(" ")) {
        prefix = " " // 已经有一个空格，补一个
      } else {
        prefix = "  " // 没有空格，补两个
      }
    }

    // 2. 处理后缀空格逻辑
    let suffix = ""
    if (end < currentValue.length) {
      const textAfter = currentValue.substring(end)
      if (textAfter.startsWith("  ")) {
        suffix = "" // 已经有两个空格，不补
      } else if (textAfter.startsWith(" ")) {
        suffix = " " // 已经有一个空格，补一个
      } else {
        suffix = "  " // 没有空格，补两个
      }
    }

    const finalInsertString = prefix + variableName + suffix

    // 3. 执行插入
    form.value.conditionExpr =
      currentValue.substring(0, start) +
      finalInsertString +
      currentValue.substring(end)

    // 4. 重置光标位置
    nextTick(() => {
      // 光标定位在：原始起始位 + 前缀长度 + 变量长度
      // 这样光标会落在变量名后面，而如果在后面补了空格，光标会在空格前面，方便继续输入
      const newPos = start + prefix.length + variableName.length
      textarea!.setSelectionRange(newPos, newPos)
      textarea!.focus()
    })
  } else {
    // 兜底追加逻辑（同样适用双空格逻辑）
    const prefix = currentValue.trim().length > 0 ? "  " : ""
    form.value.conditionExpr = currentValue + prefix + variableName
  }

  selectedVariable.value = null
}

const formRules = {
  name: { required: true, message: '请输入规则名称', trigger: 'blur' },
  scope: { required: true, message: '请选择作用域', trigger: 'change' },
  blockedResponse: { required: true, message: '请输入拦截提示语', trigger: 'blur' }
}

const scopeOptions = [
  { label: '用户输入 + AI响应', value: 'ALL' },
  { label: '仅检查用户输入', value: 'INPUT' },
  { label: '仅检查AI响应', value: 'RESPONSE' }
]

// scope 显示文本映射
const scopeTextMap: Record<string, string> = {
  ALL: '用户输入和AI响应',
  INPUT: '用户输入',
  RESPONSE: 'AI响应'
}

// 当前选中的 scope 文本
const currentScopeText = computed(() => {
  return scopeTextMap[form.value.scope] || '文本内容'
})

// 四种规则的动态 tooltip 文案
const tooltipTexts = computed(() => ({
  keyword: `精确匹配${currentScopeText.value}，命中列表中任意一个敏感词即触发拦截`,
  regex: `对${currentScopeText.value}进行格式匹配，命中列表内任意一项模式即触发拦截`,
  spel: `对${currentScopeText.value}进行逻辑判定，表达式结果为 true 时触发拦截`,
  ai: `通过 AI 模型对用户输入进行深度语义分析并判定是否违规`
}))


const logicSteps = computed(() => {
  const base = ["关键词", "正则列表", "SpEL表达式"]

  // 仅当不是“仅AI响应”时才显示 AI 审核
  if (form.value.scope !== 'RESPONSE') {
    base.push("AI 审核")
  }

  return base
})


const pagination = ref({ page: 1, pageSize: 10, itemCount: 0 })
const agentId = computed(() => parseInt(route.params.id as string))

const parseSafe = (data: any) => {
  if (!data) return null
  if (typeof data !== 'string') return data
  try { return JSON.parse(data) } catch (e) { return null }
}

const rowProps = () => ({ style: 'transition: all 0.3s ease; cursor: pointer;' })

const columns = [
  {
    title: '优先级',
    key: 'priority',
    width: 80,
    align: 'center',
    render: (row: ComplianceRule) => h(NTag, { size: 'small', type: 'info', bordered: false }, () => `P${row.priority}`)
  },
  {
    title: '规则名称',
    key: 'name',
    width: 150,
    render: (row: ComplianceRule) => h('span', { class: 'font-bold text-gray-700' }, row.name)
  },
  {
  title: '校验规则',
  key: 'logic',
  width: 220,
  render: (row: ComplianceRule) => {
    const tags: any[] = []

    // 解析
    const kws = parseSafe(row.keywords)
    const params = parseSafe(row.parameters)

    const hasKeywords = Array.isArray(kws) && kws.length > 0
    const hasRegex =
      params &&
      Array.isArray(params.regex_patterns) &&
      params.regex_patterns.length > 0

    const hasSpel =
      row.conditionExpr &&
      row.conditionExpr.trim().length > 0

    const hasLlm =
      row.guidelinePrompt &&
      row.guidelinePrompt.trim().length > 0

    // ====== 关键词 ======
    if (hasKeywords) {
      tags.push(
        h(NTag, { size: 'tiny', type: 'success' }, () => '关键词')
      )
    }

    // ====== 正则 ======
    if (hasRegex) {
      tags.push(
        h(NTag, { size: 'tiny', type: 'info' }, () => '正则')
      )
    }

    // ====== SpEL ======
    if (hasSpel) {
      tags.push(
        h(NTag, { size: 'tiny', type: 'warning' }, () => 'SpEL')
      )
    }

    // ====== LLM（必须有内容 且 scope 允许） ======
    if (hasLlm && (row.scope === 'ALL' || row.scope === 'INPUT')) {
      tags.push(
        h(NTag, { size: 'tiny', type: 'error' }, () => 'AI审核')
      )
    }

    return h(
      'div',
      { class: 'flex flex-wrap gap-1' },
      tags.length > 0 ? tags : '-'
    )
  }
},
  {
    title: '作用域',
    key: 'scope',
    width: 120,
    align: 'center',
    render: (row: ComplianceRule) => {
      const scopeLabels: any = { ALL: '双向', INPUT: '用户', RESPONSE: 'AI响应' }
      const scopeColors: any = { ALL: 'info', INPUT: 'success', RESPONSE: 'warning' }
      return h(NTag, { type: scopeColors[row.scope], size: 'small', round: true }, () => scopeLabels[row.scope])
    }
  },
  {
    title: '状态',
    key: 'enabled',
    width: 100,
    align: 'center',
    render: (row: ComplianceRule) => h(NSwitch, {
      value: row.enabled === 1 || row.enabled === true,
      size: 'small',
      onUpdateValue: () => handleToggle(row)
    })
  },
  {
    title: '操作',
    key: 'actions',
    width: 220,
    align: 'center',
    render: (row: ComplianceRule) => h(NSpace, { 
      justify: 'center',
      size: 'small',
      wrap: false 
    }, {
      default: () => [
        h(NButton, {
          size: 'small',
          quaternary: true,
          type: 'primary',
          onClick: (e) => { e.stopPropagation(); handleEdit(row); }
        }, () => '编辑'),
        h(NButton, {
          size: 'small',
          quaternary: true,
          type: 'info',
          onClick: (e) => { e.stopPropagation(); handleCopy(row); }
        }, () => '复制'),
        h(NButton, {
          size: 'small',
          quaternary: true,
          type: 'error',
          onClick: (e) => { e.stopPropagation(); showDeleteConfirm(row); }
        }, () => '删除')
      ]
    })
  }
]

const loadAgent = async () => {
  try {
    const response = await agentApi.get(agentId.value)
    currentAgent.value = response.data
  } catch (error) { message.error('加载 Agent 失败') }
}

const loadRules = async () => {
  loading.value = true
  try {
    const response = await complianceApi.listByAgent(agentId.value)
    // 按优先级升序
    rules.value = response.data.sort((a: any, b: any) => a.priority - b.priority)
    pagination.value.itemCount = response.data.length
  } catch (error) { message.error('加载合规规则失败') }
  finally { loading.value = false }
}

const handlePageChange = (page: number) => {
  pagination.value.page = page
  loadRules()
}

const handleCreate = () => {
  editingRule.value = undefined
  resetForm()
  showCreateModal.value = true
}

const handleEdit = (rule: ComplianceRule) => {
  editingRule.value = rule
  form.value = {
    name: rule.name,
    description: rule.description,
    scope: rule.scope,
    priority: rule.priority,
    enabled: rule.enabled === 1 || rule.enabled === true,
    blockedResponse: rule.blockedResponse,
    conditionExpr: rule.conditionExpr,
    guidelinePrompt: rule.guidelinePrompt
  }
  keywords.value = parseSafe(rule.keywords) || []
  categories.value = parseSafe(rule.categories) || []
  const params = parseSafe(rule.parameters)
  regexList.value = params?.regex_patterns || [] 
  showCreateModal.value = true
}

const handleCopy = (rule: ComplianceRule) => {
  handleEdit(rule)
  editingRule.value = undefined
  form.value.name = `${form.value.name} - 副本`
  message.info('已载入规则副本，修改后保存即可创建')
}

const handleToggle = async (rule: ComplianceRule) => {
  try {
    const nextStatus = (rule.enabled === 1 || rule.enabled === true) ? 0 : 1
    await complianceApi.update(rule.id!, { enabled: nextStatus })
    message.success('状态更新成功')
    await loadRules()
  } catch (error) { message.error('状态更新失败') }
}

const showDeleteConfirm = (rule: ComplianceRule) => {
  dialog.warning({
    title: '确认删除',
    content: `确定要删除规则 "${rule.name}" 吗？`,
    positiveText: '确定',
    negativeText: '取消',
    onPositiveClick: () => { handleDelete(rule) }
  })
}

const handleDelete = async (rule: ComplianceRule) => {
  try {
    await complianceApi.delete(rule.id!)
    message.success('删除成功')
    await loadRules()
  } catch (error) { message.error('删除失败') }
}

const handleCancel = () => {
  showCreateModal.value = false
  editingRule.value = undefined
  resetForm()
}

const resetForm = () => {
  form.value = { name: '', description: '', scope: 'ALL', priority: 1, enabled: true, blockedResponse: '', conditionExpr: '', guidelinePrompt: '' }
  keywords.value = []
  categories.value = []
  regexList.value = []
  selectedVariable.value = null
}

const handleSave = async () => {
  try {
    await formRef.value?.validate()
    saving.value = true
    const ruleData: any = {
      ...form.value,
      agentId: agentId.value,
      enabled: form.value.enabled ? 1 : 0,
      keywords: JSON.stringify(keywords.value),
      categories: JSON.stringify(categories.value),
      parameters: JSON.stringify({ 
        regex_patterns: regexList.value 
      })
    }
    if (editingRule.value) {
      await complianceApi.update(editingRule.value.id!, ruleData)
      message.success('更新成功')
    } else {
      await complianceApi.create(ruleData)
      message.success('创建成功')
    }
    handleCancel()
    await loadRules()
  } catch (error) { message.error('保存失败') }
  finally { saving.value = false }
}

onMounted(async () => {
  await loadAgent()
  await loadRules()
  await loadFlowVariables()
})
</script>

<style scoped>
@keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
.animate-fade-in { animation: fadeIn 0.6s ease-out; }
.animate-slide-up { animation: slideUp 0.8s ease-out; }

.switch-theme-custom.n-switch--active :deep(.n-switch__rail) {
  background-image: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  background-color: transparent !important;
}

.create-button:hover { 
  transform: scale(1.05) translateY(-2px); 
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4) !important; 
}

.save-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%) !important;
  border: none !important;
  box-shadow: 0 4px 15px rgba(102, 126, 234, 0.4);
}

.table-card { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
.table-card:hover { transform: translateY(-2px); box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15) !important; }

:deep(.modal-theme-custom.n-dialog) .n-dialog__icon,
:deep(.modal-theme-custom.n-dialog) .n-base-icon,
:deep(.modal-theme-custom.n-dialog) .n-base-icon svg {
  color: #764ba2 !important;
  fill: #764ba2 !important;
}
:deep(.modal-theme-custom.n-dialog) .n-dialog__icon svg path { fill: #764ba2 !important; }
:deep(.modal-theme-custom .n-dialog__header) { font-weight: 700 !important; }

.modal-animate { animation: slideUp 0.4s ease-out; }
.cancel-button:hover { background-color: #f3f4f6; transform: translateY(-1px); }

:deep(.n-data-table-th) { 
  background: linear-gradient(to bottom, #f9fafb, #f3f4f6) !important; 
  font-weight: 700 !important; 
  border-bottom: 2px solid #e5e7eb !important; 
}
</style>

<style>
.n-tooltip.description-tooltip-custom {
  background-color: #ffffff !important;
  border: 1px solid #e2e8f0 !important;
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1) !important;
  padding: 14px !important;
  border-radius: 10px !important;
}
.n-tooltip.description-tooltip-custom .n-tooltip__arrow {
  background-color: #ffffff !important;
  border-bottom: 1px solid #e2e8f0 !important;
  border-right: 1px solid #e2e8f0 !important;
}
.description-tooltip-custom {
  color: #334155 !important;
  line-height: 1.6 !important;
  font-size: 14px !important;
  white-space: pre-wrap !important;
  word-break: break-all !important;
}
</style>