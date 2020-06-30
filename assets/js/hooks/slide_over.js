export const initSlideOver = {
  mounted() {
    const handleOpenCloseEvent = (event) => {
      if (event.detail.open === false) {
        this.el.removeEventListener('slideover-change', handleOpenCloseEvent)
        this.pushEvent('close-slideover', { id: this.el.id })
      }
    }
    this.el.addEventListener('slideover-change', handleOpenCloseEvent)
  },
}
