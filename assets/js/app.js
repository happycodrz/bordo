// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import '../css/app.css'

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import 'phoenix_html'
import 'alpinejs'
import { Socket } from 'phoenix'
import NProgress from 'nprogress'
import { LiveSocket } from 'phoenix_live_view'
import LiveReact, { initLiveReact } from 'phoenix_live_react'
const feather = require('feather-icons')

let Hooks = {}
Hooks.LiveReact = LiveReact
Hooks.FeatherIcon = {
  mounted() {
    feather.replace()
  },
}
Hooks.ScrollLock = {
  mounted() {
    this.lockScroll()
  },
  destroyed() {
    this.unlockScroll()
  },
  lockScroll() {
    // From https://github.com/excid3/tailwindcss-stimulus-components/blob/master/src/modal.js
    // Add right padding to the body so the page doesn't shift when we disable scrolling
    const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth
    document.body.style.paddingRight = `${scrollbarWidth}px`
    // Save the scroll position
    this.scrollPosition = window.pageYOffset || document.body.scrollTop
    // Add classes to body to fix its position
    document.body.classList.add('fix-position')
    // Add negative top position in order for body to stay in place
    document.body.style.top = `-${this.scrollPosition}px`
  },
  unlockScroll() {
    // From https://github.com/excid3/tailwindcss-stimulus-components/blob/master/src/modal.js
    // Remove tweaks for scrollbar
    document.body.style.paddingRight = null
    // Remove classes from body to unfix position
    document.body.classList.remove('fix-position')
    // Restore the scroll position of the body before it got locked
    document.documentElement.scrollTop = this.scrollPosition
    // Remove the negative top inline style from body
    document.body.style.top = null
  },
}

import Choices from 'choices.js'
let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute('content')
let liveSocket = new LiveSocket('/live', Socket, {
  hooks: Hooks,
  dom: {
    onBeforeElUpdated(from, to){
      if(from.__x){ window.Alpine.clone(from.__x, to) }
    }
  },
  params: { _csrf_token: csrfToken },
})

// Show progress bar on live navigation and form submits
window.addEventListener('phx:page-loading-start', (info) => NProgress.start())
window.addEventListener('phx:page-loading-stop', (info) => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
window.liveSocket = liveSocket

import BrandSidebarBody from './react/components/BrandSidebarBody'
import Media from './react/components/Media'
import ScheduleCalendar from './react/components/ScheduleCalendar'
import Settings from './react/components/Settings'
import Launchpad from './react/components/Launchpad'

window.Components = {
  BrandSidebarBody,
  Launchpad,
  Media,
  ScheduleCalendar,
  Settings
}

document.addEventListener('DOMContentLoaded', () => {
  feather.replace({width: '1em', height: '1em'})
  initLiveReact()
  const element = document.querySelector('.js-choice')
  if (element) {
    new Choices(element, {
      searchEnabled: true,
    })
  }
  feather.replace()
})
