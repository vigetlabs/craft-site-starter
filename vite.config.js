import { defineConfig } from 'vite'
import VitePluginSvgSpritemap from '@spiriit/vite-plugin-svg-spritemap'
import process from 'node:process'

// Matches ddev web_extra_exposed_ports.https_port
const HTTPS_PORT = 3000

export default defineConfig(({ command }) => {
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
      // Matches ddev web_extra_exposed_ports.container_port
      port: 3000,
      // Strips custom ports from DDEV_PRIMARY_URL if present
      origin: `${process.env.DDEV_PRIMARY_URL?.replace(/:\d+$/, '')}:${HTTPS_PORT}`,
      allowedHosts: ['.ddev.site'],
      cors: {
        origin: /https?:\/\/([A-Za-z0-9\-.]+)?(\.ddev\.site)(?::\d+)?$/,
      },
    },
    plugins: [
      VitePluginSvgSpritemap('./src/icons/*.svg', {
        output: { name: 'spritemap.svg' },
        injectSVGOnDev: true, // Used only in dev mode for HMR
      }),
    ],
  }
})
