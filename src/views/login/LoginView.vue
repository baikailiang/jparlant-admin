<template>
  <div class="login-container">
    <!-- 背景装饰 -->
    <div class="bg-decoration">
      <div class="circle circle-1"></div>
      <div class="circle circle-2"></div>
      <div class="circle circle-3"></div>
    </div>

    <div class="login-box">
      <!-- Logo 区域 -->
      <div class="login-header">
        <div class="logo-wrapper">
          <div class="logo-container">
            <!-- 六边形主体 -->
            <svg class="hexagon-logo" viewBox="0 0 240 240" xmlns="http://www.w3.org/2000/svg">
              <defs>
                <linearGradient id="hexGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" style="stop-color:#00d4ff"/>
                  <stop offset="35%" style="stop-color:#7c3aed"/>
                  <stop offset="70%" style="stop-color:#a855f7"/>
                  <stop offset="100%" style="stop-color:#ec4899"/>
                </linearGradient>
                <linearGradient id="hexGradient2" x1="0%" y1="100%" x2="100%" y2="0%">
                  <stop offset="0%" style="stop-color:#ec4899"/>
                  <stop offset="30%" style="stop-color:#a855f7"/>
                  <stop offset="65%" style="stop-color:#7c3aed"/>
                  <stop offset="100%" style="stop-color:#00d4ff"/>
                </linearGradient>
                <linearGradient id="lineGradient" x1="0%" y1="0%" x2="100%" y2="0%">
                  <stop offset="0%" style="stop-color:#00d4ff;stop-opacity:0.2"/>
                  <stop offset="50%" style="stop-color:#7c3aed;stop-opacity:0.9"/>
                  <stop offset="100%" style="stop-color:#a855f7;stop-opacity:0.2"/>
                </linearGradient>
                <filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
                  <feGaussianBlur stdDeviation="3" result="blur"/>
                  <feMerge>
                    <feMergeNode in="blur"/>
                    <feMergeNode in="SourceGraphic"/>
                  </feMerge>
                </filter>
                <filter id="glowStrong" x="-50%" y="-50%" width="200%" height="200%">
                  <feGaussianBlur stdDeviation="5" result="blur"/>
                  <feMerge>
                    <feMergeNode in="blur"/>
                    <feMergeNode in="SourceGraphic"/>
                  </feMerge>
                </filter>
              </defs>
              
              <!-- 背景光环 -->
              <circle cx="120" cy="120" r="100" fill="none" stroke="url(#hexGradient)" stroke-width="0.5" opacity="0.15" filter="url(#glow)"/>
              <circle cx="120" cy="120" r="85" fill="none" stroke="url(#hexGradient2)" stroke-width="0.5" opacity="0.2" filter="url(#glow)"/>
              
              <!-- 外层六边形框架 -->
              <polygon class="hex-outer" points="120,15 205,65 205,175 120,225 35,175 35,65" 
                       fill="none" stroke="url(#hexGradient)" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
              
              <!-- 中层六边形 -->
              <polygon class="hex-mid" points="120,45 175,80 175,160 120,195 65,160 65,80" 
                       fill="none" stroke="url(#hexGradient2)" stroke-width="1.8" opacity="0.7" stroke-linecap="round" stroke-linejoin="round"/>
              
              <!-- 内层六边形 -->
              <polygon class="hex-inner" points="120,70 155,92 155,148 120,170 85,148 85,92" 
                       fill="none" stroke="url(#hexGradient)" stroke-width="1.2" opacity="0.5" stroke-linecap="round" stroke-linejoin="round"/>
              
              <!-- 中心填充六边形 -->
              <polygon class="hex-core" points="120,85 142,100 142,130 120,145 98,130 98,100" 
                       fill="url(#hexGradient)" opacity="0.15"/>
              
              <!-- 连接线网络 -->
              <g class="connections" stroke="url(#lineGradient)" stroke-width="1.2" fill="none" stroke-linecap="round">
                <!-- 从中心到内层 -->
                <line x1="120" y1="120" x2="120" y2="70"/>
                <line x1="120" y1="120" x2="155" y2="92"/>
                <line x1="120" y1="120" x2="155" y2="148"/>
                <line x1="120" y1="120" x2="120" y2="170"/>
                <line x1="120" y1="120" x2="85" y2="148"/>
                <line x1="120" y1="120" x2="85" y2="92"/>
                <!-- 从内层到中层 -->
                <line x1="120" y1="70" x2="120" y2="45"/>
                <line x1="155" y1="92" x2="175" y2="80"/>
                <line x1="155" y1="148" x2="175" y2="160"/>
                <line x1="120" y1="170" x2="120" y2="195"/>
                <line x1="85" y1="148" x2="65" y2="160"/>
                <line x1="85" y1="92" x2="65" y2="80"/>
                <!-- 从中层到外层 -->
                <line x1="120" y1="45" x2="120" y2="15"/>
                <line x1="175" y1="80" x2="205" y2="65"/>
                <line x1="175" y1="160" x2="205" y2="175"/>
                <line x1="120" y1="195" x2="120" y2="225"/>
                <line x1="65" y1="160" x2="35" y2="175"/>
                <line x1="65" y1="80" x2="35" y2="65"/>
                <!-- 交叉连接线 -->
                <line x1="120" y1="45" x2="175" y2="160" opacity="0.3"/>
                <line x1="120" y1="45" x2="65" y2="160" opacity="0.3"/>
                <line x1="175" y1="80" x2="65" y2="80" opacity="0.3"/>
                <line x1="175" y1="160" x2="65" y2="160" opacity="0.3"/>
              </g>
              
              <!-- 节点 -->
              <g class="nodes">
                <!-- 中心大节点 -->
                <circle cx="120" cy="120" r="9" fill="url(#hexGradient)" filter="url(#glowStrong)"/>
                <circle cx="120" cy="120" r="5" fill="white" opacity="0.9"/>
                
                <!-- 内层节点 -->
                <circle cx="120" cy="70" r="5" fill="url(#hexGradient)" filter="url(#glow)"/>
                <circle cx="155" cy="92" r="5" fill="url(#hexGradient)" filter="url(#glow)"/>
                <circle cx="155" cy="148" r="5" fill="url(#hexGradient)" filter="url(#glow)"/>
                <circle cx="120" cy="170" r="5" fill="url(#hexGradient)" filter="url(#glow)"/>
                <circle cx="85" cy="148" r="5" fill="url(#hexGradient)" filter="url(#glow)"/>
                <circle cx="85" cy="92" r="5" fill="url(#hexGradient)" filter="url(#glow)"/>
                
                <!-- 中层节点 -->
                <circle cx="120" cy="45" r="4" fill="url(#hexGradient2)" filter="url(#glow)"/>
                <circle cx="175" cy="80" r="4" fill="url(#hexGradient2)" filter="url(#glow)"/>
                <circle cx="175" cy="160" r="4" fill="url(#hexGradient2)" filter="url(#glow)"/>
                <circle cx="120" cy="195" r="4" fill="url(#hexGradient2)" filter="url(#glow)"/>
                <circle cx="65" cy="160" r="4" fill="url(#hexGradient2)" filter="url(#glow)"/>
                <circle cx="65" cy="80" r="4" fill="url(#hexGradient2)" filter="url(#glow)"/>
                
                <!-- 外层节点 -->
                <circle cx="120" cy="15" r="6" fill="url(#hexGradient)" filter="url(#glowStrong)"/>
                <circle cx="205" cy="65" r="6" fill="url(#hexGradient)" filter="url(#glowStrong)"/>
                <circle cx="205" cy="175" r="6" fill="url(#hexGradient)" filter="url(#glowStrong)"/>
                <circle cx="120" cy="225" r="6" fill="url(#hexGradient)" filter="url(#glowStrong)"/>
                <circle cx="35" cy="175" r="6" fill="url(#hexGradient)" filter="url(#glowStrong)"/>
                <circle cx="35" cy="65" r="6" fill="url(#hexGradient)" filter="url(#glowStrong)"/>
              </g>
              
              <!-- 中心文字 -->
              <text x="120" y="128" text-anchor="middle" class="logo-text" 
                    fill="white" font-size="16" font-weight="800" font-family="'Segoe UI', Arial, sans-serif" letter-spacing="1">JP</text>
            </svg>
            
            <!-- 品牌名称 -->
            <div class="brand-name">jparlant</div>
            
            <!-- 光晕效果 -->
            <div class="logo-glow"></div>
          </div>
        </div>
      </div>

      <!-- 欢迎语 -->
      <div class="welcome-section">
        <h2 class="welcome-title">
          智能体流程编排平台
        </h2>
      </div>

      <n-form
        ref="formRef"
        :model="formData"
        :rules="rules"
        class="login-form"
        @keyup.enter="handleLogin"
      >
        <n-form-item path="username">
          <n-input
            v-model:value="formData.username"
            placeholder="请输入用户名"
            size="large"
            :disabled="loading"
            class="input-custom"
          >
            <template #prefix>
              <n-icon class="input-icon"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg></n-icon></template>
          </n-input>
        </n-form-item>

        <n-form-item path="password">
          <n-input
            v-model:value="formData.password"
            type="password"
            placeholder="请输入密码"
            size="large"
            :disabled="loading"
            show-password-on="mousedown"
            class="input-custom"
          >
            <template #prefix>
              <n-icon class="input-icon"><svg viewBox="0 0 24 24"><path fill="currentColor" d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"/></svg></n-icon></template>
          </n-input>
        </n-form-item>

        <n-form-item>
          <n-checkbox v-model:checked="rememberMe" class="remember-checkbox">记住用户名</n-checkbox>
        </n-form-item>

        <n-button
          type="primary"
          size="large"
          block
          :loading="loading"
          class="login-button"
          @click="handleLogin"
        >
          登 录
        </n-button>
      </n-form>
    </div>

    <!-- 底部信息 -->
    <div class="login-footer">
      <p>© 2024 J-Parlant 智能流程编排平台</p>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useMessage } from 'naive-ui'
