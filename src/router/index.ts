import { createRouter, createWebHistory } from 'vue-router'
import Layout from '@/views/Layout.vue'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      component: Layout,
      redirect: '/agents',
      children: [
        {
          path: '/agents',
          name: 'Agents',
          component: () => import('@/views/agents/AgentList.vue'),
          meta: { title: '' }
        },
        {
          path: '/agents/:id/flows',
          name: 'AgentFlows',
          component: () => import('@/views/flows/FlowBuilder.vue'),
          meta: { title: '' }
        },
        {
          path: '/agents/:id/intents',
          name: 'AgentIntents',
          component: () => import('@/views/intents/IntentManager.vue'),
          meta: { title: '' }
        },
        {
          path: '/agents/:agentId/intents/:intentId/chat',
          name: 'IntentChat',
          component: () => import('@/views/intents/IntentChat.vue'),
          meta: { title: '' }
        },
        {
          path: '/agents/:id/compliance',
          name: 'ComplianceRules',
          component: () => import('@/views/compliance/ComplianceManager.vue'),
          meta: { title: '' }
        },
        {
          path: '/agents/:id/glossary',
          name: 'Glossary',
          component: () => import('@/views/glossary/GlossaryManager.vue'),
          meta: { title: '' }
        }
      ]
    }
  ]
})

export default router