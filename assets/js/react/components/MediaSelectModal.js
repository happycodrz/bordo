import React, { useState } from 'react'

import Modal from 'react-bootstrap/Modal'
import Button from 'react-bootstrap/Button'
import { EIStateProvider, reducer, initialState } from '../state'
import { MediaGallery } from './Media'

const MediaSelectModal = ({ show, handleShow, handleSelect, key, brandId }) => {
  console.log(brandId, 'from media select modal')
  const [selectedImage, setSelectedImage] = useState(null)

  const handleSelectClick = (selectedImage) => {
    handleSelect(selectedImage)
    handleShow()
  }

  let initialState = { ...initialState, activeBrand: { id: brandId } }

  return (
    <EIStateProvider initialState={initialState} reducer={reducer}>
      <Modal
        size="lg"
        centered={true}
        show={show}
        onHide={handleShow}
        key={key}
        dialogClassName="mediaSelectModal"
      >
        <Modal.Body style={{ overflow: 'hidden' }}>
          <MediaGallery
            isSelecter={true}
            onSelect={(e) => setSelectedImage(e)}
          />
        </Modal.Body>
        <Modal.Footer>
          <Button variant="outline-danger" onClick={handleShow}>
            Cancel
          </Button>
          <Button
            variant="success"
            disabled={!selectedImage}
            onClick={() => handleSelectClick(selectedImage)}
          >
            Select
          </Button>
        </Modal.Footer>
      </Modal>
    </EIStateProvider>
  )
}

export default MediaSelectModal
