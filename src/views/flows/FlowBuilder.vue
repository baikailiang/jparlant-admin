<template>
  <div class="flow-builder h-screen flex flex-col bg-gradient-to-br from-slate-50 to-gray-100 dark:from-[#0f172a] dark:to-[#1e293b] transition-colors duration-500">
    <!-- 顶部工具栏 -->
    <div class="bg-white/80 dark:bg-slate-900/80 backdrop-blur-xl border-b border-gray-200/50 dark:border-gray-800/50 px-8 py-4 sticky top-0 z-50 transition-all">
      <div class="flex items-center justify-between w-full">
        <!-- 左侧区域：包含返回按钮和标题组 -->
        <div class="flex items-center space-x-6">
          <!-- 1. 返回按钮 -->
          <n-button 
            @click="handleBack" 
            quaternary 
            circle 
            size="large" 
            class="bg-white dark:bg-slate-800 shadow-sm hover:shadow-md transition-all border border-gray-100 dark:border-slate-700"
          >
            <template #icon>
              <n-icon size="22" class="text-gray-600 dark:text-slate-300">
                <svg viewBox="0 0 24 24"><path fill="currentColor" d="M20 11H7.83l5.59-5.59L12 4l-8 8l8 8l1.41-1.41L7.83 13H20v-2z"/></svg>
              </n-icon>
            </template>
          </n-button>

          <!-- 2. 标题与状态垂直列 (明确 items-start 确保左对齐) -->
          <div class="flex flex-col items-start space-y-3">
            <!-- 主标题：渐变文字 + 动态方块 -->
            <h1 class="flex items-center text-3xl font-black tracking-tight bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">
              <span>流程编排</span>
              <div class="ml-4 flex items-center justify-center w-10 h-10 rounded-2xl bg-gradient-to-tr from-blue-600 to-indigo-600 shadow-lg shadow-blue-300/40 text-white transition-all duration-300 hover:scale-110 hover:rotate-3">
                <n-icon size="24">
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M13 11H9V8H5v8h4v-3h4v3h4V8h-4v3zm6-7H5c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2z"/></svg>
                </n-icon>
              </div>
            </h1>

            <!-- 身份信息：胶囊设计 + 呼吸灯 -->
            <div class="flex items-center text-sm space-x-4">
              <div class="flex items-center bg-white dark:bg-slate-800 px-3 py-1.5 rounded-full shadow-sm border border-gray-100 dark:border-slate-700 transition-all hover:border-blue-200">
                <span class="relative flex h-2 w-2 mr-2">
                  <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                  <span class="relative inline-flex rounded-full h-2 w-2 bg-green-500"></span>
                </span>
                <span class="text-gray-400 dark:text-slate-500 mr-1.5 font-medium">当前代理:</span>
                <span class="font-bold text-gray-800 dark:text-slate-200">{{ currentAgent?.name }}</span>
              </div>

              <!-- 分隔点 -->
              <div class="w-1 h-1 rounded-full bg-gray-300 dark:bg-slate-600"></div>

              <!-- 意图信息 -->
              <div class="flex items-center font-medium">
                <span class="text-gray-400 dark:text-slate-500 mr-2">正在配置意图:</span>
                <span class="text-blue-600 dark:text-blue-400 font-black tracking-wide border-b-2 border-blue-500/20">
                  {{ currentIntent?.name || '未选择意图' }}
                </span>
              </div>
            </div>
          </div>
        </div>

        <!-- 右侧区域：保存按钮 -->
        <div class="flex items-center">
          <n-button
            type="primary"
            @click="handleSave"
            :loading="saving"
            class="shadow-xl shadow-blue-500/20 hover:shadow-blue-500/40 transition-all duration-300"
            style="height: 48px; border-radius: 12px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none; font-weight: 700; padding: 0 32px;"
          >
            <template #icon>
              <n-icon size="20"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M17 3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V7zm-5 16c-1.66 0-3-1.34-3-3s1.34-3 3-3s3 1.34 3 3s-1.34 3-3 3m3-10H5V5h10z"/></svg></n-icon>
            </template>
            保存流程配置
          </n-button>
        </div>
      </div>
    </div>

    <!-- 主编辑区域 -->
    <div class="flex-1 flex overflow-hidden">
      <!-- 左侧组件面板 -->
      <div class="w-72 bg-gradient-to-b from-white to-gray-50/80 border-r border-gray-200/80 flex flex-col shadow-xl">

        <!-- 🚀 变量管理区域 -->
        <div class="p-5 flex flex-col border-b border-gray-200/60" style="max-height: 50%;">
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center gap-2">
              <div class="w-1 h-5 bg-gradient-to-b from-blue-500 to-blue-600 rounded-full"></div>
              <h3 class="text-sm font-bold text-gray-800 tracking-wide">变量定义</h3>
              <span class="inline-flex items-center justify-center w-6 h-6 text-xs font-bold text-blue-600 bg-blue-100 rounded-full">{{ flatDisplayVariables.length }}</span>
            </div>
            <n-button
              size="tiny"
              type="primary"
              secondary
              circle
              @click="handleAddVariable"
              :disabled="!selectedIntentId"
              class="hover:scale-110 transition-transform duration-300 shadow-md hover:shadow-lg"
            >
              <template #icon>
                <n-icon><svg viewBox="0 0 24 24"><path fill="currentColor" d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg></n-icon>
              </template>
            </n-button>
          </div>

          <!-- 搜索框 -->
          <div class="mb-3">
            <n-input
              v-model:value="variableSearchQuery"
              size="small"
              placeholder="搜索变量..."
              class="search-input-enhanced"
              style="--n-border-radius: 10px; --n-border-hover: 1px solid rgb(59, 130, 246); --n-border-focus: 1px solid rgb(59, 130, 246);"
            >
              <template #prefix>
                <n-icon class="text-gray-400">
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>
                </n-icon>
              </template>
            </n-input>
          </div>

          <div class="flex-1 overflow-y-auto pr-1 custom-scrollbar">
            <div v-if="!selectedIntentId" class="text-xs text-gray-400 text-center py-8 italic">
              <div class="text-2xl mb-2">📋</div>
              <div>请选择一个意图</div>
            </div>
            <div v-else-if="variables.length === 0" class="text-xs text-gray-400 text-center py-8 italic">
              <div class="text-2xl mb-2">📝</div>
              <div>暂无变量</div>
            </div>
            <div v-else-if="filteredTreeVariables.length === 0" class="text-xs text-gray-400 text-center py-8 italic">
              <div class="text-2xl mb-2">🔍</div>
              <div>未匹配到变量</div>
            </div>
            <div v-else class="variable-list-custom">
              <div
                v-for="item in displayVariableList"
                :key="item.variable.id"
                class="variable-list-item"
                :style="{ paddingLeft: (item.depth * 14) + 'px' }"
              >
                <!-- 第一行：名称 + 类型标签 -->
                <div class="flex items-center gap-1.5 min-w-0">
                  <span
                    v-if="item.variable.children && item.variable.children.length > 0"
                    class="var-expand-toggle flex-shrink-0 cursor-pointer text-gray-400 hover:text-blue-500 dark:text-slate-500 dark:hover:text-blue-400"
                    :class="{ 'var-expand-open': !collapsedVariableIds.has(item.variable.id) }"
                    @click="toggleVariableExpand(item.variable.id)"
                  >
                    <svg width="12" height="12" viewBox="0 0 24 24"><path fill="currentColor" d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6z"/></svg>
                  </span>
                  <span v-else-if="item.depth > 0" class="text-gray-300 dark:text-slate-600 flex-shrink-0 text-[10px] leading-none select-none">└</span>
                  <span class="text-xs font-semibold text-gray-700 dark:text-slate-200 truncate min-w-0">{{ item.variable.name }}</span>
                  <n-tag
                    size="tiny"
                    :bordered="true"
                    :color="typeTagColorMap[item.variable.type] || { color: '#f3f4f6', textColor: '#4b5563', borderColor: '#e5e7eb' }"
                    class="flex-shrink-0"
                    style="font-size: 9px;"
                  >
                    {{ item.variable.type }}
                  </n-tag>
                </div>
                <!-- 第二行：描述 + 操作按钮 -->
                <div class="flex items-center mt-0.5">
                  <span
                    v-if="item.variable.description"
                    class="text-[10px] text-gray-400 dark:text-slate-500 truncate flex-1 mr-1"
                    :title="item.variable.description"
                  >{{ item.variable.description }}</span>
                  <span v-else class="flex-1"></span>
                  <div class="flex items-center flex-shrink-0">
                    <n-tooltip v-if="item.variable.type === 'OBJECT' || item.variable.type === 'ARRAY'" trigger="hover">
                      <template #trigger>
                        <n-button
                          size="tiny"
                          quaternary
                          circle
                          :disabled="item.variable.type === 'ARRAY' && item.variable.children && item.variable.children.length > 0"
                          @click="handleAddChildVariable(item.variable)"
                        >
                          <template #icon>
                            <n-icon :size="13"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg></n-icon>
                          </template>
                        </n-button>
                      </template>
                      {{ item.variable.type === 'ARRAY' ? '添加数组元素模板' : '添加子属性' }}
                    </n-tooltip>
                    <n-button size="tiny" quaternary circle @click="handleEditVariable(item.variable)">
                      <template #icon>
                        <n-icon :size="13"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a.996.996 0 0 0 0-1.41l-2.34-2.34a.996.996 0 0 0-1.41 0l-1.83 1.83l3.75 3.75l1.83-1.83z"/></svg></n-icon>
                      </template>
                    </n-button>
                    <n-button size="tiny" quaternary circle type="error" @click="handleDeleteVariable(Number(item.variable.id))">
                      <template #icon>
                        <n-icon :size="13"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg></n-icon>
                      </template>
                    </n-button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 步骤类型区域 -->
        <div class="p-5 flex-1 overflow-y-auto custom-scrollbar">
          <div class="flex items-center gap-2 mb-4">
            <div class="w-1 h-5 bg-gradient-to-b from-green-500 to-emerald-600 rounded-full"></div>
            <h3 class="text-sm font-bold text-gray-800 tracking-wide">步骤类型</h3>
          </div>
          <div class="grid grid-cols-1 gap-3">
            <div
              v-for="nodeType in nodeTypes"
              :key="nodeType.type"
              :draggable="true"
              @dragstart="handleDragStart($event, nodeType)"
              class="p-4 bg-white border-2 border-gray-200 rounded-xl cursor-move hover:shadow-2xl hover:border-blue-400 transition-all duration-300 group transform hover:-translate-y-1 hover:scale-105"
              style="background: linear-gradient(135deg, #ffffff 0%, #f8fafc 100%);"
            >
              <div class="flex items-center space-x-3">
                <div
                  :class="[nodeType.iconClass, 'text-2xl group-hover:scale-125 transition-transform duration-300 filter drop-shadow-md']"
                  style="transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);"
                >{{ nodeType.icon }}</div>
                <div class="flex-1">
                  <div class="text-sm font-bold text-gray-900 group-hover:text-blue-600 transition-colors">{{ nodeType.label }}</div>
                  <div class="text-[11px] text-gray-500 mt-1 leading-tight">{{ nodeType.description }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Vue Flow 画布 -->
      <div class="flex-1 relative bg-gradient-to-br from-gray-50 via-blue-50/20 to-indigo-50/30">
        <VueFlow
          v-model:nodes="nodes"
          v-model:edges="edges"
          :default-viewport="{ zoom: 1 }"
          :min-zoom="0.2"
          :max-zoom="4"
          :delete-key-code="[]"
          :connection-mode="ConnectionMode.Loose"
          @connect="onConnect"
          @edges-delete="onEdgesDelete"
          @nodes-delete="onNodesDelete"
          @dragover="handleDragOver"
          @drop="handleDrop"
          @node-double-click="handleNodeDoubleClick"
          class="h-full"
        >
          <Background pattern-color="#cbd5e1" :gap="20" />
          <Controls />
          <MiniMap />
          
          <template #node-step="nodeProps">
            <StepNode
              v-bind="nodeProps"
              @edit="handleEditStep"
              @delete="handleDeleteStep"
            />
          </template>

          <template #edge-smoothstep="edgeProps">
            <BranchEdge v-bind="edgeProps" />
          </template>
        </VueFlow>
      </div>
    </div>

    <!-- 步骤编辑 Modal -->
    <StepEditModal
      v-model:show="showStepModal"
      :step="editingStep"
      :intent-id="selectedIntentId"
      :all-steps="steps"
      @save="handleStepSave"
      @variable-added="loadVariables"
    />

    <!-- 变量编辑 Modal -->
    <n-modal
      v-model:show="showVariableModal"
      preset="dialog"
      :title="modalTitle"
      :style="{ width: '500px' }"
    >
      <n-form
        ref="variableFormRef"
        :model="variableForm"
        :rules="variableRules"
        label-width="80px"
        label-placement="left"
      >
        <!-- 父级变量提示 -->
        <n-form-item v-if="parentVariable" label="父级变量">
          <n-input :value="`${parentVariable.name} (${parentVariable.type})`" disabled />
        </n-form-item>

        <n-form-item label="变量名称" path="name">
          <n-input
            v-model:value="variableForm.name"
            placeholder="请输入变量名称（如：userName）"
            :disabled="isArrayChild && !editingVariable"
          />
        </n-form-item>

        <n-form-item label="变量类型" path="type">
          <n-select v-model:value="variableForm.type" :options="variableTypeOptions" />
        </n-form-item>

        <n-form-item label="变量描述" path="description">
          <n-input
            v-model:value="variableForm.description"
            type="textarea"
            :rows="4"
            :placeholder="variableForm.type === 'OBJECT' ? '请描述该对象的用途和结构（如：用户基本信息，包含姓名、手机号等字段）' : variableForm.type === 'ARRAY' ? '请描述数组的用途及每个元素的结构（如：订单列表，每个元素包含订单号和商品信息）' : '请详细描述变量的用途和含义'"
          />
        </n-form-item>
      </n-form>

      <template #action>
        <n-space>
          <n-button @click="showVariableModal = false">取消</n-button>
          <n-button type="primary" @click="handleVariableSave">
            {{ editingVariable ? '更新' : '创建' }}
          </n-button>
        </n-space>
      </template>
    </n-modal>

    <!-- 流转规则配置 Modal -->
    <n-modal
      v-model:show="showBranchConfigModal"
      preset="dialog"
      title="流转规则配置"
      :style="{ width: '600px', borderRadius: '16px' }"
      :mask-closable="false"
    >
      <n-form
        ref="branchConfigFormRef"
        :model="branchConfigForm"
        label-width="100px"
        label-placement="left"
        class="mt-4"
      >
        <n-alert type="info" size="small" class="mb-4">
          设置步骤流转的触发规则。如果一个步骤有多个流转路径，建议设置一个“默认流转”作为兜底。
        </n-alert>

        <n-form-item label="流转名称">
          <n-input
            v-model:value="branchConfigForm.label"
            :placeholder="branchConfigForm.isDefault ? '其他 (默认路径)' : '例如：审核通过 (可选)'"
            size="large"
            style="border-radius: 10px;"
          />
        </n-form-item>

        <n-form-item label="默认流转">
          <div class="flex items-center space-x-4">
            <n-switch v-model:value="branchConfigForm.isDefault" @update:value="handleDefaultSwitchChange" />
            <span class="text-xs text-gray-500">
              开启后，当其他路径条件都不满足时，将走此路径（兜底逻辑）。
            </span>
          </div>
        </n-form-item>

        <!-- 如果不是默认流转，则显示条件配置 -->
        <div v-if="!branchConfigForm.isDefault">
          <n-divider style="margin: 16px 0">触发条件</n-divider>

          <n-form-item label-placement="top">
            <div class="w-full space-y-3">
              <div
                v-for="(condition, index) in branchConfigForm.conditions"
                :key="index"
                class="border border-gray-200 dark:border-gray-700 rounded-lg p-4 bg-gray-50/50 dark:bg-slate-800/50 space-y-3"
              >
                <div class="flex items-center justify-between mb-2">
                  <n-tag :bordered="false" type="primary" size="small">规则 {{ index + 1 }}</n-tag>
                  <n-button size="tiny" quaternary type="error" @click="handleRemoveCondition(index)">
                    <template #icon><n-icon><svg viewBox="0 0 24 24"><path fill="currentColor" d="M19 6.41L17.59 5L12 10.59L6.41 5L5 6.41L10.59 12L5 17.59L6.41 19L12 13.41L17.59 19L19 17.59L13.41 12z"/></svg></n-icon></template>
                    移除
                  </n-button>
                </div>

                <n-select v-model:value="condition.conditionType" :options="conditionTypeOptions" placeholder="选择判断逻辑" size="small" />

                <template v-if="condition.conditionType === 'normal'">
                  <div class="grid grid-cols-2 gap-2">
                    <!-- 变量选择框 -->
                    <n-tree-select
                      v-model:value="condition.key"
                      :options="conditionVariableOptions"
                      :render-label="renderConditionVariableLabel"
                      placeholder="选择变量"
                      size="small"
                      filterable
                      clearable
                      default-expand-all
                    />
                    
                    <!-- 匹配值：根据变量类型切换显示 -->
                    <!-- 如果是布尔类型，显示下拉框 -->
                    <n-select
                      v-if="getVariableType(condition.key) === 'BOOLEAN'"
                      v-model:value="condition.normalValue"
                      :options="booleanOptions"
                      placeholder="选择布尔值"
                      size="small"
                    />
                    <!-- 否则显示普通的输入框 -->
                    <n-input 
                      v-else
                      v-model:value="condition.normalValue" 
                      placeholder="匹配值" 
                      size="small" 
                    />
                  </div>
                </template>

                <template v-if="condition.conditionType === 'operator'">
                  <div class="flex flex-col gap-2">
                    <n-tree-select
                      v-model:value="condition.key"
                      :options="conditionVariableOptions"
                      :render-label="renderConditionVariableLabel"
                      placeholder="选择变量"
                      size="small"
                      filterable
                      clearable
                      default-expand-all
                    />
                    <div class="flex gap-2">
                      <n-select v-model:value="condition.operatorType" :options="operatorOptions" placeholder="操作符" size="small" style="width: 140px;" />
                      <n-input-number v-model:value="condition.operatorValue" placeholder="数值" size="small" class="flex-1" />
                    </div>
                  </div>
                </template>

                <template v-if="condition.conditionType === 'collection'">
                  <n-tree-select
                    v-model:value="condition.key"
                    :options="conditionVariableOptions"
                    :render-label="renderConditionVariableLabel"
                    placeholder="选择变量"
                    size="small"
                    filterable
                    clearable
                    default-expand-all
                  />
                  <n-dynamic-tags v-model:value="condition.collectionValues" size="small" placeholder="输入值后回车" />
                </template>

                <template v-if="condition.conditionType === 'spel'">
                  <n-input v-model:value="condition.spelExpression" type="textarea" :rows="2" placeholder="#score >= 60" size="small" />
                </template>
              </div>

              <n-button dashed block @click="handleAddCondition" size="medium" type="primary">
                <template #icon><n-icon><svg viewBox="0 0 24 24"><path fill="currentColor" d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/></svg></n-icon></template>
                添加触发规则
              </n-button>
            </div>
          </n-form-item>
        </div>
      </n-form>

      <template #action>
        <n-space justify="end" size="large">
          <n-button @click="handleBranchConfigCancel" size="large" style="border-radius: 10px; padding: 0 24px;">
            取消
          </n-button>
          <n-button
            type="primary"
            @click="handleBranchConfigSave"
            size="large"
            style="border-radius: 10px; padding: 0 32px; background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); border: none;"
          >
            确认应用
          </n-button>
        </n-space>
      </template>
    </n-modal>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, onUnmounted, h } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { VueFlow, useVueFlow, ConnectionMode } from '@vue-flow/core'
