<template>
  <div class="chat-wrapper h-screen flex flex-col bg-[#fcfcfd] dark:bg-[#050505] text-[#1a1a1a] dark:text-[#ededed]">

    <!-- Header -->
    <header class="pt-8 pb-4 px-8 flex-shrink-0">
      <div class="max-w-4xl mx-auto flex items-end justify-between">
        <div class="flex items-center gap-6">
          <n-button
            @click="router.push(`/agents/${agentId}/intents`)"
            quaternary circle size="large"
            class="!text-zinc-400 hover:!text-zinc-900 dark:hover:!text-white"
          >
            <template #icon>
              <n-icon size="28"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M15 18l-6-6l6-6"/></svg></n-icon>
            </template>
          </n-button>
          <h1 class="text-3xl font-black tracking-tight dark:text-white">对话助手</h1>
        </div>

        <n-button @click="handleClearChat" quaternary circle size="large">
          <template #icon>
            <n-icon size="22" class="text-zinc-300 hover:text-red-500">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7M10 11v6M14 11v6M9 7V4a1 1 0 011-1h4a1 1 0 011 1v3M4 7h16"/></svg>
            </n-icon>
          </template>
        </n-button>
      </div>
    </header>

    <!-- Main：消息展示 -->
    <main ref="chatContainer" class="flex-1 overflow-y-auto px-6 py-4 scroll-smooth custom-scrollbar">
      <div class="max-w-4xl mx-auto space-y-8 pb-10">
        <div
          v-for="(message, index) in messages"
          :key="index"
          class="flex w-full animate-in"
          :class="message.role === 'user' ? 'justify-end' : 'justify-start'"
        >
          <div class="flex flex-col max-w-[90%]" :class="message.role === 'user' ? 'items-end' : 'items-start'">
            <div
              class="px-5 py-3 text-base leading-relaxed shadow-sm transition-all overflow-hidden"
              :class="message.role === 'user'
                ? 'bg-[#007aff] text-white rounded-[22px] rounded-br-[4px]'
                : 'bg-white dark:bg-[#1c1c1e] text-[#1a1a1a] dark:text-[#ededed] rounded-[22px] rounded-bl-[4px] border border-zinc-100 dark:border-zinc-800'"
            >
              <!-- 消息中的图片展示 -->
              <div v-if="message.images && message.images.length" class="mb-2 flex flex-wrap gap-2 justify-end">
                <n-image-group>
                  <n-image
                    v-for="(img, i) in message.images"
                    :key="i"
                    :src="img"
                    width="120"
                    class="rounded-lg shadow-sm border border-black/10 dark:border-white/10"
                    show-toolbar-tooltip
                  />
                </n-image-group>
              </div>

              <!-- AI 回复：渲染 Markdown -->
              <div 
                v-if="message.role === 'assistant'" 
                class="markdown-body prose dark:prose-invert max-w-none"
                v-html="md.render(message.content)"
              ></div>
              
              <!-- 用户文本 -->
              <div v-else-if="message.content" class="whitespace-pre-wrap break-words font-medium">
                {{ message.content }}
              </div>
            </div>
            <span class="text-[10px] text-zinc-400 mt-2 font-bold uppercase tracking-wider px-1">
              {{ formatTime(message.timestamp) }}
            </span>
          </div>
        </div>

        <!-- 正在输入状态 -->
        <div v-if="isStreaming" class="flex justify-start">
          <div class="bg-white dark:bg-[#1c1c1e] px-5 py-4 rounded-2xl border border-zinc-100 dark:border-zinc-800 shadow-sm">
            <n-spin size="small" />
          </div>
        </div>
      </div>
    </main>

    <!-- Footer：输入控制区域 -->
    <footer class="flex-shrink-0 px-6 pb-10">
      <div class="max-w-3xl mx-auto">
        <div class="bg-white dark:bg-[#1c1c1e] rounded-[28px] shadow-[0_12px_40px_rgba(0,0,0,0.08)] border border-zinc-100 dark:border-zinc-800 transition-all focus-within:ring-2 focus-within:ring-blue-500/10 overflow-hidden">
          
          <!-- 图片待上传预览 (TransitionGroup) -->
          <TransitionGroup 
            tag="div" name="list"
            v-if="uploadedImages.length" 
            class="flex gap-3 p-4 bg-zinc-50/50 dark:bg-black/20 border-b border-zinc-50 dark:border-zinc-800"
          >
            <div v-for="(img, i) in uploadedImages" :key="img.id" class="relative group">
              <img :src="img.url" class="w-20 h-20 rounded-xl object-cover border border-white dark:border-zinc-700 shadow-sm" />
              <button
                class="absolute -top-2 -right-2 bg-zinc-900 dark:bg-zinc-100 text-white dark:text-zinc-900 rounded-full w-6 h-6 flex items-center justify-center shadow-lg hover:scale-110 transition-transform z-10"
                @click="removeImage(i)"
              >
                <n-icon size="14">✕</n-icon>
              </button>
            </div>
          </TransitionGroup>

          <!-- 输入行 -->
          <div class="flex items-end p-3 gap-3">
            <div class="flex-shrink-0">
              <n-upload
                multiple :max="4" accept="image/*" :show-file-list="false"
                :file-list="tempFileList" @update:file-list="handleFileChange"
              >
                <n-button quaternary circle size="large" class="!bg-zinc-50 dark:!bg-zinc-800" :disabled="uploadedImages.length >= 4 || isStreaming">
                  <template #icon><n-icon size="24"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg></n-icon></template>
                </n-button>
              </n-upload>
            </div>

            <div class="flex-1 min-w-0">
              <n-input
                ref="inputRef"
                v-model:value="userInput"
                type="textarea"
                :autosize="{ minRows: 1, maxRows: 8 }"
                placeholder="键入消息..."
                @keydown.enter.exact.prevent="handleSendMessage"
                class="modern-input"
                :disabled="isStreaming"
              />
            </div>

            <div class="flex-shrink-0">
              <n-button
                type="primary" circle size="large"
                :disabled="!canSend" :loading="isStreaming" @click="handleSendMessage"
                class="!bg-[#007aff] !shadow-md"
              >
                <template #icon><n-icon size="20"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z"/></svg></n-icon></template>
              </n-button>
            </div>
          </div>
        </div>
        <div class="mt-3 px-2 flex justify-between text-[10px] text-zinc-400 font-bold uppercase tracking-widest">
          <span :class="{'text-orange-500': uploadedImages.length >= 4}">图片附件: {{ uploadedImages.length }} / 4</span>
          <span>Shift + Enter 换行</span>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, nextTick, onMounted, onUnmounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useMessage, NButton, NIcon, NInput, NUpload, NSpin, NImage, NImageGroup, type UploadFileInfo } from 'naive-ui'