import { useUserStore } from '@/stores/user'
import { authApi } from '@/api'

const router = useRouter()
const message = useMessage()
const userStore = useUserStore()

const formRef = ref()
const loading = ref(false)
const rememberMe = ref(false)

const formData = ref({
  username: '',
  password: ''
})

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ required: true, message: '请输入密码', trigger: 'blur' }]
}

// 检查是否已登录
onMounted(() => {
  if (userStore.isLoggedIn) {
    router.push('/')
  }
  // 读取记住的用户名
  const rememberedUsername = localStorage.getItem('jparlant_remember_username')
  if (rememberedUsername) {
    formData.value.username = rememberedUsername
    rememberMe.value = true
  }
})

const handleLogin = async () => {
  try {
    await formRef.value?.validate()
    loading.value = true

    const res = await authApi.login({
      username: formData.value.username,
      password: formData.value.password
    })

    // 兼容不同的响应数据结构
    const loginData = res?.data ?? res
    const token = loginData?.token
    const userInfo = loginData?.userInfo

    if (!token) {
      throw new Error('登录响应异常：未获取到 token')
    }

    userStore.setToken(token)
    if (userInfo) {
      userStore.setUserInfo(userInfo)
    }

    // 记住用户名
    if (rememberMe.value) {
      localStorage.setItem('jparlant_remember_username', formData.value.username)
    } else {
      localStorage.removeItem('jparlant_remember_username')
    }

    message.success('登录成功')
    
    // 使用 replace 避免浏览器后退返回登录页
    router.replace('/')
  } catch (error: any) {
    message.error(error.message || '登录失败')
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-container {
  height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  position: relative;
  overflow: hidden;
}

/* 背景装饰 */
.bg-decoration {
  position: absolute;
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  overflow: hidden;
}

.circle {
  position: absolute;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.1);
}

.circle-1 {
  width: 400px;
  height: 400px;
  top: -100px;
  right: -100px;
  animation: float 6s ease-in-out infinite;
}

.circle-2 {
  width: 300px;
  height: 300px;
  bottom: -50px;
  left: -50px;
  animation: float 8s ease-in-out infinite reverse;
}

.circle-3 {
  width: 200px;
  height: 200px;
  top: 50%;
  left: 10%;
  animation: float 7s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-20px); }
}

