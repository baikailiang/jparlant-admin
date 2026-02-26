import { defineStore } from 'pinia'
import { ref } from 'vue'
import type { Agent } from '@/types'

export const useAgentStore = defineStore('agent', () => {
  const agents = ref<Agent[]>([])
  const currentAgent = ref<Agent>()
  const loading = ref(false)

  const setAgents = (newAgents: Agent[]) => {
    agents.value = newAgents
  }

  const addAgent = (agent: Agent) => {
    agents.value.push(agent)
  }

  const updateAgent = (id: number, updates: Partial<Agent>) => {
    const index = agents.value.findIndex(a => a.id === id)
    if (index !== -1) {
      agents.value[index] = { ...agents.value[index], ...updates }
    }
  }

  const removeAgent = (id: number) => {
    const index = agents.value.findIndex(a => a.id === id)
    if (index !== -1) {
      agents.value.splice(index, 1)
    }
  }

  const setCurrentAgent = (agent: Agent) => {
    currentAgent.value = agent
  }

  return {
    agents,
    currentAgent,
    loading,
    setAgents,
    addAgent,
    updateAgent,
    removeAgent,
    setCurrentAgent
  }
})