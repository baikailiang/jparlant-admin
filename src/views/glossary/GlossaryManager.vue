<template>
  <div class="glossary-manager px-6 py-8 min-h-screen bg-gradient-to-br from-gray-50 to-blue-50">
    <!-- 顶部操作栏 -->
    <div class="flex items-center justify-between mb-8 animate-fade-in">
      <div class="flex items-center space-x-4">
        <n-button @click="router.push('/agents')" quaternary circle class="hover:bg-blue-50 transition-all duration-300">
          <template #icon>
            <n-icon size="20"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M20 11H7.83l5.59-5.59L12 4l-8 8l8 8l1.41-1.41L7.83 13H20v-2z"/></svg></n-icon>
          </template>
        </n-button>
        <div class="space-y-3">
          <h1
            class="flex items-center text-3xl font-bold tracking-tight 
                  bg-gradient-to-r from-blue-600 to-purple-600 
                  bg-clip-text text-transparent"
          >
            <span>术语库管理</span>
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
                  <path fill="currentColor" d="M19 2H5a2 2 0 0 0-2 2v15a3 3 0 0 0 3 3h14a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2zm0 18H7a1 1 0 0 1-1-1a1 1 0 0 1 1-1h12zm0-4H7a2.98 2.98 0 0 0-1 .17V4h13z"/>
                  <path fill="currentColor" d="M13 12L11 7L9 12M12.5 13H8.5L7.5 15H6L10 6H11L15 15H13.5L12.5 13Z"/>
                </svg>
              </n-icon>
            </div>
          </h1>

          <div class="flex items-center">
            <p class="text-[14px] text-gray-500 font-medium flex items-center">
              <span class="mr-2 inline-flex items-center px-3 py-1 bg-white border border-blue-100 rounded-lg shadow-sm group transition-all duration-300 hover:border-blue-300">
                <n-icon size="16" class="text-blue-600 mr-2">
                  <svg viewBox="0 0 24 24">
                    <path fill="currentColor" d="M12 2a2 2 0 0 1 2 2c0 .74-.4 1.39-1 1.73V7h1a7 7 0 0 1 7 7v8H3v-8a7 7 0 0 1 7-7h1V5.73c-.6-.34-1-.99-1-1.73a2 2 0 0 1 2-2M10 10v2h4v-2h-4m-3 4v2h2v-2H7m8 0v2h2v-2h-2z"/>
                  </svg>
                </n-icon>
                <span class="text-blue-800 font-bold tracking-wide">{{ currentAgent?.name }}</span>
              </span>
              <span class="text-gray-400">的业务术语定义库</span>
            </p>
          </div>
        </div>
      </div>
      <div class="flex space-x-3">
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
          添加术语
        </n-button>
      </div>
    </div>

    <!-- 搜索和筛选 -->
    <n-card
      class="search-card mb-6 shadow-lg border-0 animate-slide-up"
      style="border-radius: 16px; backdrop-filter: blur(10px); background: rgba(255, 255, 255, 0.95);"
      :bordered="false"
    >
      <div class="flex items-center space-x-4">
        <n-input
          v-model:value="searchKeyword"
          placeholder="搜索术语名称或定义"
          class="flex-1"
          size="large"
          clearable
          style="border-radius: 10px;"
        >
          <template #prefix>
            <n-icon><svg viewBox="0 0 24 24"><path fill="currentColor" d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5C16 5.91 13.09 3 9.5 3S3 5.91 3 9.5S5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5S14 7.01 14 9.5S11.99 14 9.5 14"/></svg></n-icon>
          </template>
        </n-input>

        <n-select
          v-model:value="selectedCategory"
          placeholder="选择分类"
          :options="categoryOptions"
          clearable
          size="large"
          class="w-48"
          style="border-radius: 10px;"
        />

        <n-button
          @click="handleSearch"
          size="large"
          type="primary"
          secondary
          style="border-radius: 10px; padding: 0 24px;"
        >
          搜索
        </n-button>
      </div>
    </n-card>

    <!-- 术语列表 -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <n-card
        v-for="term in filteredTerms"
        :key="term.id"
        class="term-card hover:shadow-2xl transition-all cursor-pointer border-0 animate-slide-up"
        style="border-radius: 16px; overflow: hidden; backdrop-filter: blur(10px); background: rgba(255, 255, 255, 0.98);"
        :bordered="false"
        @click="handleViewTerm(term)"
      >
        <template #header>
          <div class="flex items-center justify-between">
            <span class="font-bold text-lg text-gray-900 group-hover:text-blue-600 transition-colors">{{ term.name }}</span>
            <n-tag
              :type="getCategoryColor(term.category)"
              round
              size="medium"
              style="font-weight: 600; padding: 4px 12px;"
            >
              {{ term.category }}
            </n-tag>
          </div>
        </template>

        <div class="space-y-3">
          <!-- 优化点：使用 n-popover 彻底解决黑底和文字显示问题 -->
          <n-popover 
            trigger="hover" 
            placement="top-start" 
            :width="400"
            style="border-radius: 12px; box-shadow: 0 12px 32px rgba(0,0,0,0.15);"
          >
            <template #trigger>
              <p class="text-sm text-gray-600 line-clamp-3 cursor-help hover:text-gray-900 transition-colors">
                {{ term.definition }}
              </p>
            </template>
            <!-- 弹窗内容 -->
            <div class="p-1 text-gray-800 leading-relaxed" style="white-space: pre-wrap; word-break: break-all; font-size: 14px;">
              {{ term.definition }}
            </div>
          </n-popover>

          <div v-if="parseSafe(term.synonyms)?.length > 0" class="space-y-1">
            <span class="text-xs text-gray-500 font-medium">同义词:</span>
            <div class="flex flex-wrap gap-1">
              <n-tag
                v-for="synonym in parseSafe(term.synonyms).slice(0, 3)"
                :key="synonym"
                size="small"
                type="info"
                round
              >
                {{ synonym }}
              </n-tag>
              <span v-if="parseSafe(term.synonyms).length > 3" class="text-xs text-gray-400">
                +{{ parseSafe(term.synonyms).length - 3 }}
              </span>
            </div>
          </div>

          <div class="flex items-center justify-between text-xs text-gray-500">
            <span class="font-medium">优先级: {{ term.priority }}</span>
            <span>{{ formatDate(term.createdAt) }}</span>
          </div>
        </div>

        <template #action>
          <n-space size="small">
            <n-button
              size="small"
              type="primary"
              secondary
              @click.stop="handleEdit(term)"
              style="border-radius: 8px; font-weight: 500;"
            >
              编辑
            </n-button>
            <n-button
              size="small"
              type="error"
              secondary
              @click.stop="handleDelete(term)"
              style="border-radius: 8px; font-weight: 500;"
            >
              删除
            </n-button>
          </n-space>
        </template>
      </n-card>
    </div>
    
    <!-- (下方的 Modal 和 Script 保持原有内容，此处省略以节省长度) -->
    <!-- ... 其余代码 ... -->
    
    <!-- 创建/编辑术语 Modal -->
    <n-modal
      v-model:show="showCreateModal"
      preset="dialog"
      :show-icon="false"
      class="glossary-modal modal-animate"
      :style="{ width: '1000px', borderRadius: '24px', padding: '0' }"
      :mask-closable="false"
    >
      <!-- 自定义 Modal 头部 -->
      <div class="px-8 py-6 border-b border-gray-100 flex items-center justify-between bg-white rounded-t-3xl">
        <div class="flex items-center space-x-3">
          <div class="w-12 h-12 rounded-2xl bg-indigo-50 flex items-center justify-center text-indigo-600">
            <n-icon size="28">
              <svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 3L1 9l4 2.18v6L12 21l7-3.82v-6l2-1.09V17h2V9L12 3m6.82 6L12 12.72L5.18 9L12 5.28L18.82 9M17 16l-5 2.72L7 16v-3.73L12 15l5-2.73V16z"/></svg>
            </n-icon>
          </div>
          <div>
            <h2 class="text-xl font-bold text-gray-900">{{ editingTerm ? '编辑术语定义' : '新建业务术语' }}</h2>
            <p class="text-sm text-gray-500 mt-0.5">配置 AI 的专业词汇理解和特定回复话术</p>
          </div>
        </div>
      </div>

      <div class="p-8 bg-gray-50/50">
        <n-form
          ref="formRef"
          :model="form"
          :rules="formRules"
          label-placement="top"
          class="space-y-6"
        >
          <div class="grid grid-cols-12 gap-8">
            <!-- 左侧：核心定义区 -->
            <div class="col-span-5 space-y-6">
              <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                <div class="flex items-center space-x-2 mb-6">
                  <div class="w-1.5 h-5 bg-indigo-500 rounded-full"></div>
                  <h3 class="font-bold text-gray-800 tracking-wide">核心配置</h3>
                </div>

                <n-form-item label="术语名称" path="name">
                  <n-input
                    v-model:value="form.name"
                    placeholder="如：极速达、信用分"
                    size="large"
                    style="border-radius: 12px;"
                  />
                </n-form-item>

                <n-form-item label="所属分类" path="category">
                  <n-input
                    v-model:value="form.category"
                    placeholder="输入分类，方便后续筛选"
                    size="large"
                    style="border-radius: 12px;"
                  />
                </n-form-item>

                <n-form-item label="术语详细定义" path="definition">
                  <n-input
                    v-model:value="form.definition"
                    type="textarea"
                    :rows="4"
                    placeholder="请详细描述该术语的业务含义，AI 将参考此定义进行回复..."
                    size="large"
                    style="border-radius: 12px;"
                  />
                </n-form-item>

                <n-form-item path="priority">
                  <template #label>
                    <div class="flex items-center space-x-1">
                      <span>优先级</span>
                      <n-tooltip trigger="hover">
                        <template #trigger>
                          <n-icon size="16" class="text-gray-400 cursor-help"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2m1 15h-2v-2h2v2zm0-4h-2V7h2v6z"/></svg></n-icon>
                        </template>
                        数值越小，当匹配到多个术语时，AI 会优先采用此定义。
                      </n-tooltip>
                    </div>
                  </template>
                  <n-input-number
                    v-model:value="form.priority"
                    :min="1"
                    :max="99"
                    size="large"
                    class="w-full"
                    style="border-radius: 12px;"
                  />
                  <template #feedback>
                    <span class="text-xs text-gray-400">推荐范围：1 - 10（1为最高级）</span>
                  </template>
                </n-form-item>
              </div>
            </div>

            <!-- 右侧：扩展与示例区 -->
            <div class="col-span-7 space-y-6">
              <!-- 关联配置 -->
              <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                <div class="flex items-center space-x-2 mb-6">
                  <div class="w-1.5 h-5 bg-purple-500 rounded-full"></div>
                  <h3 class="font-bold text-gray-800 tracking-wide">关联扩展</h3>
                </div>

                <div class="grid grid-cols-2 gap-4">
                  <n-form-item label="同义词/简称">
                    <n-dynamic-tags
                      v-model:value="synonyms"
                      size="large"
                      placeholder="+ 添加"
                    />
                  </n-form-item>

                  <n-form-item label="相关联术语">
                    <n-select
                      v-model:value="relatedNames"
                      multiple
                      filterable
                      tag
                      size="large"
                      :options="termOptions"
                      placeholder="选择或输入"
                      style="border-radius: 12px;"
                    />
                  </n-form-item>
                </div>
              </div>

              <!-- 使用示例 -->
              <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                <div class="flex items-center justify-between mb-6">
                  <div class="flex items-center space-x-2">
                    <div class="w-1.5 h-5 bg-amber-500 rounded-full"></div>
                    <h3 class="font-bold text-gray-800 tracking-wide">场景示例</h3>
                  </div>
                  <n-button size="small" type="primary" secondary round @click="addExample">
                    <template #icon>
                      <n-icon><svg viewBox="0 0 24 24"><path fill="currentColor" d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg></n-icon>
                    </template>
                    添加示例
                  </n-button>
                </div>

                <div class="space-y-4 max-h-[420px] overflow-y-auto pr-2 custom-scrollbar">
                  <div v-if="examples.length === 0" class="text-center py-8 border-2 border-dashed border-gray-100 rounded-2xl">
                    <p class="text-gray-400 text-sm">暂无示例。添加示例可让 AI 的回复风格更专业。</p>
                  </div>
                  
                  <div
                    v-for="(example, index) in examples"
                    :key="index"
                    class="example-card group relative bg-gray-50/50 hover:bg-indigo-50/30 p-5 rounded-xl border border-gray-100 hover:border-indigo-100 transition-all mb-4"
                  >
                    <div class="absolute top-3 right-3 opacity-0 group-hover:opacity-100 transition-opacity">
                      <n-button quaternary circle type="error" size="small" @click="removeExample(index)">
                        <template #icon><n-icon><svg viewBox="0 0 24 24"><path fill="currentColor" d="M19 6.41L17.59 5L12 10.59L6.41 5L5 6.41L10.59 12L5 17.59L6.41 19L12 13.41L17.59 19L19 17.59L13.41 12L19 6.41z"/></svg></n-icon></template>
                      </n-button>
                    </div>

                    <div class="space-y-4">
                      <div>
                        <div class="text-[12px] font-bold text-gray-400 mb-2 uppercase tracking-wider flex items-center">
                          <span class="w-1.5 h-1.5 bg-gray-300 rounded-full mr-2"></span>触发场景
                        </div>
                        <n-input v-model:value="example.key" type="textarea" :autosize="{ minRows: 1, maxRows: 5 }" placeholder="详细描述用户在什么情况下会触及该术语（如：客户反复询问极速达的时效覆盖范围）" />
                      </div>
                      <div>
                        <div class="text-[12px] font-bold text-indigo-400 mb-2 uppercase tracking-wider flex items-center">
                          <span class="w-1.5 h-1.5 bg-indigo-400 rounded-full mr-2"></span>标准话术回复 (AI 将学习此表达方式)
                        </div>
                        <n-input v-model:value="example.value" type="textarea" :autosize="{ minRows: 3, maxRows: 10 }" placeholder="请输入该场景下的标准专业回复。建议包含术语的核心价值点..." />
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </n-form>
      </div>

      <template #action>
        <div class="px-8 py-6 bg-white border-t border-gray-100 rounded-b-3xl flex justify-end items-center space-x-4">
          <n-button @click="handleCancel" size="large" ghost style="border-radius: 14px;" class="px-8">取消</n-button>
          <n-button type="primary" @click="handleSave" :loading="saving" size="large" class="px-10 font-bold shadow-lg shadow-indigo-200" style="border-radius: 14px; background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%); border: none;">
            {{ editingTerm ? '保存修改' : '立即发布' }}
          </n-button>
        </div>
      </template>
    </n-modal>


    <!-- 术语详情 Modal -->
    <n-modal
      v-model:show="showDetailModal"
      preset="card"
      class="w-[800px] glossary-detail-modal"
      style="border-radius: 24px; overflow: hidden;"
      :bordered="false"
      :show-icon="false"
    >
      <template #header>
        <div class="flex items-center space-x-3">
          <div class="w-1.5 h-6 bg-blue-600 rounded-full"></div>
          <span class="text-xl font-bold text-gray-900">术语资产详情</span>
        </div>
      </template>

      <div v-if="viewingTerm" class="space-y-8 p-2">
        <!-- 头部概览 -->
        <div class="flex items-start justify-between bg-blue-50/50 p-6 rounded-3xl border border-blue-100/50">
          <div>
            <h1 class="text-3xl font-black text-gray-900 mb-2 tracking-tight">{{ viewingTerm.name }}</h1>
            <div class="flex items-center space-x-2">
              <n-tag :type="getCategoryColor(viewingTerm.category)" size="small" round>{{ viewingTerm.category }}</n-tag>
              <n-tag size="small" round ghost>优先级 {{ viewingTerm.priority }}</n-tag>
            </div>
          </div>
          <div class="text-right text-xs text-gray-400">
            <div>最后更新: {{ formatDate(viewingTerm.createdAt) }}</div>
          </div>
        </div>

        <!-- 详细定义 -->
        <div class="space-y-3">
          <h3 class="text-sm font-bold text-gray-400 uppercase tracking-widest px-1">业务核心定义</h3>
          <div class="text-base text-gray-700 leading-relaxed bg-white p-6 rounded-2xl border border-gray-100 shadow-sm">
            {{ viewingTerm.definition }}
          </div>
        </div>

        <!-- 标签信息 -->
        <div class="grid grid-cols-2 gap-6">
          <div v-if="parseSafe(viewingTerm.synonyms)?.length" class="space-y-3">
            <h3 class="text-sm font-bold text-gray-400 uppercase tracking-widest px-1">同义表达</h3>
            <div class="flex flex-wrap gap-2">
              <n-tag v-for="tag in parseSafe(viewingTerm.synonyms)" :key="tag" type="info" size="small" ghost round>
                {{ tag }}
              </n-tag>
            </div>
          </div>
          <div v-if="parseSafe(viewingTerm.relatedNames)?.length" class="space-y-3">
            <h3 class="text-sm font-bold text-gray-400 uppercase tracking-widest px-1">关联知识点</h3>
            <div class="flex flex-wrap gap-2">
              <n-tag v-for="tag in parseSafe(viewingTerm.relatedNames)" :key="tag" type="warning" size="small" ghost round>
                {{ tag }}
              </n-tag>
            </div>
          </div>
        </div>

        <!-- 场景话术 -->
        <div v-if="parseSafe(viewingTerm.examples) && Object.keys(parseSafe(viewingTerm.examples)).length" class="space-y-4">
          <h3 class="text-sm font-bold text-gray-400 uppercase tracking-widest px-1">场景化带教示例</h3>
          <div class="space-y-4">
            <div 
              v-for="[key, value] in Object.entries(parseSafe(viewingTerm.examples))" 
              :key="key"
              class="group bg-gray-50 hover:bg-white transition-all p-5 rounded-2xl border border-gray-100 hover:shadow-md"
            >
              <div class="flex items-center text-blue-600 font-bold text-sm mb-3">
                <div class="w-2 h-2 rounded-full bg-blue-500 mr-2"></div>
                场景：{{ key }}
              </div>
              <div class="text-gray-600 bg-white/50 p-4 rounded-xl border border-dashed border-gray-200">
                {{ value }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import {
  NCard, NButton, NInput, NSelect, NTag, NModal, NForm, NFormItem, NInputNumber,
  NDynamicTags, NSpace, NIcon, NTooltip, NPopover, useMessage, useDialog
} from 'naive-ui'
import { agentApi, glossaryApi } from '@/api'
import type { Agent, GlossaryTerm } from '@/types'

const route = useRoute()
const router = useRouter()
const message = useMessage()
const dialog = useDialog()

const currentAgent = ref<Agent>()
const terms = ref<GlossaryTerm[]>([])
const loading = ref(false)
const saving = ref(false)

const showCreateModal = ref(false)
const showDetailModal = ref(false)

const editingTerm = ref<GlossaryTerm>()
const viewingTerm = ref<GlossaryTerm>()

const searchKeyword = ref('')
const selectedCategory = ref<string>()

const form = ref<Partial<GlossaryTerm>>({
  name: '',
  definition: '',
  category: '',
  priority: 1
})

const synonyms = ref<string[]>([])
const relatedNames = ref<string[]>([])
const examples = ref<Array<{key: string, value: string}>>([])

const formRef = ref()

const formRules = {
  name: { required: true, message: '请输入术语名称', trigger: 'blur' },
  definition: { required: true, message: '请输入术语定义', trigger: 'blur' },
  category: { required: true, message: '请输入分类', trigger: 'blur' },
  priority: { required: true, type: 'number', message: '请输入优先级', trigger: 'blur' }
}

const agentId = computed(() => parseInt(route.params.id as string))

const categoryOptions = computed(() => {
  const categories = [...new Set(terms.value.map(term => term.category))]
  return categories.map(cat => ({ label: cat, value: cat }))
})

const termOptions = computed(() => {
  return terms.value.map(term => ({ label: term.name, value: term.name }))
})

const filteredTerms = computed(() => {
  let filtered = terms.value
  if (searchKeyword.value) {
    const keyword = searchKeyword.value.toLowerCase()
    filtered = filtered.filter(term => 
      term.name.toLowerCase().includes(keyword) ||
      term.definition.toLowerCase().includes(keyword)
    )
  }
  if (selectedCategory.value) {
    filtered = filtered.filter(term => term.category === selectedCategory.value)
  }
  return filtered
})

const parseSafe = (data: any) => {
  if (!data) return null
  if (typeof data !== 'string') return data
  try { return JSON.parse(data) } catch (e) { return null }
}

const getCategoryColor = (category: string) => {
  const colors = ['primary', 'info', 'success', 'warning', 'error']
  const hash = category.split('').reduce((a, b) => a + b.charCodeAt(0), 0)
  return colors[hash % colors.length] as any
}

const formatDate = (dateStr?: string): string => {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleDateString()
}

const loadAgent = async () => {
  try {
    const response = await agentApi.get(agentId.value)
    currentAgent.value = response.data
  } catch (error) { message.error('加载 Agent 失败') }
}

const loadTerms = async () => {
  loading.value = true
  try {
    const response = await glossaryApi.listByAgent(agentId.value)
    terms.value = response.data
  } catch (error) { message.error('加载术语库失败') }
  finally { loading.value = false }
}

const handleSearch = () => {}

const addExample = () => {
  examples.value.push({ key: '', value: '' })
}

const removeExample = (index: number) => {
  examples.value.splice(index, 1)
}

const handleCreate = () => {
  editingTerm.value = undefined
  resetForm()
  showCreateModal.value = true
}

const handleViewTerm = (term: GlossaryTerm) => {
  viewingTerm.value = term
  showDetailModal.value = true
}

const handleEdit = (term: GlossaryTerm) => {
  editingTerm.value = term
  form.value = {
    name: term.name,
    definition: term.definition,
    category: term.category,
    priority: term.priority || 1
  }
  synonyms.value = parseSafe(term.synonyms) || []
  relatedNames.value = parseSafe(term.relatedNames) || []
  const targetExamples = parseSafe(term.examples)
  examples.value = targetExamples 
    ? Object.entries(targetExamples).map(([key, value]) => ({ key, value: String(value) }))
    : []
  showCreateModal.value = true
}

const handleSave = async () => {
  try {
    await formRef.value?.validate()
    saving.value = true
    const examplesObject = Object.fromEntries(
      examples.value.filter(ex => ex.key && ex.value).map(ex => [ex.key, ex.value])
    )
    const termData: any = {
      name: form.value.name,
      definition: form.value.definition,
      category: form.value.category,
      priority: form.value.priority,
      agentId: agentId.value,
      synonyms: JSON.stringify(synonyms.value || []),
      relatedNames: JSON.stringify(relatedNames.value || []),
      examples: JSON.stringify(examplesObject || {})
    }
    if (editingTerm.value) {
      await glossaryApi.update(editingTerm.value.id!, termData)
      message.success('更新成功')
    } else {
      await glossaryApi.create(termData)
      message.success('创建成功')
    }
    handleCancel()
    await loadTerms()
  } catch (error: any) {
    message.error('保存失败')
  } finally {
    saving.value = false
  }
}

const handleDelete = async (term: GlossaryTerm) => {
  dialog.warning({
    title: '确认删除',
    content: `确定要删除术语 "${term.name}" 吗？`,
    positiveText: '确定',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await glossaryApi.delete(term.id!)
        message.success('删除成功')
        await loadTerms()
      } catch (error) { message.error('删除失败') }
    }
  })
}