import { Background } from '@vue-flow/background'
import { Controls } from '@vue-flow/controls'
import { MiniMap } from '@vue-flow/minimap'
import { NSelect, NButton, NIcon, NModal, NForm, NFormItem, NInput, NInputNumber, NDynamicTags, NSpace, NTag, NTooltip, NRadio, NRadioGroup, NCollapse, NCollapseItem, NAlert, NDivider, NTreeSelect, useMessage, useDialog } from 'naive-ui'
import { agentApi, intentApi, stepApi, variableApi } from '@/api'
import StepNode from '@/components/flow/StepNode.vue'
import StepEditModal from '@/components/flow/StepEditModal.vue'
import BranchEdge from '@/components/flow/BranchEdge.vue'
import type { Agent, AgentIntent, IntentStep, FlowNode, FlowEdge, FlowVariable, VariableType, IntentStepTransition, BatchSaveIntentFlowDTO } from '@/types'
import { useThemeStore } from '@/stores/theme'

const route = useRoute()
const router = useRouter()
const message = useMessage()
const dialog = useDialog()
const { project, addEdges } = useVueFlow()
const themeStore = useThemeStore()

// 状态管理
const currentAgent = ref<Agent>()
const intents = ref<AgentIntent[]>([])
const selectedIntentId = ref<number>()
const currentIntent = computed(() => 
  intents.value.find(intent => intent.id === selectedIntentId.value)
)