import { chatApi } from '@/api'
import markdownIt from 'markdown-it'
import highlightjs from 'highlight.js'
import 'highlight.js/styles/github.css'

const md = markdownIt({
  html: true, linkify: true, typographer: true,
  highlight: (str, lang) => {
    if (lang && highlightjs.getLanguage(lang)) {
      try { return highlightjs.highlight(str, { language: lang }).value; } catch (__) {}
    }
    return '';
  }
});

const route = useRoute()
const router = useRouter()
const message = useMessage()
const agentId = computed(() => Number(route.params.agentId))
const intentId = computed(() => Number(route.params.intentId))

const messages = ref<any[]>([])
const userInput = ref('')
const isStreaming = ref(false)
const chatContainer = ref<HTMLElement>()
const inputRef = ref()

// 图片状态
interface UploadedImage { id: string; file: File; url: string; }
const uploadedImages = ref<UploadedImage[]>([])
const tempFileList = ref<UploadFileInfo[]>([])

const canSend = computed(() => (userInput.value && userInput.value.trim()) || uploadedImages.value.length)
const formatTime = (d: Date) => d.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit' })

const handleFileChange = (fileList: UploadFileInfo[]) => {
  const limitedList = fileList.slice(0, 4)
  tempFileList.value = limitedList
  const newUploadedImages: UploadedImage[] = []

  limitedList.forEach(fileInfo => {
    const existing = uploadedImages.value.find(img => img.id === fileInfo.id)
    if (existing) {
      newUploadedImages.push(existing)
    } else if (fileInfo.file) {
      newUploadedImages.push({
        id: fileInfo.id,
        file: fileInfo.file,
        url: URL.createObjectURL(fileInfo.file)
      })
    }
  })
  // 释放被移除图片的URL
  uploadedImages.value.forEach(oldImg => {
    if (!newUploadedImages.find(newImg => newImg.id === oldImg.id)) URL.revokeObjectURL(oldImg.url)
  })
  uploadedImages.value = newUploadedImages
}

