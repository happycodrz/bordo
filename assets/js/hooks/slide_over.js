export const initSlideOver = {
  mounted() {
    const handleOpenCloseEvent = (event) => {
      if (event.detail.open === false) {
        this.el.removeEventListener('slideover-change', handleOpenCloseEvent)
        setTimeout(() => {
          this.pushEvent('close-slideover', { id: this.el.id })
        }, 300)
      }
    }
    this.el.addEventListener('slideover-change', handleOpenCloseEvent)
  },
}
