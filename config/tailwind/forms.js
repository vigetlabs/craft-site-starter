import plugin from 'tailwindcss/plugin'

export default plugin(({ addComponents }) => {
  // Base styles
  const inputs = {
    '.field-group': {
      '@apply flex flex-col gap-8': {},
      // label container
      '& label': {
        '@apply flex flex-col [&:has(.sr-only:last-child)]:sr-only': {},
      },
      // label
      '& .field-label': {
        '@apply text-gray-900 dark:text-white': {},
      },
      // sublabel & instructions
      '& .field-sublabel, & .field-instructions': {
        '@apply text-sm text-gray-700 dark:text-gray-300': {},
      },
      // core field styles
      '& input[type="text"], & input[type="password"], & input[type="email"], & input[type="number"], & input[type="tel"], & input[type="url"], & select, & textarea':
        {
          // base styles
          '@apply rounded-sm border-0 bg-white ring-1 outline-none ring-black/50 px-8 dark:bg-white/10 dark:text-white dark:ring-white/50':
            {},
          // placeholder styles
          '@apply placeholder:text-black/40 dark:placeholder:text-white/50': {},
          // hover styles
          '@apply hover:ring-black/75 dark:hover:ring-white/75': {},
          // focus styles
          '@apply focus:ring-blue-500 focus:ring-2 dark:focus:ring-white/75':
            {},
          // disabled styles
          '@apply disabled:bg-gray-500/10 disabled:ring-gray-500/20 disabled:text-black/75 disabled:cursor-not-allowed dark:disabled:ring-white/20 dark:disabled:bg-white/25 dark:disabled:text-white/50 dark:disabled:placeholder:text-white/35':
            {},
          // Exclude textarea from fix height
          '&:not(textarea)': {
            '@apply h-40': {},
          },
          '&:is(input[type="checkbox"])': {
            '@apply size-20 border-0 text-blue-500 checked:bg-blue-500 min-h-0':
              {},
          },
          '&:is([aria-invalid="true"])': {
            '@apply ring-red-600 hover:ring-red-700 focus:ring-red-600 dark:ring-red-300 dark:hover:ring-red-400 dark:focus:ring-red-300':
              {},
          },
        },
      // field specific styles
      '& textarea': {
        '@apply py-8': {},
      },
      '& select': {
        backgroundImage: `url("data:image/svg+xml, %3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath fill='%23000000' d='M12 5.83 15.17 9l1.41-1.41L12 3 7.41 7.59 8.83 9 12 5.83zm0 12.34L8.83 15l-1.41 1.41L12 21l4.59-4.59L15.17 15 12 18.17z'/%3E%3C/svg%3E")`,
        backgroundPosition: 'right .5rem center',
        backgroundSize: '1rem',
        backgroundRepeat: 'no-repeat',
        '@apply appearance-none pr-32': {},

        '.dark &': {
          backgroundImage: `url("data:image/svg+xml, %3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath fill='%23ffffff' d='M12 5.83 15.17 9l1.41-1.41L12 3 7.41 7.59 8.83 9 12 5.83zm0 12.34L8.83 15l-1.41 1.41L12 21l4.59-4.59L15.17 15 12 18.17z'/%3E%3C/svg%3E")`,
        },
        '& option': {
          '@apply text-black': {},
        },
      },
      // required field styles
      '&[data-required] label .field-label::after': {
        '@apply content-["*"] text-red-600 align-super text-xs ml-2 font-medium dark:text-red-300':
          {},
      },
      '&[data-required="long"] label .field-label::after': {
        '@apply content-["*Required"]': {},
      },
      // error message styles
      '.field-errors': {
        '@apply relative text-red-600 text-sm font-medium flex gap-10 flex-col pl-20 list-none dark:text-red-300':
          {},
      },
    },
  }

  addComponents(inputs)
})
