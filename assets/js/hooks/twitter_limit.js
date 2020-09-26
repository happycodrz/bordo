export const TwitterLimit = {
  textAreaUpdated(event, helpText) {
    helpText.textContent = `${event.target.textLength}/280`
  },
  mounted() {
    console.log('mounted')
    const helpText = document.createElement('p')
    helpText.classList.add('mt-2', 'text-sm', 'text-gray-500')
    helpText.textContent = '0/280'
    this.el.parentNode.parentNode.appendChild(helpText)
    this.el.addEventListener('keyup', (e) => {
      this.textAreaUpdated(e, helpText)
    })
  },
  destroyed() {
    this.el.removeEventListener('keyup', this.textAreaUpdated)
  },
}
