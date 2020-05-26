import React, { useState, useEffect } from "react"
import { useStateValue } from '../state'

import Button from "react-bootstrap/Button"
import Row from "react-bootstrap/Row"
import Col from "react-bootstrap/Col"

import MediaUploadModal from "./MediaUploadModal"

import { updateBrand, getAllUsers, deleteBrand } from "../utilities/api"
import Channels from "./Channels";
import {Icon} from "./UserIcon"
import { randomNotificationTitle } from "../utilities/helpers"
import { EditableInput } from "./EditableInput"
import { navigate } from "@reach/router"
import Avatar from "./Avatar"
import { Plus } from "react-feather"
import Users from './Users.js'

const Settings = () => {
    const [{ activeBrand }, dispatch] = useStateValue()
    const [uploadModalShow, setUploadModalShow] = useState(false)
    const [brandUsers, setBrandUsers] = useState([])

    const handleRemove = userId => {
        return null
    }

    useEffect(() => {
        getAllUsers(activeBrand.id)
            .then(users => {
                console.log(users)
                setBrandUsers(users)
            })
            .catch(error => {
                dispatch({
                    type: 'addNotification',
                    data: {
                        title: randomNotificationTitle('failure'),
                        body: error.message,
                        variant: 'danger'
                    }
                })
            })
    }, [])

    const handleOnUpload = res => {
        updateBrand(activeBrand.id, {
            "brand": {
                "image_url": res.data.secure_url,
            }
        })
            .then(e => {
                dispatch({
                    type: 'updateBrand',
                    brand: e
                })

                setUploadModalShow(false)
            })
    }

    const handleDeleteBrandClick = () => {
        if(window.confirm(`Are you sure you want to delete the brand ${activeBrand.name}?`)) {
            deleteBrand(activeBrand.id)
                .then(() => {
                    window.location.replace('/')
                })
        } else {
            return
        }
    }

    const updateBrandName = (brandName) => {
        updateBrand(activeBrand.id, {
            "brand": {
                "name": brandName
            }
        })
            .then(e => {
                dispatch({
                    type: 'updateBrand',
                    brand: e
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
                        style={{ width: 125, height: 125, overflow: 'hidden', backgroundImage: `url(${activeBrand.image_url})`, backgroundSize: 'cover' }}
                        onClick={() => setUploadModalShow(true)}
                    >
                        {/* <img src={activeBrand.image_url} alt={activeBrand.name} /> */}
                        <span className="bg-dark text-white text-center w-100 small" style={{ position: 'absolute', bottom: 0, left: 0, opacity: 0.8 }}>Update Image</span>
                    </div>
                    <EditableInput defaultValue={activeBrand.name} onSave={e => updateBrandName(e)} />
                </Col>
                <Col sm={5} className="d-flex align-items-start justify-content-end">
                    <Button variant="danger" onClick={handleDeleteBrandClick}>Delete Brand</Button>
                </Col>
            </Row>
            <Users brandUsers={brandUsers} />
            <Channels />
        </section>
    )
}

export default Settings
