<template>
  <div id="app">
    <!-- 1. 主题配置 -->
    <n-config-provider :theme="theme">
      <!-- 2. 全局样式 -->
      <n-global-style />
      
      <!-- 3. 加载条提供者 -->
      <n-loading-bar-provider>
        <!-- 4. 消息提供者 (解决你报错的关键) -->
        <n-message-provider>
          <!-- 5. 通知提供者 -->
          <n-notification-provider>
            <!-- 6. 对话框提供者 -->
            <n-dialog-provider>
              
              <!-- 业务内容入口 -->
              <router-view />
              
            </n-dialog-provider>
          </n-notification-provider>
        </n-message-provider>
      </n-loading-bar-provider>
      
    </n-config-provider>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { 
  NConfigProvider, 
  NGlobalStyle, 
  darkTheme, 
  NMessageProvider, 
  NDialogProvider, 
  NNotificationProvider, 
  NLoadingBarProvider 
} from 'naive-ui'
import { useThemeStore } from '@/stores/theme'

const themeStore = useThemeStore()
const theme = computed(() => themeStore.isDark ? darkTheme : null)
</script>

<style>
/* 确保 app 撑满全屏 */
#app {
  height: 100vh;
}
</style>