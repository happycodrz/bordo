export const InitModal = {
  mounted() {
    const handleOpenCloseEvent = (event) => {
      if (event.detail.open === false) {
        this.el.removeEventListener('modal-change', handleOpenCloseEvent)
        this.pushEvent('close-modal', { id: this.el.id })
        setTimeout(() => {
          this.pushEventTo(event.detail.id, 'close', {})
        }, 300)
      }
    }
    this.el.addEventListener('modal-change', handleOpenCloseEvent)
  },
}
