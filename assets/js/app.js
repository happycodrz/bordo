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
import { Canva } from './hooks/canva'
import { DatePicker } from './hooks/date_picker'
import { InitModal } from './hooks/modal'
import { ScrollLock } from './hooks/scroll_lock'
import { Toast } from './hooks/toast'
import { TwitterLimit } from './hooks/twitter_limit'
import { UploadMedia } from './hooks/upload_media'
import { initSlideOver } from './hooks/slide_over'

// App
import Shortcuts from './shortcuts'

let Hooks = {}

Hooks = {
  ...Hooks,
  Canva,
  DatePicker,
  InitModal,
  ScrollLock,
  Toast,
  UploadMedia,
  initSlideOver,
  TwitterLimit,
}

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

document.addEventListener('DOMContentLoaded', () => {
  const element = document.querySelector('.js-choice')
  if (element) {
    new Choices(element, {
      searchEnabled: true,
    })
  }
  Shortcuts.Init()
})
