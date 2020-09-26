export const TwitterLimit = {
  textAreaUpdated(event, helpText) {
    const textArea = event.target
    helpText.textContent = this.contentLength(textArea)
    if (textArea.textLength > 280) {
      helpText.classList = 'mt-2 text-sm text-red-500'
    } else if (textArea.textLength > 240) {
      helpText.classList = 'mt-2 text-sm text-yellow-500'
    } else {
      helpText.classList = 'mt-2 text-sm text-gray-500'
    }
  },
  contentLength(textAreaNode) {
    return `${textAreaNode.textLength}/280`
  },
  mounted() {
    const contentInput = document.querySelector('[data-content-count="Twitter"]')
    this.el.textContent = this.contentLength(contentInput)
    this.el.classList = 'mt-2 text-sm text-gray-500'
    contentInput.addEventListener('input', (e) => {
      this.textAreaUpdated(e, this.el)
    })
  },
  destroyed() {
    this.el.removeEventListener('input', this.textAreaUpdated)
  },
}