const nodes = ref<FlowNode[]>([])
const edges = ref<FlowEdge[]>([])
const steps = ref<IntentStep[]>([])
const showStepModal = ref(false)
const editingStep = ref<IntentStep>()
const saving = ref(false)

// 变量管理相关状态
const variables = ref<FlowVariable[]>([])
const variableSearchQuery = ref('')
const showVariableModal = ref(false)
const editingVariable = ref<FlowVariable>()
const parentVariable = ref<FlowVariable | null>(null)
const variableFormRef = ref()
const variableForm = ref<Partial<FlowVariable>>({
  name: '',
  description: '',
  type: 'STRING',
  parentId: null
})

// 将树形变量扁平化用于展示
interface FlatDisplayVariable {
  variable: FlowVariable
  depth: number
  parentType?: VariableType
}

const flattenForDisplay = (vars: FlowVariable[], depth = 0, parentType?: VariableType): FlatDisplayVariable[] => {
  const result: FlatDisplayVariable[] = []
  for (const v of vars) {
    result.push({ variable: v, depth, parentType })
    if (v.children && v.children.length > 0) {
      result.push(...flattenForDisplay(v.children, depth + 1, v.type))
    }
  }
  return result
}

const flatDisplayVariables = computed(() => flattenForDisplay(variables.value))

