import process from 'process'

export default {
  plugins: {
    '@tailwindcss/postcss': {},
    'postcss-pxtorem': {
      rootValue: 16,
      unitPrecision: 5,
      // rounded-*-full utilities emit 3.40282e38px; pxtorem would rewrite the exponent's 38px
      propList: ['*', '!*radius*'],
      selectorBlackList: [],
      replace: true,
      mediaQuery: true,
      minPixelValue: 2,
      exclude: /node_modules/i,
    },
    ...(process.env.NODE_ENV === 'production' ? { cssnano: {} } : {}),
  },
}
