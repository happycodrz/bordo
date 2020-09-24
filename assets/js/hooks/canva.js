export const Canva = {
  mounted() {
    if (window.CanvaButton === undefined) {
      this.loadCanva()
    }
    this.handleEvent('open', () => {
      this.createDesign()
    })
  },
  destroyed() {

  },
  loadCanva() {
    let script = document.createElement('script')
    script.src = 'https://sdk.canva.com/v2/beta/api.js'
    script.onload = () => {
      // API initialization
      window.CanvaButton.initialize({
        apiKey: 'fWzIitASrQlpVDa-nh7oUNl-',
      }).then((api) => {
        window.canva = api
      })
    }

    document.body.appendChild(script)
  },
  createDesign() {
    window.canva.createDesign({
      publishLabel: 'Upload to Bordo',
      type: 'SocialMedia',
      onDesignPublish: ({
          exportUrl,
          designId
        }) =>
        this.pushEvent('canva-upload', {
          url: exportUrl,
        }),
    })
  },
}
