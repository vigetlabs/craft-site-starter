export default {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
    'postcss-pxtorem': {
      rootValue: 16,
      unitPrecision: 5,
      propList: ['*'],
      selectorBlackList: [],
      replace: true,
      mediaQuery: true,
      minPixelValue: 1,
      exclude: /node_modules/i
    },
    ...(process.env.NODE_ENV === 'production' ? { cssnano: {} } : {})
  }
}
