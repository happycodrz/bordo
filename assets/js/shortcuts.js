import { InitModal } from './hooks/modal';

const Mousetrap = require('mousetrap')

const Shortcuts = {
  Init: () => {
    Mousetrap.bind('c', OpenModal);
  }
}

const OpenModal = () => {
  // click button, or send push-event
  const NewPostButton = document.getElementById('compose-button')
  if (window.location.href.indexOf("composer") < 0) {
    NewPostButton.click()
  }
}

export default Shortcuts
