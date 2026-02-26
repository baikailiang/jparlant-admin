export const formatDate = (date: string | Date | undefined): string => {
  if (!date) return ''
  const d = new Date(date)
  return d.toLocaleDateString('zh-CN')
}

export const formatDateTime = (date: string | Date | undefined): string => {
  if (!date) return ''
  const d = new Date(date)
  return d.toLocaleString('zh-CN')
}

export const debounce = <T extends (...args: any[]) => any>(
  func: T,
  wait: number
): (...args: Parameters<T>) => void => {
  let timeout: NodeJS.Timeout
  return (...args: Parameters<T>) => {
    clearTimeout(timeout)
    timeout = setTimeout(() => func(...args), wait)
  }
}

export const downloadJson = (data: any, filename: string) => {
  const blob = new Blob([JSON.stringify(data, null, 2)], {
    type: 'application/json'
  })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  document.body.appendChild(a)
  a.click()
  document.body.removeChild(a)
  URL.revokeObjectURL(url)
}

export const parseJson = (jsonStr: string): any => {
  try {
    return JSON.parse(jsonStr)
  } catch {
    return null
  }
}

export const validateEmail = (email: string): boolean => {
  const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  return re.test(email)
}

export const generateId = (): string => {
  return Math.random().toString(36).substr(2, 9)
}