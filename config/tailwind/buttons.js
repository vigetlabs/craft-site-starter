import plugin from 'tailwindcss/plugin'

export default plugin(({ addComponents }) => {
  // Base Styles
  const base = {
    // core
    '@apply inline-flex items-center justify-center rounded font-bold transition text-base gap-12 cursor-pointer no-underline':
      {},
    // focus
    '@apply focus:outline-none focus-visible:ring-4': {},
    // disabled
    '@apply disabled:opacity-20 disabled:pointer-events-none': {},
    // icon
    '& svg': {
      '@apply size-20': {},
    },
    // text exempt
    '&:not(.btn-text)': {
      '@apply px-20 min-h-40': {},
    },
  }

  const buttons = {
    // Button Variants
    '.btn-contained': {
      ...base,
      [`@apply
        bg-sky-600 text-white
        hover:bg-sky-700
        active:bg-sky-800
        focus-visible:bg-sky-700 focus-visible:ring-sky-600/50
        dark:bg-sky-200 dark:text-sky-800
        dark:hover:bg-sky-50
        dark:active:bg-sky-100
        dark:focus-visible:bg-sky-50 dark:focus-visible:ring-white/50`]: {},
    },

    '.btn-outlined': {
      ...base,
      [`@apply
        border border-sky-600 bg-transparent text-sky-600
        hover:bg-sky-100 hover:border-sky-700 hover:text-sky-700
        active:bg-sky-200/80 active:text-sky-800
        focus-visible:bg-sky-100 focus-visible:border-sky-700 focus-visible:ring-sky-600/50
        dark:border-white dark:text-white
        dark:hover:bg-white/25
        dark:active:bg-white/30
        dark:focus-visible:bg-sky-100/30 dark:focus-visible:ring-white/50`]: {},
    },

    '.btn-subtle': {
      ...base,
      [`@apply
        bg-transparent bg-transparent text-sky-600
        hover:bg-sky-100 hover:text-sky-700
        active:bg-sky-200/80 active:text-sky-800
        focus-visible:bg-sky-100 focus-visible:border-sky-700 focus-visible:ring-sky-600/50
        dark:text-white
        dark:hover:bg-white/25
        dark:active:bg-white/30
        dark:focus-visible:bg-sky-100/30 dark:focus-visible:ring-white/75`]: {},
    },

    '.btn-text': {
      ...base,
      [`@apply
        bg-transparent text-sky-600
        hover:text-sky-700 hover:underline
        active:text-sky-800
        focus-visible:bg-sky-100 focus-visible:ring-sky-600/50
        dark:border-white dark:text-white
        dark:hover:text-white/90
        dark:active:text-white/80
        dark:focus-visible:bg-sky-100/30  dark:focus-visible:ring-white/75`]:
        {},
    },

    // Button Sizes
    '.btn-sm': {
      '@apply text-sm gap-8': {},
      '& svg': {
        '@apply size-16': {},
      },
      '&:not(.btn-text)': {
        '@apply px-16 min-h-32': {},
      },
    },
    '.btn-lg': {
      '@apply text-xl gap-12': {},
      '& svg': {
        '@apply size-24': {},
      },
      '&:not(.btn-text)': {
        '@apply px-32 min-h-56': {},
      },
    },

    // Button Icon/Sizes
    '.btn-icon': {
      fontSize: '0 !important',
      lineHeight: '0 !important',
      '@apply !p-0 !gap-0 aspect-square justify-center items-center': {},
    },
  }

  addComponents(buttons)
})