// 计算过滤后的变量
const filteredVariables = computed(() => {
  if (!variableSearchQuery.value) return flatDisplayVariables.value
  const query = variableSearchQuery.value.toLowerCase()
  return flatDisplayVariables.value.filter(fv =>
    fv.variable.name.toLowerCase().includes(query) ||
    (fv.variable.description && fv.variable.description.toLowerCase().includes(query))
  )
})

// 将树形变量完全扁平化用于下拉选项
const flattenAllVariables = (vars: FlowVariable[]): FlowVariable[] => {
  const result: FlowVariable[] = []
  for (const v of vars) {
    result.push(v)
    if (v.children && v.children.length > 0) {
      result.push(...flattenAllVariables(v.children))
    }
  }
  return result
}

// 生成变量下拉选项
const variableOptions = computed(() => {
  const flatVars = flattenAllVariables(variables.value)
  const uniqueOptionsMap = new Map()

  flatVars.forEach(v => {
    // 如果变量名重复，只保留第一个遇到的（防止虚拟滚动因 value 重复而崩溃）
    if (v.name && !uniqueOptionsMap.has(v.name)) {
      uniqueOptionsMap.set(v.name, {
        label: `${v.name} (${v.description || '无描述'})`,
        value: v.name,
        // 关键点：明确提供 key 属性，通常使用数据库 id 确保唯一性
        key: v.id || v.name 
      })
    }
  })

  return Array.from(uniqueOptionsMap.values())
})


// 递归构建变量树选项（用于触发条件中的变量选择）
const conditionVariableOptions = computed(() => {
  const buildTree = (vars: FlowVariable[], parentPath: string): any[] => {
    return vars.map(v => {
      const currentPath = parentPath ? `${parentPath}.${v.name}` : `$.${v.name}`
      const node: any = {
        label: v.name,
        key: currentPath,
        type: v.type,
        description: v.description,
      }
      if (v.children && v.children.length > 0) {
        node.children = buildTree(v.children, currentPath)
      }
      return node
    })
  }
  return buildTree(variables.value, '')
})

// 树选择器的标签渲染函数
const renderConditionVariableLabel = ({ option }: { option: any }) => {
  const tipParts: string[] = []
  if (option.type) tipParts.push(`类型: ${option.type}`)
  if (option.description) tipParts.push(option.description)
  if (tipParts.length > 0) {
    return h(NTooltip, { placement: 'right', delay: 300 }, {
      trigger: () => h('span', { style: 'display: inline-block; width: 100%;' }, option.label),
      default: () => tipParts.join(' | ')
    })
  }
  return h('span', option.label)
}

// 查找变量类型的辅助函数
const getVariableType = (key: string) => {
  const allVars = flattenAllVariables(variables.value)
  const varName = key && key.startsWith('$.') ? key.split('.').pop() : key
  const variable = allVars.find(v => v.name === varName)
  return variable ? variable.type : 'STRING'
}

// 定义布尔值下拉选项
const booleanOptions = [
  { label: 'true', value: 'true' },
  { label: 'false', value: 'false' }
]

const variableRules = {
  name: [
    { required: true, message: '请输入变量名称', trigger: 'blur' },
    { 
      pattern: /^[a-zA-Z_][a-zA-Z0-9_]*$/, 
      message: '变量名仅支持字母、数字和下划线，且不能以数字开头', 
      trigger: ['blur', 'input'] 
    }
  ],
  description: { required: true, message: '请输入变量描述', trigger: 'blur' },
  type: { required: true, message: '请选择变量类型', trigger: 'change' }
}

const variableTypeOptions = [
  { label: '字符串 (STRING)', value: 'STRING' },
  { label: '数字 (NUMBER)', value: 'NUMBER' },
  { label: '布尔值 (BOOLEAN)', value: 'BOOLEAN' },
  { label: '对象 (OBJECT)', value: 'OBJECT' },
  { label: '数组 (ARRAY)', value: 'ARRAY' }
]

// 变量类型颜色映射
const typeTagColorMap: Record<string, { color: string; textColor: string; borderColor: string }> = {
  STRING: { color: '#dcfce7', textColor: '#15803d', borderColor: '#bbf7d0' },
  NUMBER: { color: '#dbeafe', textColor: '#1d4ed8', borderColor: '#bfdbfe' },
  BOOLEAN: { color: '#ffedd5', textColor: '#c2410c', borderColor: '#fed7aa' },
  OBJECT: { color: '#f3e8ff', textColor: '#7e22ce', borderColor: '#e9d5ff' },
  ARRAY: { color: '#fce7f3', textColor: '#be185d', borderColor: '#fbcfe8' }
}