/* 登录框 */
.login-box {
  width: 420px;
  padding: 48px 40px;
  background: white;
  border-radius: 24px;
  box-shadow: 0 25px 80px rgba(0, 0, 0, 0.25);
  position: relative;
  z-index: 1;
}

/* Logo 区域 */
.login-header {
  margin-bottom: 24px;
}

.logo-container {
  position: relative;
  width: 160px;
  height: 180px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  margin: 0 auto;
}

.hexagon-logo {
  width: 140px;
  height: 140px;
  filter: drop-shadow(0 4px 20px rgba(124, 58, 237, 0.4));
}

/* 六边形动画 */
.hex-outer {
  animation: rotate 20s linear infinite;
  transform-origin: center;
}

.hex-inner {
  animation: rotate 15s linear infinite reverse;
  transform-origin: center;
}

.connections line {
  stroke-dasharray: 100;
  stroke-dashoffset: 100;
  animation: drawLine 2s ease forwards;
}

.connections line:nth-child(1) { animation-delay: 0.1s; }
.connections line:nth-child(2) { animation-delay: 0.2s; }
.connections line:nth-child(3) { animation-delay: 0.3s; }
.connections line:nth-child(4) { animation-delay: 0.4s; }
.connections line:nth-child(5) { animation-delay: 0.5s; }
.connections line:nth-child(6) { animation-delay: 0.6s; }
.connections line:nth-child(7) { animation-delay: 0.7s; }
.connections line:nth-child(8) { animation-delay: 0.8s; }

