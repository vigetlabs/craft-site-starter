import buttons from './config/tailwind/buttons'
import dialog from './config/tailwind/dialog'
import richText from './config/tailwind/rich-text'

/**
 Helper function to pair key and value together

 Note: PostCSS Converts all `px` values to `rem`
 */
function pxPair(value) {
  return { [value]: `${value}px` }
}

/** @type {import('tailwindcss').Config} */
export default {
  content: ['./templates/**/*.{twig,html}', './src/**/*.{js,jsx,ts,tsx,svg}'],
  theme: {
    spacing: {
      ...pxPair(0),
      ...pxPair(1),
      ...pxPair(2),
      ...pxPair(4),
      ...pxPair(6),
      ...pxPair(8),
      ...pxPair(10),
      ...pxPair(12),
      ...pxPair(16),
      ...pxPair(20),
      ...pxPair(24),
      ...pxPair(28),
      ...pxPair(32),
      ...pxPair(36),
      ...pxPair(40),
      ...pxPair(44),
      ...pxPair(48),
      ...pxPair(52),
      ...pxPair(56),
      ...pxPair(60),
      ...pxPair(64),
      ...pxPair(80),
      ...pxPair(96),
      ...pxPair(112),
      ...pxPair(128),
    },
    extend: {
      maxWidth: {
        content: '1440px',
      },
    },
  },
  plugins: [buttons, dialog, richText],
}
