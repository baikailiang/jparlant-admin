export interface Agent {
  id?: number
  name: string
  instructions: string
  description: string
  keywords: string
  status: boolean
  createdAt?: string
  updatedAt?: string
}

export interface AgentIntent {
  id?: number
  agentId: number
  name: string
  description: string
  enabled: boolean
  flowType: FlowType
  metadataJson?: string
  createdAt?: string
  updatedAt?: string
}

export interface IntentStep {
  id?: number
  intentId: number
  name: string
  description: string
  belongToPhase: SessionPhase
  priority: number
  stepType: StepType
  prompt: string
  expectedInputsJson?: string
  validationJson?: string
  dependencies?: string
  canSkip: boolean
  skipToPrompt?: string
  coreActionsJson?: string
  transitionsJson?: string
}

export interface FlowTransition {
  condition: string
  targetStepId: number
  label: string
}

export interface ComplianceRule {
  id?: number
  agentId: number
  name: string
  description?: string
  scope: ComplianceScope
  keywords?: string[]
  parameters?: Record<string, any>
  conditionExpr?: string
  blockedResponse?: string
  categories?: string[]
  priority: number
  enabled: boolean
  guidelinePrompt?: string
  createdAt?: string
  updatedAt?: string
}

export interface GlossaryTerm {
  id?: number
  name: string
  definition: string
  category: string
  synonyms?: string[]
  relatedNames?: string[]
  examples?: Record<string, any>
  agentId: number
  priority: number
  createdAt?: string
  updatedAt?: string
}

export type FlowType = 'LINEAR' | 'CONDITIONAL' | 'LOOP' | 'INTERACTIVE'

export type StepType = 'INPUT' | 'ACTION' | 'COMPLETED'

export type SessionPhase = 
  | 'READY' 
  | 'PROLOGUE' 
  | 'UNDERSTANDING' 
  | 'PROCESSING' 
  | 'REVIEW' 
  | 'PENDING' 
  | 'HANDOVER' 
  | 'SUSPENDED' 
  | 'CLOSING' 
  | 'ARCHIVED' 
  | 'TERMINATED'

export type ComplianceScope = 'INPUT' | 'RESPONSE' | 'ALL'

// Vue Flow types
export interface FlowNode {
  id: string
  type?: string
  position: { x: number; y: number }
  data: {
    step: IntentStep
    label: string
  }
}

export interface FlowEdge {
  id: string
  source: string
  target: string
  type?: string
  animated?: boolean
  label?: string
  data?: {
    condition?: string
    transitionLabel?: string
  }
  style?: any
  labelStyle?: any
  labelBgStyle?: any
  selected?: boolean
}

export interface FlowVariable {
  id: number | string
  intentId?: number
  parentId?: number | null
  name: string
  description: string
  type: VariableType
  isRequired?: number
  defaultValue?: string
  children?: FlowVariable[]
  createdAt?: string
  updatedAt?: string
}

export type VariableType = 'STRING' | 'NUMBER' | 'BOOLEAN' | 'OBJECT' | 'ARRAY'

// 步骤转换关系（用于批量保存流程配置）
export interface IntentStepTransition {
  intentId: number
  fromStepId: number
  toStepId: number
  branchCode?: string
  conditionJson?: string
  priority: number
  isDefault?: number
}

// 批量保存流程配置 DTO
export interface BatchSaveIntentFlowDTO {
  intentId: number
  transitions: IntentStepTransition[]
}

// Action 元数据相关类型
export interface PropertySchema {
  name: string
  type: string
  description: string
  complex: boolean
  children: PropertySchema[]
}

export interface MethodMetadata {
  methodName: string
  displayName: string
  parameters: PropertySchema[]
  returnSchema: PropertySchema
}

export interface BeanWithMethods {
  beanName: string
  displayName: string
  methods: MethodMetadata[]
}