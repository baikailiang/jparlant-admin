<template>
  <g class="vue-flow__edge">
    <!-- 1. 不可见的探测线，增加点击区域宽度 -->
    <path
      :d="edgePath"
      fill="none"
      stroke="transparent"
      stroke-width="20"
      class="vue-flow__edge-interaction"
      style="cursor: pointer; pointer-events: stroke;"
    />

    <!-- 2. 原有的视觉线条 -->
    <path
      :id="id"
      :style="edgeStyle"
      class="vue-flow__edge-path"
      :d="edgePath"
      :marker-end="markerEnd"
    />

    <!-- 修改点：只要有 label 或者是 condition 就展示标签 -->
    <g v-if="label || data?.condition">
      <foreignObject
        :x="labelX - 50"
        :y="labelY - 15"
        width="100"
        height="30"
        style="pointer-events: none;" 
      >
        <div xmlns="http://www.w3.org/1999/xhtml" style="width: 100%; height: 100%; display: flex; align-items: center; justify-content: center; pointer-events: none;">
          <n-tooltip trigger="hover" placement="top" :delay="200" scrollable>
            <template #trigger>
              <div 
                class="branch-label" 
                :class="{ 'is-default': data?.isDefault }"
              >
                {{ label || (data?.isDefault ? '默认' : '流转') }}
              </div>
            </template>
            
            <div class="condition-tooltip-container">
              <div class="condition-tooltip-header">
                <span class="dot" :class="{ 'is-default-dot': data?.isDefault }"></span> 
                {{ data?.isDefault ? '默认流转路径' : '满足以下条件时流转' }}
              </div>
              <div v-if="friendlyConditions.length > 0" class="condition-rules-list">
                <div v-for="(rule, index) in friendlyConditions" :key="index" class="rule-item">
                  <span class="rule-symbol">▸</span> {{ rule }}
                </div>
              </div>
              <div v-else class="rule-item text-gray-400 italic">
                无特定触发条件，作为兜底路径执行
              </div>
            </div>
          </n-tooltip>
        </div>
      </foreignObject>
    </g>
  </g>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { getSmoothStepPath, Position } from '@vue-flow/core'
import { NTooltip } from 'naive-ui'

interface Props {
  id: string
  sourceX: number
  sourceY: number
  targetX: number
  targetY: number
  sourcePosition?: Position
  targetPosition?: Position
  data?: {
    condition?: string
    transitionLabel?: string
    isDefault?: number
  }
  markerEnd?: string
  style?: any
  label?: string
}

const props = withDefaults(defineProps<Props>(), {
  sourcePosition: Position.Right,
  targetPosition: Position.Left
})

const friendlyConditions = computed(() => {
  if (!props.data?.condition) return []
  try {
    const obj = JSON.parse(props.data.condition)
    const rules: string[] = []
    const opMap: Record<string, string> = { '$gt': '>', '$gte': '≥', '$lt': '<', '$lte': '≤', '$eq': '=', '$neq': '≠' }

    for (const [key, val] of Object.entries(obj)) {
      if (key === '$expr') { rules.push(`自定义逻辑: ${val}`); continue }
      if (Array.isArray(val)) { rules.push(`${key} 属于 [${val.join(', ')}]`) } 
      else if (typeof val === 'object' && val !== null) {
        for (const [op, opVal] of Object.entries(val)) {
          // 处理 $size 操作符的嵌套对象（如 {$size: {$gt: 3}}）
          if (op === '$size' && typeof opVal === 'object' && opVal !== null) {
            for (const [sizeOp, sizeVal] of Object.entries(opVal)) {
              const sizeSymbol = opMap[sizeOp] || sizeOp
              rules.push(`${key} 长度 ${sizeSymbol} ${sizeVal}`)
            }
          } else {
            const symbol = opMap[op] || op
            rules.push(`${key} ${symbol} ${opVal}`)
          }
        }
      } else { rules.push(`${key} 等于 ${val}`) }
    }
    return rules
  } catch (e) { return ['解析异常'] }
})

const edgePath = computed(() => {
  const [path] = getSmoothStepPath({
    sourceX: props.sourceX,
    sourceY: props.sourceY,
    sourcePosition: props.sourcePosition,
    targetX: props.targetX,
    targetY: props.targetY,
    targetPosition: props.targetPosition,
  })
  return path
})

const labelX = computed(() => (props.sourceX + props.targetX) / 2)
const labelY = computed(() => (props.sourceY + props.targetY) / 2)

const edgeStyle = computed(() => ({
  stroke: props.data?.isDefault ? '#3b82f6' : '#10b981',
  strokeWidth: 2,
  ...props.style
}))
</script>

<style scoped>
.vue-flow__edge { pointer-events: none; }
.vue-flow__edge-path, .vue-flow__edge-interaction { pointer-events: stroke; cursor: pointer; }

.branch-label {
  pointer-events: auto;
  background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
  color: #047857;
  padding: 4px 12px;
  border-radius: 12px;
  font-size: 11px;
  font-weight: 700;
  border: 2px solid #10b981;
  box-shadow: 0 2px 8px rgba(16, 185, 129, 0.3);
  cursor: help;
  transition: all 0.2s ease;
  white-space: nowrap;
}

/* 默认路径的标签样式：蓝色系 */
.branch-label.is-default {
  background: linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%);
  color: #1e40af;
  border-color: #3b82f6;
  box-shadow: 0 2px 8px rgba(59, 130, 246, 0.3);
}

.branch-label:hover { transform: scale(1.05); box-shadow: 0 4px 12px rgba(16, 185, 129, 0.5); }
.branch-label.is-default:hover { box-shadow: 0 4px 12px rgba(59, 130, 246, 0.5); }

.condition-tooltip-container { padding: 6px; min-width: 180px; max-width: 320px; }
.condition-tooltip-header { font-size: 13px; font-weight: 600; margin-bottom: 10px; display: flex; align-items: center; gap: 8px; color: #f8fafc; }
.condition-tooltip-header .dot { width: 8px; height: 8px; background-color: #10b981; border-radius: 50%; box-shadow: 0 0 8px #10b981; }
.condition-tooltip-header .dot.is-default-dot { background-color: #3b82f6; box-shadow: 0 0 8px #3b82f6; }

.condition-rules-list { display: flex; flex-direction: column; gap: 6px; }
.rule-item { font-size: 12px; line-height: 1.6; background: rgba(30, 41, 59, 0.8); color: #e2e8f0; padding: 6px 10px; border-radius: 8px; border-left: 3px solid #10b981; word-break: break-all; }
.condition-tooltip-header .is-default-dot + .rule-item { border-left-color: #3b82f6; }
.rule-symbol { color: #10b981; margin-right: 4px; font-weight: bold; }
</style>