const removeImage = (index: number) => {
  URL.revokeObjectURL(uploadedImages.value[index].url)
  uploadedImages.value.splice(index, 1)
  tempFileList.value.splice(index, 1)
}

const scrollToBottom = () => {
  nextTick(() => {
    chatContainer.value?.scrollTo({ top: chatContainer.value.scrollHeight, behavior: 'smooth' })
  })
}

const handleSendMessage = async () => {
  if (!canSend.value) return
  
  const content = userInput.value.trim()
  // 关键：克隆当前的图片URL数组到消息历史中
  const currentImageUrls = uploadedImages.value.map(img => img.url)
  const currentFiles = uploadedImages.value.map(img => img.file)
  
  // 将图片信息存入消息记录
  messages.value.push({ 
    role: 'user', 
    content: content, 
    images: currentImageUrls, // 这里保存了预览地址
    timestamp: new Date() 
  })
  
  userInput.value = ''
  // 注意：这里不要 revokeObjectURL，因为消息列表中还要用。
  // 我们只清空待发送队列的引用，ObjectUrls 的释放统一交由 handleClearChat 或 onUnmounted。
  uploadedImages.value = []
  tempFileList.value = []
  scrollToBottom()

  isStreaming.value = true
  try {
    let assistantMessage = ''
    const messageIndex = messages.value.length
    await chatApi.streamChat(intentId.value, content, currentFiles, (chunk) => {
      assistantMessage += chunk
      if (messages.value.length > messageIndex) {
        messages.value[messageIndex] = { role: 'assistant', content: assistantMessage, timestamp: new Date() }
      } else {
        messages.value.push({ role: 'assistant', content: assistantMessage, timestamp: new Date() })
      }
      scrollToBottom()
    })
  } catch (e) {
    message.error('发送失败')
  } finally {
    isStreaming.value = false
    scrollToBottom()
  }
}

const handleClearChat = () => {
  // 释放所有消息中占用的 URL 资源
  messages.value.forEach(msg => {
    if (msg.images) msg.images.forEach((url: string) => URL.revokeObjectURL(url))
  })
  messages.value = []
}

onMounted(() => nextTick(() => inputRef.value?.focus()))
onUnmounted(() => {
  // 彻底释放内存
  handleClearChat()
  uploadedImages.value.forEach(img => URL.revokeObjectURL(img.url))
})
</script>

<style scoped>
.markdown-body { font-size: 15px; line-height: 1.6; }
:deep(.markdown-body p) { margin-bottom: 0.8em; }
:deep(.markdown-body p:last-child) { margin-bottom: 0; }
:deep(.markdown-body code) {
  background-color: rgba(175, 184, 193, 0.2);
  padding: 0.2em 0.4em; border-radius: 6px; font-size: 85%;
}
:deep(.markdown-body pre) {
  background-color: #f6f8fa; padding: 16px; border-radius: 12px; overflow: auto; margin: 12px 0;
}
.dark :deep(.markdown-body pre) { background-color: #0d1117; }

/* 输入框 */
:deep(.modern-input.n-input) {
  --n-border: none !important;
  --n-border-hover: none !important;
  --n-border-focus: none !important;
  --n-box-shadow-focus: none !important;
  --n-color: transparent !important;
  --n-color-focus: transparent !important;
  background-color: transparent !important;
  font-size: 16px !important;
  width: 100% !important;
}

/* 消息动画 */
.animate-in { animation: message-in 0.4s cubic-bezier(0.16, 1, 0.3, 1) forwards; }
@keyframes message-in {
  from { opacity: 0; transform: translateY(12px) scale(0.98); }
  to { opacity: 1; transform: translateY(0) scale(1); }
}

.custom-scrollbar::-webkit-scrollbar { width: 4px; }
.custom-scrollbar::-webkit-scrollbar-thumb { background: #e4e4e7; border-radius: 10px; }
.dark .custom-scrollbar::-webkit-scrollbar-thumb { background: #27272a; }

.list-enter-active, .list-leave-active { transition: all 0.3s ease; }
.list-enter-from, .list-leave-to { opacity: 0; transform: translateY(10px); }
</style>