import React, { useState } from 'react'
import { reducer, useStateValue, EIStateProvider } from '../state'

import Row from 'react-bootstrap/Row'
import Col from 'react-bootstrap/Col'

import MediaUploadModal from './MediaUploadModal'

import { updateBrand } from '../utilities/api'
import { EditableInput } from './EditableInput'

const SettingsComponent = () => {
  const [{ activeBrand }, dispatch] = useStateValue()
  const [uploadModalShow, setUploadModalShow] = useState(false)

  const handleOnUpload = (res) => {
    updateBrand(activeBrand.id, {
      brand: {
        image_url: res.data.secure_url,
      },
    }).then((e) => {
      dispatch({
        type: 'updateBrand',
        brand: e,
      })

      setUploadModalShow(false)
    })
  }

  const updateBrandName = (brandName) => {
    updateBrand(activeBrand.id, {
      brand: {
        name: brandName,
      },
    }).then((e) => {
      dispatch({
        type: 'updateBrand',
        brand: e,
      })
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
      <Row className="mb-5">
        <Col sm={7} className="d-flex align-items-center">
          <div
            className="bg-white border rounded-lg d-flex align-items-end position-relative mr-3"
            style={{
              width: 125,
              height: 125,
              overflow: 'hidden',
              backgroundImage: `url(${activeBrand.image_url})`,
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
          <EditableInput
            defaultValue={activeBrand.name}
            onSave={(e) => updateBrandName(e)}
          />
        </Col>
      </Row>
    </section>
  )
}

let initialState = {
  loadingBrand: false,
  activeBrand: null,
  brands: null,
  activeUser: null,
  posts: [],
  assets: null,
  notifications: [],
}

const Settings = ({ brandId, brandName, brandSlug, brandImage }) => {
  const activeBrand = {
    id: brandId,
    name: brandName,
    slug: brandSlug,
    image_url: brandImage,
  }

  initialState = { ...initialState, activeBrand: activeBrand }
  return (
    <EIStateProvider initialState={initialState} reducer={reducer}>
      <SettingsComponent />
    </EIStateProvider>
  )
}
export default Settings
