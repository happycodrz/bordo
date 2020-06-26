import React, { useState } from 'react'

import Row from 'react-bootstrap/Row'
import Col from 'react-bootstrap/Col'

import MediaUploadModal from './MediaUploadModal'

import { updateBrand } from '../utilities/api'

const Settings = ({ brandId, brandImage }) => {
  const [uploadModalShow, setUploadModalShow] = useState(false)

  const handleOnUpload = (res) => {
    updateBrand(brandId, {
      brand: {
        image_url: res.data.secure_url,
      },
    }).then((e) => {
      window.location.reload()
    })
  }

  return (
    <section>
      <MediaUploadModal
        show={uploadModalShow}
        handleShow={() => setUploadModalShow(!uploadModalShow)}
        onUpload={handleOnUpload}
        withTitle={false}
      />
      <Row>
        <Col className="d-flex align-items-center">
          <div
            className="bg-white border rounded-lg d-flex align-items-end position-relative mr-3"
            style={{
              width: 125,
              height: 125,
              overflow: 'hidden',
              backgroundImage: `url(${brandImage})`,
              backgroundSize: 'cover',
            }}
            onClick={() => setUploadModalShow(true)}
          >
            <span
              className="bg-dark text-white text-center w-100 small"
              style={{ position: 'absolute', bottom: 0, left: 0, opacity: 0.8 }}
            >
              Update Image
            </span>
          </div>
        </Col>
      </Row>
    </section>
  )
}

export default Settings
