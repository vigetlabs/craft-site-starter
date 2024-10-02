import plugin from 'tailwindcss/plugin'

/**
 * Provides a container class for content that should be centered and constrained to the sites max width.
 * Could optionally expand this to use CSS grid for advanced layouts & breakouts.
 *
 * @see https://www.viget.com/articles/fluid-breakout-layout-css-grid/
 */
export default plugin(({ addComponents }) => {
  const container = {
    '.container': {
      '@apply max-w-[1240px] px-16 mx-auto sm:px-32': {},
    },
  }

  addComponents(container)
})
