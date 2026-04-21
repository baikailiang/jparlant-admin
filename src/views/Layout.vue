<template>
  <!-- 根容器 -->
  <div :class="['min-h-screen transition-colors duration-500', themeStore.isDark ? 'bg-[#0f172a] text-slate-200' : 'bg-gradient-to-br from-gray-50 via-blue-50/20 to-purple-50/20']">
    <n-layout has-sider class="bg-transparent">
      <!-- 侧边栏 -->
      <n-layout-sider
        bordered
        collapse-mode="width"
        :collapsed-width="64"
        :width="260"
        :collapsed="collapsed"
        show-trigger
        @collapse="collapsed = true"
        @expand="collapsed = false"
        :class="['sidebar-modern transition-all duration-500', themeStore.isDark ? 'bg-[#1e293b]/90 border-gray-800' : 'bg-white/90']"
      >
        <div class="flex flex-col h-full bg-transparent">
          <!-- Logo区域 -->
          <div :class="['flex items-center justify-center h-20 border-b backdrop-blur-sm transition-colors duration-500', themeStore.isDark ? 'border-gray-800 bg-slate-900/50' : 'border-gray-200/80 bg-white/90']">
            <div v-if="!collapsed" class="flex items-center space-x-3 animate-fade-in">
              <div class="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center shadow-lg transform hover:rotate-12 transition-transform">
                <span class="text-2xl">🤖</span>
              </div>
              <span class="text-xl font-bold bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">J-Parlant</span>
            </div>
            <div v-else class="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-purple-600 flex items-center justify-center shadow-lg">
              <span class="text-2xl">🤖</span>
            </div>
          </div>

          <!-- 导航菜单 -->
          <n-menu
            v-model:value="activeKey"
            :collapsed="collapsed"
            :collapsed-width="64"
            :collapsed-icon-size="24"
            :options="menuOptions"
            :root-indent="20"
            :indent="16"
            @update:value="handleMenuSelect"
            :inverted="themeStore.isDark"
            class="menu-modern"
          />
        </div>
      </n-layout-sider>

      <!-- 主内容区 -->
      <n-layout class="bg-transparent">
        <!-- 顶部导航栏 -->
        <n-layout-header
          bordered
          :class="['h-18 flex items-center justify-between px-8 backdrop-blur-md shadow-sm transition-all duration-500', 
            themeStore.isDark ? 'bg-slate-900/80 border-gray-800' : 'bg-white/95 border-gray-200/80']"
        >
          <div class="flex items-center space-x-4">
            <n-breadcrumb class="breadcrumb-modern">
              <n-breadcrumb-item v-for="item in breadcrumbs" :key="item.name">
                <span :class="['font-medium transition-colors', themeStore.isDark ? 'text-slate-300 hover:text-blue-400' : 'text-gray-700 hover:text-blue-600']">
                  {{ item.title }}
                </span>
              </n-breadcrumb-item>
            </n-breadcrumb>
          </div>

          <div class="flex items-center space-x-3">
            <!-- 用户信息 -->
            <n-dropdown :options="userDropdownOptions" @select="handleUserDropdownSelect">
              <div class="flex items-center space-x-2 cursor-pointer px-3 py-2 rounded-lg hover:bg-gray-100 dark:hover:bg-slate-800 transition-colors">
                <n-avatar
                  round
                  size="small"
                  :src="userStore.userInfo?.avatar"
                  :fallback-src="defaultAvatar"
                />
                <span class="text-sm font-medium" :class="themeStore.isDark ? 'text-slate-200' : 'text-gray-700'">
                  {{ userStore.userInfo?.nickname || userStore.userInfo?.username || '用户' }}
                </span>
                <n-icon size="16" :class="themeStore.isDark ? 'text-slate-400' : 'text-gray-500'">
                  <svg viewBox="0 0 24 24"><path fill="currentColor" d="M7.41 8.59L12 13.17l4.59-4.58L18 10l-6 6-6-6 1.41-1.41z"/></svg>
                </n-icon>
              </div>
            </n-dropdown>
          </div>
        </n-layout-header>

        <!-- 主内容 -->
        <n-layout-content class="p-0 bg-transparent">
          <router-view />
        </n-layout-content>
      </n-layout>
    </n-layout>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, h } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import {
  NLayout,
  NLayoutSider,
  NLayoutHeader,
  NLayoutContent,
  NMenu,
  NBreadcrumb,
  NBreadcrumbItem,
  NIcon,
  NDropdown,
  NAvatar,
  useMessage
} from 'naive-ui'
import { useThemeStore } from '@/stores/theme'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const route = useRoute()
const themeStore = useThemeStore()
const userStore = useUserStore()
const message = useMessage()

