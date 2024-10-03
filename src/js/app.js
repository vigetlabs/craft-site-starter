import '../css/app.css'

import Alpine from 'alpinejs'
import focus from '@alpinejs/focus'
import nav from './alpine/nav'

Alpine.plugin(focus)

// @ts-ignore
window.Alpine = Alpine

Alpine.data('nav', nav)
Alpine.start()
