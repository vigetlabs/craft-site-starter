import '../css/app.css'

import Alpine from 'alpinejs'
import focus from '@alpinejs/focus'
import collapse from '@alpinejs/collapse'
import nav from './alpine/nav'

Alpine.plugin(focus)
Alpine.plugin(collapse)

// @ts-ignore
window.Alpine = Alpine

Alpine.data('nav', nav)
Alpine.start()
