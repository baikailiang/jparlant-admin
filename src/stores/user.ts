import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

const TOKEN_KEY = 'jparlant_token'
const USER_KEY = 'jparlant_user'

export interface UserInfo {
  id: number
  username: string
  nickname?: string
  avatar?: string
}

export const useUserStore = defineStore('user', () => {
  // State
  const token = ref<string | null>(localStorage.getItem(TOKEN_KEY))
  const userInfo = ref<UserInfo | null>(null)

  // 初始化时从 localStorage 读取用户信息
  const storedUser = localStorage.getItem(USER_KEY)
  if (storedUser) {
    try {
      userInfo.value = JSON.parse(storedUser)
    } catch {
      userInfo.value = null
    }
  }

  // Getters
  const isLoggedIn = computed(() => !!token.value)

  // Actions
  const setToken = (newToken: string) => {
    token.value = newToken
    localStorage.setItem(TOKEN_KEY, newToken)
  }

  const setUserInfo = (info: UserInfo) => {
    userInfo.value = info
    localStorage.setItem(USER_KEY, JSON.stringify(info))
  }

  const logout = () => {
    token.value = null
    userInfo.value = null
    localStorage.removeItem(TOKEN_KEY)
    localStorage.removeItem(USER_KEY)
  }

  const getToken = () => token.value

  return {
    token,
    userInfo,
    isLoggedIn,
    setToken,
    setUserInfo,
    logout,
    getToken
  }
})
