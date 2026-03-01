import axios from 'axios'
import type { Agent, AgentIntent, IntentStep, ComplianceRule, GlossaryTerm, BatchSaveIntentFlowDTO, BeanWithMethods } from '@/types'

// localStorage key for metadata API base URL
const METADATA_API_URL_KEY = 'jparlant_metadata_api_url'

// 获取元数据服务地址
export const getMetadataApiUrl = (): string | null => {
  return localStorage.getItem(METADATA_API_URL_KEY)
}

// 设置元数据服务地址
export const setMetadataApiUrl = (url: string): void => {
  localStorage.setItem(METADATA_API_URL_KEY, url)
}

// 检查元数据服务地址是否已配置
export const isMetadataApiConfigured = (): boolean => {
  const url = getMetadataApiUrl()
  return !!url && url.trim().length > 0
}

const api = axios.create({
  // import.meta.env.VITE_APP_BASE_API 对应 .env 文件中的配置
  // 如果没定义，默认用 '/'
  baseURL: import.meta.env.VITE_APP_BASE_API || '/',
  timeout: 10000
})

// 元数据服务 API 实例（用于业务动作配置和图片识别执行器）
// 通过代理转发，避免跨域问题
const metadataApi = axios.create({
  baseURL: '/metadata-api',
  timeout: 10000
})

// 元数据服务请求拦截器：添加目标地址到请求头
metadataApi.interceptors.request.use((config) => {
  const targetUrl = getMetadataApiUrl()
  if (targetUrl) {
    config.headers['X-Target-Url'] = targetUrl
  }
  return config
})

// 元数据服务响应拦截器
metadataApi.interceptors.response.use(
  (response) => {
    if (response.data && typeof response.data.code !== 'undefined' && 'data' in response.data) {
      if (response.data.code !== 200) {
        return Promise.reject(new Error(response.data.message || '请求失败'))
      }
      return { ...response, data: response.data.data }
    }
    return response
  },
  (error) => {
    return Promise.reject(error)
  }
)

// 响应拦截器：自动解包后端统一响应格式 { code, message, data }
api.interceptors.response.use(
  (response) => {
    // 如果响应数据包含 code 和 data 字段，说明是后端统一格式，自动解包
    if (response.data && typeof response.data.code !== 'undefined' && 'data' in response.data) {
      // 检查业务状态码
      if (response.data.code !== 200) {
        return Promise.reject(new Error(response.data.message || '请求失败'))
      }
      // 将 response.data.data 提升为 response.data
      return { ...response, data: response.data.data }
    }
    return response
  },
  (error) => {
    return Promise.reject(error)
  }
)

// Agent APIs
export const agentApi = {
  list: () => api.get<Agent[]>('/agents'),
  get: (id: number) => api.get<Agent>(`/agents/${id}`),
  create: (data: Omit<Agent, 'id'>) => api.post<Agent>('/agents', data),
  update: (id: number, data: Partial<Agent>) => api.put<Agent>(`/agents/${id}`, data),
  delete: (id: number) => api.delete(`/agents/${id}`),
  updateStatus: (id: number, status: number) => api.post(`/agents/${id}/status`, null, { params: { status } })
}

// Agent Intent APIs
export const intentApi = {
  listByAgent: (agentId: number) => api.get<AgentIntent[]>(`/agents/${agentId}/intents`),
  get: (id: number) => api.get<AgentIntent>(`/intents/${id}`),
  create: (data: Omit<AgentIntent, 'id'>) => api.post<AgentIntent>('/intents', data),
  update: (id: number, data: Partial<AgentIntent>) => api.put<AgentIntent>(`/intents/${id}`, data),
  delete: (id: number) => api.delete(`/intents/${id}`)
}