// 树形表格列定义
const variableColumns: any[] = [
  {
    title: '变量名称',
    key: 'name',
    minWidth: 100,
    ellipsis: { tooltip: true }
  },
  {
    title: '类型',
    key: 'type',
    width: 80,
    render(row: FlowVariable) {
      const colorInfo = typeTagColorMap[row.type] || { color: '#f3f4f6', textColor: '#4b5563', borderColor: '#e5e7eb' }
      return h(NTag, { size: 'small', bordered: true, color: colorInfo, style: { fontSize: '10px' } }, { default: () => row.type })
    }
  },
  {
    title: '描述',
    key: 'description',
    minWidth: 80,
    ellipsis: { tooltip: true }
  },
  {
    title: '操作',
    key: 'actions',
    width: 100,
    render(row: FlowVariable) {
      const buttons: any[] = []

      if (row.type === 'OBJECT' || row.type === 'ARRAY') {
        const isArrayFull = row.type === 'ARRAY' && row.children && row.children.length > 0
        buttons.push(
          h(NTooltip, { trigger: 'hover' }, {
            trigger: () => h(NButton, {
              size: 'tiny',
              quaternary: true,
              circle: true,
              disabled: isArrayFull,
              onClick: () => handleAddChildVariable(row)
            }, {
              icon: () => h(NIcon, { size: 14 }, {
                default: () => h('svg', { viewBox: '0 0 24 24' }, [
                  h('path', { fill: 'currentColor', d: 'M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z' })
                ])
              })
            }),
            default: () => row.type === 'ARRAY' ? '添加数组元素模板' : '添加子属性'
          })
        )
      }

      buttons.push(
        h(NButton, {
          size: 'tiny',
          quaternary: true,
          circle: true,
          onClick: () => handleEditVariable(row)
        }, {
          icon: () => h(NIcon, { size: 14 }, {
            default: () => h('svg', { viewBox: '0 0 24 24' }, [
              h('path', { fill: 'currentColor', d: 'M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a.996.996 0 0 0 0-1.41l-2.34-2.34a.996.996 0 0 0-1.41 0l-1.83 1.83l3.75 3.75l1.83-1.83z' })
            ])
          })
        })
      )

      buttons.push(
        h(NButton, {
          size: 'tiny',
          quaternary: true,
          circle: true,
          type: 'error',
          onClick: () => handleDeleteVariable(Number(row.id))
        }, {
          icon: () => h(NIcon, { size: 14 }, {
            default: () => h('svg', { viewBox: '0 0 24 24' }, [
              h('path', { fill: 'currentColor', d: 'M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z' })
            ])
          })
        })
      )

      return h('div', { style: 'display: flex; gap: 2px;' }, buttons)
    }
  }
]

// 用于树形表格的过滤数据
const filteredTreeVariables = computed(() => {
  if (!variableSearchQuery.value) return variables.value
  const query = variableSearchQuery.value.toLowerCase()

  const filterTree = (nodes: FlowVariable[]): FlowVariable[] => {
    return nodes.reduce<FlowVariable[]>((acc, node) => {
      const nameMatch = node.name.toLowerCase().includes(query)
      const descMatch = node.description?.toLowerCase().includes(query) || false
      const filteredChildren = node.children ? filterTree(node.children) : []

      if (nameMatch || descMatch || filteredChildren.length > 0) {
        acc.push({
          ...node,
          children: filteredChildren.length > 0 ? filteredChildren : (nameMatch || descMatch ? node.children : undefined)
        } as FlowVariable)
      }
      return acc
    }, [])
  }

  return filterTree(variables.value)
})

// 变量展开/折叠状态（存储已折叠的变量ID，默认全部展开）
const collapsedVariableIds = ref(new Set<number | string>())

const toggleVariableExpand = (variableId: number | string) => {
  const newSet = new Set(collapsedVariableIds.value)
  if (newSet.has(variableId)) {
    newSet.delete(variableId)
  } else {
    newSet.add(variableId)
  }
  collapsedVariableIds.value = newSet
}

// 带折叠感知的扁平化函数
const flattenForDisplayFiltered = (vars: FlowVariable[], collapsed: Set<number | string>, depth = 0, parentType?: VariableType): FlatDisplayVariable[] => {
  const result: FlatDisplayVariable[] = []
  for (const v of vars) {
    result.push({ variable: v, depth, parentType })
    if (v.children && v.children.length > 0 && !collapsed.has(v.id)) {
      result.push(...flattenForDisplayFiltered(v.children, collapsed, depth + 1, v.type))
    }
  }
  return result
}

// 将过滤后的树形变量扁平化用于自定义列表展示
const displayVariableList = computed(() => flattenForDisplayFiltered(filteredTreeVariables.value, collapsedVariableIds.value))

// 添加子项时的可选类型
const isArrayChild = computed(() => parentVariable.value?.type === 'ARRAY')

const modalTitle = computed(() => {
  if (editingVariable.value) return '编辑变量'
  if (parentVariable.value) {
    return parentVariable.value.type === 'ARRAY' ? '添加数组元素模板' : '添加子属性'
  }
  return '新建变量'
})

const nodeTypes = [
  { type: 'INPUT', label: '交互节点', description: '收集用户输入', icon: '📝', iconClass: 'text-blue-500' },
  { type: 'ACTION', label: '逻辑节点', description: '执行业务逻辑', icon: '⚙️', iconClass: 'text-green-500' },
  { type: 'TRANSITION', label: '过渡节点', description: 'AI 回复过渡', icon: '🔄', iconClass: 'text-orange-500' },
  { type: 'COMPLETED', label: '结束节点', description: '流程结束', icon: '✅', iconClass: 'text-gray-500' }
]

// 用于记录最后一次拖拽落点坐标的临时状态
const lastDroppedPosition = ref<{ x: number, y: number } | null>(null)

// 分支连线配置相关状态
const showBranchConfigModal = ref(false)
const pendingConnection = ref<any>(null)

interface ConditionItem {
  key: string
  conditionType: 'normal' | 'operator' | 'collection' | 'spel'
  normalValue?: any
  operatorType?: '$gt' | '$gte' | '$lt' | '$lte' | '$eq' | '$neq'
  operatorValue?: number
  collectionValues?: string[]
  spelExpression?: string
}

const branchConfigForm = ref({
  label: '',
  isDefault: false, // 新增：是否是默认路径
  conditions: [] as ConditionItem[]
})

const handleDefaultSwitchChange = (val: boolean) => {
  if (val) {
    // 如果设为默认，清空已有的条件，且 label 若为空则设为“其他”
    branchConfigForm.value.conditions = []
    if (!branchConfigForm.value.label) branchConfigForm.value.label = '其他'
  }
}

const branchConfigFormRef = ref()

// 条件类型选项
const conditionTypeOptions = [
  { label: '普通值条件', value: 'normal' },
  { label: '操作符条件', value: 'operator' },
  { label: '集合条件', value: 'collection' }
]

// 操作符选项
const operatorOptions = [
  { label: '大于 (>)', value: '$gt' },
  { label: '大于等于 (>=)', value: '$gte' },
  { label: '小于 (<)', value: '$lt' },
  { label: '小于等于 (<=)', value: '$lte' },
  { label: '等于 (==)', value: '$eq' },
  { label: '不等于 (!=)', value: '$neq' }
]

// 加载 Agent 基础信息
const loadAgent = async () => {
  try {
    const agentId = parseInt(route.params.id as string)
    const response = await agentApi.get(agentId)
    currentAgent.value = response.data
  } catch (error) { message.error('加载 Agent 失败') }
}

// 加载意图列表
const loadIntents = async () => {
  try {
    const response = await intentApi.listByAgent(parseInt(route.params.id as string))
    intents.value = response.data
    if (intents.value.length > 0 && !selectedIntentId.value) {
      const intentIdFromQuery = route.query.intentId ? parseInt(route.query.intentId as string) : null
      const targetIntentId = intentIdFromQuery || intents.value[0].id
      await handleIntentChange(targetIntentId)
    }
  } catch (error) { message.error('加载意图列表失败') }
}

const loadSteps = async (intentId: number) => {
  try {
    const response = await stepApi.listByIntent(intentId)
    steps.value = response.data
    buildFlowGraph()
  } catch (error) { message.error('加载步骤失败') }
}

