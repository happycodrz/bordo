import React, { useEffect, useState } from 'react'

const CanvaButton = ({ children, onDesignOpen, onDesignPublish }) => {
  const [ready, setReady] = useState(false)
  let canva

  useEffect(() => {
    var script = document.createElement('script')
    script.src = 'https://sdk.canva.com/v2/beta/api.js'
    script.onload = () => {
      // API initialization
      if (window.CanvaButton) {
        window.CanvaButton.initialize({
          apiKey: 'fWzIitASrQlpVDa-nh7oUNl-',
        }).then((api) => {
          window.canva = api
          setReady(true)
          console.log(api)
        })
      }
    }

    document.body.appendChild(script)
  }, [])

  const handleButtonClick = () => {
    window.canva.createDesign({
      type: 'SocialMedia',
      onDesignOpen: ({ designId }) => onDesignOpen(designId),
      onDesignPublish: ({ exportUrl, designId }) =>
        onDesignPublish(exportUrl, designId),
    })
  }

  const childElement = children
    ? React.cloneElement(children, {
        disabled: !ready,
        onClick: handleButtonClick,
      })
    : null

  return childElement ? (
    childElement
  ) : (
    <button disabled={!ready} onClick={handleButtonClick}>
      Design on Canva
    </button>
  )
}

export default CanvaButton
