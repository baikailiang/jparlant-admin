<template>
  <n-tooltip trigger="hover" placement="bottom" :delay="500">
    <template #trigger>
      <div
        class="step-node border-2 rounded-2xl p-4 transition-all relative backdrop-blur-sm"
        :class="[
          data.step.stepType === 'INPUT' ? 'border-blue-400 bg-gradient-to-br from-blue-50/50 to-blue-100/30' :
          data.step.stepType === 'ACTION' ? 'border-green-400 bg-gradient-to-br from-green-50/50 to-green-100/30' :
          'border-purple-400 bg-gradient-to-br from-purple-50/50 to-purple-100/30',
          { 'selected-effect': selected }
        ]"
        style="width: 220px; min-height: 170px;"
      >
        <!-- 快捷操作栏 -->
        <div class="quick-actions nodrag">
          <n-button-group size="tiny">
            <n-button type="primary" strong secondary @click.stop="emits('edit', data.step)">
              <template #icon><n-icon><svg viewBox="0 0 24 24"><path fill="currentColor" d="M3 17.25V21h3.75L17.81 9.94l-3.75-3.75L3 17.25zM20.71 7.04a.996.996 0 0 0 0-1.41l-2.34-2.34a.996.996 0 0 0-1.41 0l-1.83 1.83l3.75 3.75l1.83-1.83z"/></svg></n-icon></template>
              编辑
            </n-button>
            <n-button type="error" strong secondary @click.stop="emits('delete', data.step)">
              <template #icon><n-icon><svg viewBox="0 0 24 24"><path fill="currentColor" d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/></svg></n-icon></template>
            </n-button>
          </n-button-group>
        </div>

        <!-- 节点头部图标 -->
        <div class="flex items-center mb-4">
          <div
            class="w-11 h-11 rounded-xl flex items-center justify-center text-xl font-bold shadow-md transform transition-transform hover:scale-110"
            :class="{
              'bg-gradient-to-br from-blue-500 to-blue-600 text-white': data.step.stepType === 'INPUT',
              'bg-gradient-to-br from-green-500 to-green-600 text-white': data.step.stepType === 'ACTION',
              'bg-gradient-to-br from-purple-500 to-purple-600 text-white': data.step.stepType === 'COMPLETED'
            }"
          >
            {{ getStepIcon(data.step.stepType) }}
          </div>
          <div class="ml-3 flex-1 overflow-hidden">
            <div class="font-bold text-gray-900 truncate text-sm">{{ data.step.name }}</div>
            <div class="text-[10px] uppercase tracking-wider font-semibold"
              :class="{
                'text-blue-500': data.step.stepType === 'INPUT',
                'text-green-500': data.step.stepType === 'ACTION',
                'text-purple-500': data.step.stepType === 'COMPLETED'
              }"
            >
              {{ data.step.stepType }}
            </div>
          </div>
        </div>

        <!-- 节点内容描述 -->
        <div class="mb-3">
          <n-tooltip trigger="hover" :disabled="!data.step.description">
            <template #trigger>
              <div class="text-xs text-gray-600 line-clamp-2 leading-relaxed h-9">
                {{ data.step.description || '暂无描述' }}
              </div>
            </template>
            <div class="max-w-xs">{{ data.step.description }}</div>
          </n-tooltip>
        </div>

        <!-- 标签展示 -->
        <div class="flex flex-wrap gap-1.5">
          <n-tag size="small" :bordered="false" :type="getPhaseTagType(data.step.belongToPhase)" round>
            {{ getPhaseLabel(data.step.belongToPhase) }}
          </n-tag>
          <n-tag size="small" :bordered="false" :type="getTypeTagType(data.step.stepType)" round>
            {{ getTypeLabel(data.step.stepType) }}
          </n-tag>
          <n-tag v-if="data.step.canSkip" size="small" :bordered="false" type="warning" round>跳过</n-tag>
        </div>

        <!-- Vue Flow 连接点 -->
        <Handle type="target" :position="Position.Top" class="custom-handle nodrag" />
        <Handle type="source" :position="Position.Bottom" class="custom-handle nodrag" />
      </div>
    </template>
    <span>双击进行编辑</span>
  </n-tooltip>
</template>

<script setup lang="ts">
import { Handle, Position } from '@vue-flow/core'
import { NButton, NButtonGroup, NIcon, NTag, NTooltip } from 'naive-ui'
import type { IntentStep, StepType, SessionPhase } from '@/types'

interface Props {
  data: { step: IntentStep; label: string }
  selected?: boolean
}

const props = defineProps<Props>()
const emits = defineEmits(['edit', 'delete'])

const getStepIcon = (type: StepType) => {
  const icons = { INPUT: '📝', ACTION: '⚙️', COMPLETED: '✅' }
  return icons[type] || '❓'
}

// 优化点 2：拆分标签显示逻辑
const getPhaseLabel = (phase: SessionPhase) => {
  const labels: any = { 
    'READY': '准备', 
    'PROLOGUE': '开场', 
    'UNDERSTANDING': '理解', 
    'PROCESSING': '处理',
    'REVIEW': '审核', 
    'PENDING': '等待', 
    'CLOSING': '结束' 
  }
  return labels[phase] || phase
}

const getTypeLabel = (stepType: StepType) => {
  const typeLabels: Record<StepType, string> = {
    'INPUT': '输入',
    'ACTION': '执行',
    'COMPLETED': '完成'
  }
  return typeLabels[stepType] || stepType
}

const getPhaseTagType = (phase: SessionPhase) => {
  if (['READY', 'PROLOGUE'].includes(phase)) return 'info'
  if (['PROCESSING'].includes(phase)) return 'primary'
  if (['REVIEW', 'PENDING'].includes(phase)) return 'warning'
  return 'default'
}

// 优化点 2：类型标签颜色同步步骤边框色
const getTypeTagType = (stepType: StepType) => {
  switch (stepType) {
    case 'INPUT': return 'info'    // 对应蓝色
    case 'ACTION': return 'success' // 对应绿色
    case 'COMPLETED': return 'error' // 对应紫色/红色系
    default: return 'default'
  }
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.step-node {
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.step-node:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 20px rgba(0, 0, 0, 0.12);
}

/* 选中时的发光效果 */
.selected-effect {
  border-color: #3b82f6 !important;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.15), 0 8px 24px rgba(59, 130, 246, 0.25) !important;
  background: white !important;
  transform: translateY(-3px) scale(1.03);
}

/* 快捷操作栏仅在选中时显示 */
.quick-actions {
  position: absolute;
  top: -38px;
  right: 0;
  opacity: 0;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  transform: translateY(10px);
  pointer-events: none;
  z-index: 100;
}

.selected-effect .quick-actions {
  opacity: 1;
  transform: translateY(0);
  pointer-events: all;
}

/* 连接点样式 */
.custom-handle {
  width: 14px !important;
  height: 14px !important;
  background: linear-gradient(135deg, #3b82f6, #2563eb) !important;
  border: 3px solid white !important;
  box-shadow: 0 2px 6px rgba(59, 130, 246, 0.4);
  z-index: 100;
  opacity: 0;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.custom-handle::after {
  content: "";
  position: absolute;
  top: -12px;
  left: -12px;
  right: -12px;
  bottom: -12px;
  border-radius: 50%;
}

.step-node:hover .custom-handle,
.selected-effect .custom-handle {
  opacity: 1;
}

.custom-handle:hover {
  transform: scale(1.4);
  background: linear-gradient(135deg, #2563eb, #1d4ed8) !important;
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.6);
}
</style>