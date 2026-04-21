import { createRouter, createWebHistory } from 'vue-router'
import Layout from '@/views/Layout.vue'
import { useUserStore } from '@/stores/user'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'Login',
      component: () => import('@/views/login/LoginView.vue'),
      meta: { public: true }
    },
    {
      path: '/',
      component: Layout,
      redirect: '/agents',
      children: [
        {
          path: '/agents',
          name: 'Agents',
          component: () => import('@/views/agents/AgentList.vue'),
          meta: { title: '智能体管理' }
        },
        {
          path: '/agents/:id/flows',
          name: 'AgentFlows',
          component: () => import('@/views/flows/FlowBuilder.vue'),
          meta: { title: '流程编排' }
        },
        {
          path: '/agents/:id/intents',
          name: 'AgentIntents',
          component: () => import('@/views/intents/IntentManager.vue'),
          meta: { title: '意图管理' }
        },
        {
          path: '/agents/:agentId/intents/:intentId/chat',
          name: 'IntentChat',
          component: () => import('@/views/intents/IntentChat.vue'),
          meta: { title: '意图测试' }
        },
        {
          path: '/agents/:id/compliance',
          name: 'ComplianceRules',
          component: () => import('@/views/compliance/ComplianceManager.vue'),
          meta: { title: '合规规则' }
        },
        {
          path: '/agents/:id/glossary',
          name: 'Glossary',
          component: () => import('@/views/glossary/GlossaryManager.vue'),
          meta: { title: '术语表' }
        }
      ]
    }
  ]
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const userStore = useUserStore()

  // 公开页面直接放行
  if (to.meta.public) {
    next()
    return
  }

  // 检查登录状态
  if (!userStore.isLoggedIn) {
    next('/login')
    return
  }

  next()
})

export default router