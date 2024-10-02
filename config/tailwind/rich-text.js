import plugin from 'tailwindcss/plugin'

export default plugin(({ addComponents }) => {
  const richText = {
    '.rich-text': {
      '& strong, & b': {
        '@apply font-semibold': {},
      },
      '& p': {
        '@apply mb-16': {},
      },
      '& a': {
        '@apply text-sky-600 underline': {},
      },
      '& ol, & ul': {
        '@apply mt-20 mb-20 pl-20': {},
      },
      '& ol': {
        '@apply list-decimal': {},
      },
      '& ul': {
        '@apply list-disc': {},
      },
      '& li, & li > ol, & li > ul': {
        '@apply mt-8 mb-8': {},
      },
      '& blockquote': {
        '@apply italic text-lg border-l-2 border-sky-600 pl-16': {},
      },
      // Separate rich text classes let us adjust sizes without migrating existing content
      '& .rich-text-size-xlarge': {
        '@apply text-2xl': {},
      },
      '& .rich-text-size-large': {
        '@apply text-xl': {},
      },
      '& .rich-text-size-medium': {
        '@apply text-lg': {},
      },
      '& .rich-text-size-small': {
        '@apply text-sm': {},
      },
    },
  }

  addComponents(richText)
})
