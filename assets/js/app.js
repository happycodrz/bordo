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

// Hooks
import LiveReact, { initLiveReact } from 'phoenix_live_react'
import { initModal, closeModal } from './hooks/modal'
import { initSlideOver } from './hooks/slide_over'

const feather = require('feather-icons')

let Hooks = {}
Hooks.LiveReact = LiveReact
Hooks.FeatherIcon = {
  mounted() {
    feather.replace()
  },
}

Hooks = { ...Hooks, initModal, closeModal, initSlideOver }

import Choices from 'choices.js'
let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute('content')
let liveSocket = new LiveSocket('/live', Socket, {
  hooks: Hooks,
  dom: {
    onBeforeElUpdated(from, to) {
      if (from.__x) {
        window.Alpine.clone(from.__x, to)
      }
    },
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

import SidebarNewPostButton from './react/components/SidebarNewPostButton'
import Media from './react/components/Media'
import ScheduleCalendar from './react/components/ScheduleCalendar'
import Settings from './react/components/Settings'

window.Components = {
  SidebarNewPostButton,
  Media,
  ScheduleCalendar,
  Settings,
}

document.addEventListener('DOMContentLoaded', () => {
  feather.replace({ width: '1em', height: '1em' })
  initLiveReact()
  const element = document.querySelector('.js-choice')
  if (element) {
    new Choices(element, {
      searchEnabled: true,
    })
  }
  feather.replace()
})
