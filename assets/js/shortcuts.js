import { InitModal } from './hooks/modal';

const Mousetrap = require('mousetrap')

const Shortcuts = {
  Init: () => {
    Mousetrap.bind('c', OpenModal);
  }
}

const OpenModal = () => {
  // click button, or send push-event
  const NewPostButton = document.getElementById('post-slideover-button')
  const ModalContainer = document.getElementById('new-post')
  if (ModalContainer && ModalContainer.children.length < 1) {
    NewPostButton.click()
  }
}

export default Shortcuts