// Intent Step APIs
export const stepApi = {
  listByIntent: (intentId: number) => api.get<IntentStep[]>(`/intents/${intentId}/steps`),
  get: (id: number) => api.get<IntentStep>(`/steps/${id}`),
  create: (data: Omit<IntentStep, 'id'>) => api.post<IntentStep>('/steps', data),
  update: (id: number, data: Partial<IntentStep>) => api.put<IntentStep>(`/steps/${id}`, data),
  delete: (id: number) => api.delete(`/steps/${id}`),
  batchUpdate: (steps: IntentStep[]) => api.put('/steps/batch', steps),
  batchUpdatePriority: (steps: IntentStep[]) => api.put('/steps/batch/priority', steps),
  batchSaveFlow: (data: BatchSaveIntentFlowDTO) => api.post('/steps/batch/line', data),
  // 获取所有可用的业务动作元数据（使用独立配置的元数据服务）
  getActionMetadata: () => metadataApi.get<BeanWithMethods[]>('/jparlant/metadata/actions')
}

// Compliance Rule APIs
export const complianceApi = {
  listByAgent: (agentId: number) => api.get<ComplianceRule[]>(`/agents/${agentId}/compliance-rules`),
  get: (id: number) => api.get<ComplianceRule>(`/compliance-rules/${id}`),
  create: (data: Omit<ComplianceRule, 'id'>) => api.post<ComplianceRule>('/compliance-rules', data),
  update: (id: number, data: Partial<ComplianceRule>) => api.put<ComplianceRule>(`/compliance-rules/${id}`, data),
  delete: (id: number) => api.delete(`/compliance-rules/${id}`)
}

// Glossary APIs
export const glossaryApi = {
  listByAgent: (agentId: number) => api.get<GlossaryTerm[]>(`/agents/${agentId}/glossary`),
  get: (id: number) => api.get<GlossaryTerm>(`/glossary/${id}`),
  create: (data: Omit<GlossaryTerm, 'id'>) => api.post<GlossaryTerm>('/glossary', data),
  update: (id: number, data: Partial<GlossaryTerm>) => api.put<GlossaryTerm>(`/glossary/${id}`, data),
  delete: (id: number) => api.delete(`/glossary/${id}`)
}

export const variableApi = {
  // 获取 Intent 下的所有变量
  listByIntent: (intentId: number) => api.get(`/variables/intent/${intentId}`),

  // 创建变量
  create: (data: any) => api.post('/variables', data),

  // 更新变量
  update: (id: number, data: any) => api.put(`/variables/${id}`, data),

  // 删除变量
  delete: (id: number) => api.delete(`/variables/${id}`)
}

// Chat API for testing intents
export const chatApi = {
  streamChat: async (
    intentId: number,
    question: string,
    files: File[],
    userId: string, // 1. 新增参数接收 UI 传来的 userId
    onChunk: (chunk: string) => void
  ): Promise<void> => {
    const formData = new FormData()
    formData.append('question', question)
    formData.append('intentId', intentId.toString()) // 建议：将 intentId 也传给后端
    formData.append('chatQueryType', '1')
    files.forEach(file => formData.append('files', file))

    // 如果后端习惯从 FormData 中获取 userId，也可以取消下面这行的注释
    // formData.append('userId', userId) 

    const response = await fetch('/customerAgent/chatInText/stream', {
      method: 'POST',
      headers: {
        'userId': userId, // 2. 将硬编码修改为动态获取的参数
        'timezone': 'Asia/Shanghai'
      },
      body: formData
    })

    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)

    const reader = response.body?.getReader()
    if (!reader) throw new Error('无法获取响应流')

    const decoder = new TextDecoder()
    let buffer = '' 

    try {
      while (true) {
        const { done, value } = await reader.read()
        if (done) break

        buffer += decoder.decode(value, { stream: true })
        
        let lines = buffer.split('\n')
        buffer = lines.pop() || '' 

        for (const line of lines) {
          const trimmedLine = line.trim()
          if (!trimmedLine || !trimmedLine.startsWith('data:')) continue

          const data = trimmedLine.substring(5).trim()
          if (data === '[DONE]') break

          try {
            const json = JSON.parse(data)
            if (json.answer) {
              onChunk(json.answer)
            }
          } catch (e) {
            onChunk(data)
          }
        }
      }
    } finally {
      reader.releaseLock()
    }
  }
}


export default api