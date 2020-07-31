export const Toast = {
  mounted() {
    const handleToast = (event) => {
      if (event.detail.open === true) {
        this.el.removeEventListener('toast-change', handleToast)
      }
    }
    this.el.addEventListener('toast-change', handleToast)
  },
}