const collapsed = ref(false)
const activeKey = ref('')
const defaultAvatar = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNDAiIGhlaWdodD0iNDAiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48Y2lyY2xlIGN4PSIxMiIgY3k9IjEyIiByPSIxMCIgZmlsbD0iI2U1ZTdlYiIvPjxwYXRoIGQ9Ik0xMiAxMmMyLjIxIDAgNC0xLjc5IDQtNHMtMS43OS00LTQtNC00IDEuNzktNCA0IDEuNzkgNCA0IDR6bTAgMmMtMi42NyAwLTggMS4zNC04IDR2MmgxNnYtMmMwLTIuNjYtNS4zMy00LTgtNHoiIGZpbGw9IiM5Y2EzYWYiLz48L3N2Zz4='

const userDropdownOptions = [
  {
    label: '退出登录',
    key: 'logout',
    icon: () => h(NIcon, null, { default: () => h('svg', { viewBox: '0 0 24 24' }, [h('path', { fill: 'currentColor', d: 'M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z' })]) })
  }
]

const handleUserDropdownSelect = (key: string) => {
  if (key === 'logout') {
    userStore.logout()
    message.success('已退出登录')
    router.push('/login')
  }
}

const menuOptions = computed(() => [
  {
    label: 'Agent 管理',
    key: '/agents',
    icon: () => h('div', { class: 'text-xl transform transition-transform group-hover:scale-110' }, '🤖')
  }
])

const breadcrumbs = computed(() => {
  const matched = route.matched.filter(item => item.meta?.title)
  return matched.map(item => ({
    name: item.name,
    title: item.meta?.title
  }))
})

const handleMenuSelect = (key: string) => {
  router.push(key)
}
</script>

<style scoped>
.sidebar-modern {
  box-shadow: 4px 0 20px rgba(0, 0, 0, 0.05);
  z-index: 10;
}

/* 菜单样式优化 */
.menu-modern :deep(.n-menu-item) {
  margin: 6px 12px;
  border-radius: 12px;
  transition: all 0.3s ease;
  font-weight: 500;
}

.menu-modern :deep(.n-menu-item.n-menu-item--selected) {
  background: linear-gradient(135deg, #6366f1 0%, #4338ca 100%) !important;
  color: white !important;
  box-shadow: 0 4px 15px rgba(99, 102, 241, 0.35);
}

/* 太阳图标发光增强 */
.sun-icon-glow {
  filter: drop-shadow(0 0 8px rgba(251, 191, 36, 0.8));
}

/* 模式切换按钮悬停 */
.theme-toggle-wrapper {
  cursor: pointer;
  outline: none;
}

.theme-toggle-wrapper:hover {
  transform: scale(1.05);
}

.theme-toggle-wrapper:active {
  transform: scale(0.95);
}

/* 面包屑样式 */
.breadcrumb-modern :deep(.n-breadcrumb-item__separator) {
  color: #94a3b8;
  margin: 0 8px;
}

/* 动画 */
@keyframes fadeIn {
  from { opacity: 0; transform: translateY(-4px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fade-in {
  animation: fadeIn 0.4s ease-out forwards;
}

:deep(.n-layout-toggle-button) {
  border-radius: 50%;
  width: 24px;
  height: 24px;
  background: #6366f1 !important;
  color: white !important;
  right: -12px;
}
</style>