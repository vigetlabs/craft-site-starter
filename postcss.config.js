export default {
    plugins: {
        tailwindcss: {},
        autoprefixer: {},
        'postcss-pxtorem': {
            rootValue: 16,
            unitPrecision: 5,
            propList: [
                'font',
                'font-size',
                'line-height',
                'letter-spacing',
                'border*',
                'background*',
                'grid*',
                'top',
                'left',
                'bottom',
                'right',
                'inset',
                'width',
                'height',
                'margin*',
                'padding*',
                'max-*',
                'min-*',
                'gap*',
            ],
            selectorBlackList: [],
            replace: true,
            mediaQuery: true,
            minPixelValue: 0,
            exclude: /node_modules/i,
        }
    }
}