const handleCancel = () => {
  showCreateModal.value = false
  resetForm()
}

const resetForm = () => {
  form.value = { name: '', definition: '', category: '', priority: 1 }
  synonyms.value = []
  relatedNames.value = []
  examples.value = []
}

onMounted(async () => {
  await loadAgent()
  await loadTerms()
})
</script>

<style scoped>
@keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
.animate-fade-in { animation: fadeIn 0.6s ease-out; }
.animate-slide-up { animation: slideUp 0.8s ease-out; }
.term-card { transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1); }
.term-card:hover { transform: translateY(-4px) scale(1.01); }
.search-card { transition: all 0.4s cubic-bezier(0.4, 0, 0.2, 1); }
.search-card:hover { transform: translateY(-2px); box-shadow: 0 20px 40px rgba(0, 0, 0, 0.12) !important; }
.line-clamp-3 { display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }
.create-button:hover { transform: scale(1.05) translateY(-2px); box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4) !important; }

/* Modal 样式 */
.glossary-modal :deep(.n-dialog__close) { top: 24px; right: 24px; }
.custom-scrollbar::-webkit-scrollbar { width: 6px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: #e5e7eb; border-radius: 10px; }
.example-card { box-shadow: 0 2px 12px rgba(0,0,0,0.04); }
:deep(.n-dynamic-tags .n-tag) { border-radius: 8px; background-color: #f3f4f6; border: none; font-weight: 500; color: #4b5563; }
:deep(.n-input) { transition: all 0.2s; }
:deep(.n-input:not(.n-input--disabled).n-input--focus) { background-color: #fff !important; box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.1); }

/* 详情弹窗专用样式 */
:deep(.glossary-detail-modal .n-card-header) {
  padding: 24px 32px 16px !important;
}
:deep(.glossary-detail-modal .n-card__content) {
  padding: 0 32px 32px !important;
}
.glossary-detail-modal {
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.2) !important;
}
</style>