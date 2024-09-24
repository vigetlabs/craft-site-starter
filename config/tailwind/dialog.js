import plugin from 'tailwindcss/plugin'

export default plugin(({ addComponents }) => {
  addComponents({
    '.dialog': {
      '@apply invisible opacity-0 fixed inset-24 overflow-hidden z-50 open:visible m-auto bg-white p-24 text-black dark:border dark:border-gray-500 dark:bg-gray-900 dark:text-white rounded':
        {},
      '&[open]': {
        animation:
          'dialog-in var(--dialog-transition-duration, 300ms) cubic-bezier(0.2, 0, 0.13, 1) forwards',
      },
      '&::backdrop': {
        animation:
          'dialog-backdrop-in var(--dialog-transition-duration, 300ms) cubic-bezier(0.2, 0, 0.13, 1) forwards',
        '@apply bg-black/80 backdrop-blur-sm': {},
      },
      '&[data-dialog-status="closing"]': {
        animation:
          'dialog-out var(--dialog-transition-duration, 300ms) cubic-bezier(0.2, 0, 0.13, 1) forwards',

        '&::backdrop': {
          animation:
            'dialog-backdrop-out var(--dialog-transition-duration, 300ms) cubic-bezier(0.2, 0, 0.13, 1) forwards',
        },
      },
      // Animation Keyframes
      '@keyframes dialog-in': {
        '0%': { transform: 'translateY(2rem)', opacity: 0 },
        '100%': { transform: 'translateY(0px)', opacity: 1 },
      },
      '@keyframes dialog-out': {
        '0%': { transform: 'scale(1)', opacity: 1 },
        '100%': { transform: 'scale(0.9)', opacity: 0 },
      },
      '@keyframes dialog-backdrop-in': {
        '0%': { opacity: 0 },
        '100%': { opacity: 1 },
      },
      '@keyframes dialog-backdrop-out': {
        '0%': { opacity: 1 },
        '100%': { opacity: 0 },
      },
    },
  })
})
