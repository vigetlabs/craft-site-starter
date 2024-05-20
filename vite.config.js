import { defineConfig, loadEnv } from 'vite'

// Match ports in .ddev/config.yaml -> web_extra_exposed_ports
const HTTP_PORT = 3000
const HTTPS_PORT = 3001

export default defineConfig(({ command, mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  const originPort = env.PRIMARY_SITE_URL.startsWith('https')
    ? HTTPS_PORT
    : HTTP_PORT

  return {
    base: command === 'serve' ? '' : '/dist/',
    build: {
      manifest: true,
      outDir: './web/dist/',
      rollupOptions: {
        input: {
          app: 'src/js/app.js',
        },
      },
    },
    server: {
      host: '0.0.0.0',
      strictPort: true,
      port: HTTP_PORT,
      origin: env.PRIMARY_SITE_URL + ':' + originPort,
    },
  }
})
