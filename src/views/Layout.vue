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
            <!-- 模式切换按钮 -->
            <!-- <button
              @click="themeStore.toggleTheme"
              class="theme-toggle-wrapper group relative flex items-center justify-center w-12 h-12 rounded-2xl transition-all duration-500"
              :class="themeStore.isDark ? 'bg-amber-400/10 shadow-[0_0_20px_rgba(251,191,36,0.2)] border border-amber-400/20' : 'bg-indigo-50 shadow-sm border border-indigo-100'"
            >
              <div class="relative w-full h-full flex items-center justify-center overflow-hidden">
                
                <div class="absolute transition-all duration-500 transform" 
                  :class="themeStore.isDark ? '-translate-y-12 opacity-0 rotate-90' : 'translate-y-0 opacity-100 rotate-0'">
                  <n-icon size="24" color="#6366f1">
                    <svg viewBox="0 0 24 24">
                      <path fill="currentColor" d="M12 3a9 9 0 1 0 9 9c0-.46-.04-.92-.1-1.36a5.389 5.389 0 0 1-4.4 2.26 5.403 5.403 0 0 1-3.14-9.8c-.44-.06-.9-.1-1.36-.1"/>
                    </svg>
                  </n-icon>
                </div>
                
                <div class="absolute transition-all duration-500 transform" 
                  :class="themeStore.isDark ? 'translate-y-0 opacity-100 rotate-0' : 'translate-y-12 opacity-0 -rotate-90'">
                  <n-icon size="26" color="#fbbf24" class="sun-icon-glow">
                    <svg viewBox="0 0 24 24">
                      <path fill="currentColor" d="M12 7a5 5 0 1 0 5 5 5 5 0 0 0-5-5m0 8a3 3 0 1 1 3-3 3 3 0 0 1-3 3m0-9V4m0 16v-2m8-8h2M2 12h2m15.07-7.07l-1.41 1.41M5.05 18.95l-1.42 1.42M18.95 18.95l1.42 1.42M5.05 5.05L3.64 3.64"/>
                    </svg>
                  </n-icon>
                </div>
              </div>
            </button> -->
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
  NIcon
} from 'naive-ui'
import { useThemeStore } from '@/stores/theme'

const router = useRouter()
const route = useRoute()
const themeStore = useThemeStore()

const collapsed = ref(false)
const activeKey = ref('')

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