// 加载变量使用 intentId
const loadVariables = async () => {
  if (!selectedIntentId.value) return
  try {
    const response = await variableApi.listByIntent(selectedIntentId.value)
    variables.value = response.data
  } catch (error) {
    message.error('加载变量失败')
  }
}

// 还原画布布局
const buildFlowGraph = () => {
  const flowNodes: FlowNode[] = []
  const flowEdges: FlowEdge[] = []
  let savedLayout: any = {}

  try {
    if (currentIntent.value?.metadataJson) {
      savedLayout = JSON.parse(currentIntent.value.metadataJson)
    }
  } catch (e) {
    console.warn('解析布局失败:', e)
  }

  steps.value.forEach((step, index) => {
    const stepIdStr = step.id?.toString();
    const savedPosition = stepIdStr ? savedLayout.nodePositions?.[stepIdStr] : undefined;
    flowNodes.push({
      id: stepIdStr || `step-${index}`,
      type: 'step',
      position: savedPosition || { x: 100 + (index % 3) * 250, y: 100 + Math.floor(index / 3) * 200 },
      data: { step, label: step.name }
    })
  })

  const validNodeIds = new Set(flowNodes.map(node => node.id))

  // 从 savedLayout 恢复保存的连线（包括普通连线和分支连线）
  if (savedLayout.edges && savedLayout.edges.length > 0) {
    savedLayout.edges.forEach((savedEdge: any) => {
      const sourceId = savedEdge.source.toString()
      const targetId = savedEdge.target.toString()

      if (validNodeIds.has(sourceId) && validNodeIds.has(targetId)) {
        flowEdges.push({
          id: savedEdge.id || `edge-${sourceId}-${targetId}`,
          source: sourceId,
          target: targetId,
          animated: true,
          label: savedEdge.label,
          data: savedEdge.data,
          type: savedEdge.type,
          style: savedEdge.type === 'smoothstep'
            ? { stroke: '#10b981', strokeWidth: 2 }
            : { stroke: '#3b82f6', strokeWidth: 2 }
        })
      }
    })
  }

  nodes.value = flowNodes
  edges.value = flowEdges
}

const onConnect = (params: any) => {
  if (params.source === params.target) return

  // 暂存流转参数
  pendingConnection.value = params
  // 重置表单，不再有 connectionType
  branchConfigForm.value = {
    label: '',
    conditions: []
  }
  showBranchConfigModal.value = true
}

// 添加条件
const handleAddCondition = () => {
  branchConfigForm.value.conditions.push({
    key: '',
    conditionType: 'normal',
    normalValue: '',
    collectionValues: []
  })
}

// 删除条件
const handleRemoveCondition = (index: number) => {
  branchConfigForm.value.conditions.splice(index, 1)
}

// 将条件列表转换为JSON对象
const buildConditionJson = (conditions: ConditionItem[]): Record<string, any> => {
  const result: Record<string, any> = {}

  conditions.forEach(condition => {
    if (!condition.key?.trim()) return

    // 从树选择器的路径值中提取变量名（去掉 $. 前缀）
    const key = condition.key.startsWith('$.') ? condition.key.substring(2) : condition.key

    switch (condition.conditionType) {
      case 'normal':
        // 普通值：尝试解析为boolean、number或保持string
        if (condition.normalValue === 'true') {
          result[key] = true
        } else if (condition.normalValue === 'false') {
          result[key] = false
        } else if (!isNaN(Number(condition.normalValue)) && condition.normalValue !== '') {
          result[key] = Number(condition.normalValue)
        } else {
          result[key] = condition.normalValue
        }
        break

      case 'operator':
        // 操作符：{"age": {"$gte": 18}}
        if (condition.operatorType && condition.operatorValue !== undefined) {
          result[key] = {
            [condition.operatorType]: condition.operatorValue
          }
        }
        break

      case 'collection':
        // 集合：{"status": ["ACTIVE", "PENDING"]}
        if (condition.collectionValues && condition.collectionValues.length > 0) {
          result[key] = condition.collectionValues
        }
        break

      case 'spel':
        // SpEL表达式：{"$expr": "#score >= 60"}
        if (condition.spelExpression?.trim()) {
          result['$expr'] = condition.spelExpression
        }
        break
    }
  })

  return result
}

// 处理连线配置保存
const handleBranchConfigSave = async () => {
  if (!pendingConnection.value) return

  try {
    const params = pendingConnection.value
    const form = branchConfigForm.value
    
    // 判定是否为默认路径
    const isActuallyDefault = form.isDefault || form.conditions.length === 0
    const conditionJson = !isActuallyDefault ? buildConditionJson(form.conditions) : null
    
    const edgeId = `edge-${params.source}-${params.target}-${Date.now()}`
    
    const newEdge: FlowEdge = {
      id: edgeId,
      source: params.source,
      target: params.target,
      animated: true, 
      // 这里的 label 会传递给 BranchEdge
      label: form.label || '',
      data: {
        condition: conditionJson ? JSON.stringify(conditionJson) : null,
        transitionLabel: form.label,
        isDefault: isActuallyDefault ? 1 : 0
      },
      // 统一使用 smoothstep，这样 BranchEdge.vue 才能接管渲染
      type: 'smoothstep', 
      style: { 
        stroke: isActuallyDefault ? '#3b82f6' : '#10b981', 
        strokeWidth: 2.5,
        strokeDasharray: '8', 
      }
    }

    addEdges([newEdge])
    message.success(isActuallyDefault ? '已配置默认流转路径' : '条件流转配置成功')

    showBranchConfigModal.value = false
    pendingConnection.value = null
  } catch (error) {
    message.error('应用配置失败')
  }
}



// 取消连线配置
const handleBranchConfigCancel = () => {
  showBranchConfigModal.value = false
  pendingConnection.value = null
  branchConfigForm.value = {
    connectionType: 'normal',
    label: '',
    conditions: []
  }
}

// 连线删除处理函数
const onEdgesDelete = async (deletedEdges: any[]) => {
  console.log('连线已移除:', deletedEdges)
  // 连线删除后，需要在保存时同步到后端
  message.info('连线已删除，请点击"保存流程配置"以同步到服务器')
}

// 节点删除处理函数：强化异步删除逻辑
const onNodesDelete = async (deletedNodes: any[]) => {
  if (deletedNodes.length === 0) return;
  
  try {
    // 遍历所有删除的节点，调用后端接口
    const deletePromises = deletedNodes
      .filter(node => node.data?.step?.id) // 过滤出有 ID 的持久化步骤
      .map(node => stepApi.delete(node.data.step.id));
    
    if (deletePromises.length > 0) {
      await Promise.all(deletePromises);
      message.success(`已从服务器删除 ${deletePromises.length} 个步骤`);
      
      // 重新从后端拉取最新状态
      if (selectedIntentId.value) {
        await loadSteps(selectedIntentId.value);
      }
    }
  } catch (error) {
    console.error('同步删除失败:', error);
    message.error('部分步骤删除失败，请刷新页面检查');
  }
}

const handleBack = () => router.push(`/agents/${route.params.id}/intents`)

