import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import { resolve } from 'path'
import http from 'http'
import https from 'https'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    vue(),
    {
      name: 'metadata-api-proxy',
      configureServer(server) {
        server.middlewares.use('/metadata-api', (req, res) => {
          const targetUrl = req.headers['x-target-url'] as string
          if (!targetUrl) {
            res.statusCode = 400
            res.end(JSON.stringify({ code: 400, message: '未配置业务处理器服务地址' }))
            return
          }

          try {
            const targetUrlObj = new URL(targetUrl)
            const path = req.url || '/'

            const options: http.RequestOptions = {
              hostname: targetUrlObj.hostname,
              port: targetUrlObj.port || (targetUrlObj.protocol === 'https:' ? 443 : 80),
              path: path,
              method: req.method,
              headers: {
                ...req.headers,
                host: targetUrlObj.host
              }
            }

            delete options.headers!['x-target-url']

            const proxyReq = (targetUrlObj.protocol === 'https:' ? https : http).request(options, (proxyRes) => {
              res.writeHead(proxyRes.statusCode || 500, proxyRes.headers)
              proxyRes.pipe(res)
            })

            proxyReq.on('error', (err) => {
              res.statusCode = 502
              res.end(JSON.stringify({ code: 502, message: '代理请求失败: ' + err.message }))
            })

            req.pipe(proxyReq)
          } catch (e: any) {
            res.statusCode = 400
            res.end(JSON.stringify({ code: 400, message: '无效的服务地址: ' + e.message }))
          }
        })
      }
    }
  ],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },
  server: {
    port: 3000,
    proxy: {
      '/api': {
        target: 'http://localhost:9085',
        changeOrigin: true,
        // rewrite: (path) => path.replace(/^\/api/, '')
      },
      '/customerAgent': {
        target: 'http://localhost:18700',
        changeOrigin: true
      }
    }
  }
})