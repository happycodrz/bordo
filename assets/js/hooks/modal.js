export const initModal = {
  mounted() {
    const handleOpenCloseEvent = (event) => {
      if (event.detail.open === false) {
        this.el.removeEventListener('modal-change', handleOpenCloseEvent)
        this.pushEvent('close-modal', { id: this.el.id })
      }
    }
    this.el.addEventListener('modal-change', handleOpenCloseEvent)
  },
}

export const closeModal = {
  mounted() {
    const modalId = this.el.dataset.modalId
    const el = document.getElementById(modalId)
    const event = new CustomEvent('close-modal')
    el.dispatchEvent(event)
  },
}