.nodes circle {
  opacity: 0;
  animation: fadeIn 0.5s ease forwards;
}

.nodes circle:nth-child(1) { animation-delay: 0.2s; }
.nodes circle:nth-child(2) { animation-delay: 0.3s; }
.nodes circle:nth-child(3) { animation-delay: 0.35s; }
.nodes circle:nth-child(4) { animation-delay: 0.4s; }
.nodes circle:nth-child(5) { animation-delay: 0.45s; }
.nodes circle:nth-child(6) { animation-delay: 0.5s; }
.nodes circle:nth-child(7) { animation-delay: 0.55s; }
.nodes circle:nth-child(8) { animation-delay: 0.6s; }
.nodes circle:nth-child(9) { animation-delay: 0.65s; }
.nodes circle:nth-child(10) { animation-delay: 0.7s; }
.nodes circle:nth-child(11) { animation-delay: 0.75s; }
.nodes circle:nth-child(12) { animation-delay: 0.8s; }
.nodes circle:nth-child(13) { animation-delay: 0.85s; }

@keyframes rotate {
  from { transform: rotate(0deg); }
  to { transform: rotate(360deg); }
}

@keyframes drawLine {
  to { stroke-dashoffset: 0; }
}

@keyframes fadeIn {
  to { opacity: 1; }
}

.logo-text {
  animation: pulse 2s ease-in-out infinite;
  text-shadow: 0 0 10px rgba(124, 58, 237, 0.8);
}

.brand-name {
  margin-top: 10px;
  font-size: 22px;
  font-weight: 700;
  letter-spacing: 3px;
  background: linear-gradient(90deg, #00d4ff, #7c3aed, #a855f7);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  text-shadow: none;
  font-family: 'Segoe UI', sans-serif;
}

.logo-glow {
  position: absolute;
  width: 180px;
  height: 180px;
  top: 0;
  border-radius: 50%;
  background: radial-gradient(circle, rgba(124, 58, 237, 0.25) 0%, transparent 70%);
  animation: pulse 3s ease-in-out infinite;
  z-index: -1;
}

@keyframes pulse {
  0%, 100% { transform: scale(1); opacity: 0.6; }
  50% { transform: scale(1.15); opacity: 0.3; }
}

@keyframes pulse {
  0%, 100% { transform: scale(1); opacity: 0.6; }
  50% { transform: scale(1.2); opacity: 0.3; }
}

/* 欢迎语 */
.welcome-section {
  text-align: center;
  margin-bottom: 28px;
}

.welcome-title {
  font-size: 24px;
  font-weight: 700;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 50%, #a855f7 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  margin: 0;
  letter-spacing: 1px;
}

/* 表单样式 */
.login-form {
  margin-top: 20px;
}

.input-custom :deep(.n-input__input-el) {
  font-size: 15px;
}

.input-icon {
  color: #999;
  font-size: 18px;
}

.remember-checkbox {
  font-size: 14px;
}

/* 登录按钮 */
.login-button {
  height: 48px;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: 4px;
  border-radius: 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  box-shadow: 0 8px 24px rgba(102, 126, 234, 0.4);
  transition: all 0.3s ease;
}

.login-button:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 32px rgba(102, 126, 234, 0.5);
}

.login-button:active {
  transform: translateY(0);
}

/* 底部 */
.login-footer {
  position: absolute;
  bottom: 24px;
  text-align: center;
}

.login-footer p {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.7);
  margin: 0;
}
</style>