const handleIntentChange = async (intentId: number | undefined) => {
  if (!intentId) return
  selectedIntentId.value = intentId
  await loadSteps(intentId)
  await loadVariables()
}

const handleDragStart = (event: DragEvent, nodeType: any) => {
  if (event.dataTransfer) {
    event.dataTransfer.setData('application/vueflow', JSON.stringify(nodeType))
  }
}

const handleDragOver = (event: DragEvent) => {
  event.preventDefault()
}

const handleDrop = async (event: DragEvent) => {
  if (!selectedIntentId.value) return message.warning('请先选择意图')

  // 1. 修正坐标计算逻辑：通过 project 函数并将坐标相对于画布容器进行计算
  // 获取画布容器的位置
  const vueFlowContainer = (event.target as HTMLElement).closest('.vue-flow')
  if (vueFlowContainer) {
    const { left, top } = vueFlowContainer.getBoundingClientRect()
    // 核心修正：clientX/Y 需要减去容器的 left/top，再交给 project 转换
    lastDroppedPosition.value = project({
      x: event.clientX - left,
      y: event.clientY - top,
    })
  } else {
    // 回退方案
    lastDroppedPosition.value = project({
      x: event.clientX,
      y: event.clientY,
    })
  }

  // 从 dataTransfer 中获取节点类型
  const nodeTypeData = event.dataTransfer?.getData('application/vueflow')
  let stepType: string | undefined = undefined

  if (nodeTypeData) {
    try {
      const nodeType = JSON.parse(nodeTypeData)
      stepType = nodeType.type
    } catch (e) {
      console.error('解析节点类型失败:', e)
    }
  }

  editingStep.value = {
    intentId: selectedIntentId.value,
    name: '',
    stepType: stepType,
    enabled: true,
    description: '',
    prompt: '',
    canSkip: false
  } as unknown as IntentStep
  showStepModal.value = true
}

const handleNodeDoubleClick = (event: any) => {
  const step = event.node.data.step
  handleEditStep(step)
}

const handleEditStep = (step: IntentStep) => {
  editingStep.value = { ...step }
  showStepModal.value = true
}

const handleDeleteStep = async (step: IntentStep) => {
  try {
    if (step.id) {
      await stepApi.delete(step.id)
      message.success('删除成功')
      await loadSteps(selectedIntentId.value!)
    }
  } catch (error) { message.error('删除失败') }
}

const handleStepSave = async (step: IntentStep) => {
  try {
    const isNewStep = !step.id
    // 1. 执行步骤本身的保存或更新
    const response = step.id ? await stepApi.update(step.id, step) : await stepApi.create(step)
    const savedStep = response.data
    
    // --- 核心修复：无论新建还是更新，都同步一次画布快照 ---
    
    // 2. 获取当前的元数据
    let currentMetadata: any = { nodePositions: {}, edges: [] }
    try {
      if (currentIntent.value?.metadataJson) {
        currentMetadata = JSON.parse(currentIntent.value.metadataJson)
      }
    } catch (e) {
      currentMetadata = { nodePositions: {}, edges: [] }
    }

    if (!currentMetadata.nodePositions) currentMetadata.nodePositions = {}

    // 3. 【核心】抓取画布上所有节点当前的最新位置（防止拖动后位置跳回）
    nodes.value.forEach(node => {
      currentMetadata.nodePositions[node.id] = node.position
    })

    // 4. 如果是新建节点且有落点记录，覆盖它的位置
    if (isNewStep && lastDroppedPosition.value && savedStep.id) {
      currentMetadata.nodePositions[savedStep.id.toString()] = lastDroppedPosition.value
      lastDroppedPosition.value = null
    }

    // 5. 【核心】抓取画布上当前的连线状态（防止分支连线丢失）
    // 这样能确保你刚刚配置好的分支连线被保存进 metadata
    currentMetadata.edges = edges.value.map(edge => ({
      id: edge.id,
      source: edge.source,
      target: edge.target,
      label: edge.label,
      data: edge.data,
      type: edge.type
    }))

    // 6. 统一更新意图的元数据
    await intentApi.update(selectedIntentId.value!, {
      metadataJson: JSON.stringify(currentMetadata)
    })

    // --- 修复结束 ---

    message.success('保存成功')
    showStepModal.value = false
    
    // 7. 重新加载，此时 buildFlowGraph 会拿到最新的 metadataJson
    await loadIntents() // 刷新本地 currentIntent
    await loadSteps(selectedIntentId.value!)
    
  } catch (error) { 
    console.error('保存失败:', error)
    message.error('保存失败') 
  }
}

// 变量管理函数
const handleAddVariable = () => {
  if (!selectedIntentId.value) return message.warning('请选择意图')
  parentVariable.value = null
  editingVariable.value = undefined
  variableForm.value = {
    name: '',
    description: '',
    type: 'STRING',
    parentId: null
  }
  showVariableModal.value = true
}

const handleAddChildVariable = (parent: FlowVariable) => {
  parentVariable.value = parent
  editingVariable.value = undefined
  variableForm.value = {
    name: parent.type === 'ARRAY' ? 'Item' : '',
    description: '',
    type: 'STRING',
    parentId: Number(parent.id)
  }
  showVariableModal.value = true
}

const handleEditVariable = (variable: FlowVariable) => {
  editingVariable.value = variable
  parentVariable.value = null
  variableForm.value = { ...variable }
  showVariableModal.value = true
}

const handleDeleteVariable = async (variableId: number) => {
  dialog.warning({
    title: '确认删除',
    content: '删除此变量将同时删除其所有子变量，确定要继续吗？',
    positiveText: '确定删除',
    negativeText: '取消',
    onPositiveClick: async () => {
      try {
        await variableApi.delete(variableId)
        await loadVariables()
        message.success('删除成功')
      } catch (error) {
        message.error('删除失败')
      }
    }
  })
}

const handleVariableSave = async () => {
  try {
    await variableFormRef.value?.validate()

    if (!selectedIntentId.value) {
      message.error('未选中有效意图')
      return
    }

    const intentId = selectedIntentId.value
    const payload = { ...variableForm.value, intentId }

    if (editingVariable.value) {
      await variableApi.update(Number(editingVariable.value.id), payload as FlowVariable)
      message.success('变量更新成功')
    } else {
      await variableApi.create(payload as FlowVariable)
      message.success('变量创建成功')
    }

    await loadVariables()
    showVariableModal.value = false
    editingVariable.value = undefined
    parentVariable.value = null
    variableForm.value = { name: '', description: '', type: 'STRING', parentId: null }
  } catch (error: any) {
    console.error('变量操作失败', error)
    message.error(error?.message || '变量保存失败，请检查输入')
  }
}

