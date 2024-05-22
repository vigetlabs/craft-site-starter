import eslintConfigPrettier from 'eslint-config-prettier'
import js from '@eslint/js'
import globals from 'globals'

export default [
  js.configs.recommended,
  eslintConfigPrettier,

  {
    rules: {
      'no-console': ['error', { allow: ['warn', 'error'] }],
    },
    languageOptions: {
      globals: {
        ...globals.browser,
      },
    },
  },
]
