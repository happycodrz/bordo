export const initSlideOver = {
  mounted() {
    const handleOpenCloseEvent = (event) => {
      if (event.detail.open === false) {
        this.el.removeEventListener('slideover-change', handleOpenCloseEvent)

        setTimeout(() => {
          this.pushEventTo(event.detail.id, 'close-slideover', {})
        }, 300)
      }
    }
    this.el.addEventListener('slideover-change', handleOpenCloseEvent)
  },
}