const handleSave = async () => {
  if (!selectedIntentId.value) return
  saving.value = true

  try {
    const transitions: IntentStepTransition[] = []
    const edgesBySource = new Map<string, FlowEdge[]>()
    
    edges.value.forEach(edge => {
      const sourceId = edge.source
      if (!edgesBySource.has(sourceId)) edgesBySource.set(sourceId, [])
      edgesBySource.get(sourceId)!.push(edge)
    })

    edgesBySource.forEach((sourceEdges, sourceId) => {
      // 关键：将默认路径排在最后执行 (isDefault=1 的往后排)
      const sortedEdges = [...sourceEdges].sort((a, b) => {
        const aDef = a.data?.isDefault || 0
        const bDef = b.data?.isDefault || 0
        return aDef - bDef 
      })

      sortedEdges.forEach((edge, index) => {
        const fromStepId = parseInt(edge.source)
        const toStepId = parseInt(edge.target)
        const isDefaultPath = edge.data?.isDefault === 1

        transitions.push({
          intentId: selectedIntentId.value!,
          fromStepId,
          toStepId,
          branchCode: edge.data?.transitionLabel || (isDefaultPath ? 'DEFAULT' : `BRANCH_${index}`),
          priority: index + 1, // 排序后的序号即为优先级
          conditionJson: edge.data?.condition || null,
          isDefault: isDefaultPath ? 1 : 0
        })
      })
    })

    const batchSaveData: BatchSaveIntentFlowDTO = {
      intentId: selectedIntentId.value,
      transitions
    }
    await stepApi.batchSaveFlow(batchSaveData)

    // 保存布局
    const layoutData = {
      nodePositions: nodes.value.reduce((acc, node) => ({ ...acc, [node.id]: node.position }), {}),
      edges: edges.value.map(edge => ({
        id: edge.id, source: edge.source, target: edge.target,
        label: edge.label, data: edge.data, type: edge.type
      }))
    }
    await intentApi.update(selectedIntentId.value, { metadataJson: JSON.stringify(layoutData) })
    message.success('流程配置已保存')
  } catch (error) {
    message.error('保存失败')
  } finally {
    saving.value = false
  }
}

onMounted(async () => {
  await loadAgent()
  await loadIntents()
})

const handleKeyDown = async (e: KeyboardEvent) => {
  if (e.key !== 'Delete') return

  const selectedNodes = nodes.value.filter(n => n.selected)
  const selectedEdges = edges.value.filter(e => e.selected)

  if (selectedNodes.length === 0 && selectedEdges.length === 0) return

  e.preventDefault()

  // 删除选中的连线
  if (selectedEdges.length > 0) {
    edges.value = edges.value.filter(e => !e.selected)
  }

  // 删除选中的节点
  if (selectedNodes.length > 0) {
    for (const node of selectedNodes) {
      const stepId = node.data?.step?.id
      if (stepId) {
        await stepApi.delete(stepId)
      }
    }

    nodes.value = nodes.value.filter(n => !n.selected)
    // 级联删除与该节点相关的连线
    edges.value = edges.value.filter(
      e => !selectedNodes.some(n => n.id === e.source || n.id === e.target)
    )
  }

  message.success(selectedNodes.length > 0 ? '步骤已删除' : '连接已删除')
}

onMounted(() => window.addEventListener('keydown', handleKeyDown))
onUnmounted(() => window.removeEventListener('keydown', handleKeyDown))
</script>

<style>
@import '@vue-flow/core/dist/style.css';
@import '@vue-flow/core/dist/theme-default.css';
@import '@vue-flow/controls/dist/style.css';
@import '@vue-flow/minimap/dist/style.css';

/* 自定义滚动条 */
.custom-scrollbar::-webkit-scrollbar {
  width: 6px;
}
.custom-scrollbar::-webkit-scrollbar-thumb {
  background: linear-gradient(180deg, #cbd5e1 0%, #94a3b8 100%);
  border-radius: 10px;
  transition: background 0.3s;
}
.custom-scrollbar::-webkit-scrollbar-thumb:hover {
  background: linear-gradient(180deg, #94a3b8 0%, #64748b 100%);
}
.custom-scrollbar::-webkit-scrollbar-track {
  background: transparent;
  margin: 4px 0;
}

/* 搜索框增强样式 */
.search-input-enhanced {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}
.search-input-enhanced:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.15);
}

/* 变量卡片动画 */
.variable-list-custom {
  display: flex;
  flex-direction: column;
}

.variable-list-item {
  padding: 6px 4px;
  border-radius: 6px;
  border-bottom: 1px solid #f1f5f9;
  transition: background 0.2s ease;
}

.variable-list-item:last-child {
  border-bottom: none;
}

.variable-list-item:hover {
  background: #f0f9ff;
}

.var-expand-toggle {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  transition: transform 0.2s ease;
}

.var-expand-toggle.var-expand-open {
  transform: rotate(90deg);
}

.variable-item {
  position: relative;
  overflow: hidden;
}
.variable-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(59, 130, 246, 0.1), transparent);
  transition: left 0.5s;
}
.variable-item:hover::before {
  left: 100%;
}

/* Vue Flow 节点选中效果 */
.vue-flow__node.selected {
  outline: none;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.4), 0 10px 30px rgba(59, 130, 246, 0.3);
}

/* 连接线动画 - 绘制时 */
.vue-flow__connection-path {
  stroke: #3b82f6;
  stroke-width: 3;
  stroke-dasharray: 8;
  animation: dashdraw 0.8s linear infinite;
  filter: drop-shadow(0 2px 4px rgba(59, 130, 246, 0.3));
}

@keyframes dashdraw {
  from { stroke-dashoffset: 16; }
  to { stroke-dashoffset: 0; }
}

/* 已连接的边线样式 */
.vue-flow__edge-path {
  stroke: #94a3b8;
  stroke-width: 2.5;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  filter: drop-shadow(0 1px 2px rgba(0, 0, 0, 0.1));
}

.vue-flow__edge:hover .vue-flow__edge-path {
  stroke: #64748b;
  stroke-width: 3;
  filter: drop-shadow(0 2px 6px rgba(0, 0, 0, 0.2));
}

.vue-flow__edge.selected .vue-flow__edge-path {
  stroke: #3b82f6 !important;
  stroke-width: 3.5;
  filter: drop-shadow(0 3px 8px rgba(59, 130, 246, 0.4));
  animation: pulse-edge 2s ease-in-out infinite;
}

@keyframes pulse-edge {
  0%, 100% {
    stroke-width: 3.5;
    opacity: 1;
  }
  50% {
    stroke-width: 4;
    opacity: 0.9;
  }
}

/* 控制器按钮样式增强 */
.vue-flow__controls {
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
  border-radius: 12px;
  overflow: hidden;
  backdrop-filter: blur(8px);
  background: rgba(255, 255, 255, 0.95);
}

.vue-flow__controls-button {
  transition: all 0.3s;
  border-bottom: 1px solid #e5e7eb;
}

.vue-flow__controls-button:hover {
  background: linear-gradient(135deg, #eff6ff 0%, #dbeafe 100%);
  transform: scale(1.05);
}

/* 小地图样式增强 */
.vue-flow__minimap {
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.15);
  border-radius: 12px;
  overflow: hidden;
  border: 2px solid rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(8px);
}

/* 背景网格增强 */
.vue-flow__background {
  opacity: 0.6;
}

/* 拖拽时的视觉反馈 */
[draggable="true"] {
  user-select: none;
  -webkit-user-drag: element;
}

[draggable="true"]:active {
  opacity: 0.7;
  transform: scale(0.98);
  cursor: grabbing !important;
}
</style>