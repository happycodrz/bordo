import React, { useState, useEffect } from "react"
import { useStateValue } from '../state'

import Button from "react-bootstrap/Button"
import Row from "react-bootstrap/Row"
import Col from "react-bootstrap/Col"

import MediaUploadModal from "./MediaUploadModal"

import { updateBrand, getAllUsers, deleteBrand } from "../utilities/api"
import Channels from "./Channels";
import UserIcon from "./UserIcon"
import { randomNotificationTitle } from "../utilities/helpers"
import { EditableInput } from "./EditableInput"

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
                    window.location.reload()
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
            <Row className="mb-3">
                <Col><h2>Team Members</h2></Col>
            </Row>
            <Row>
                {!brandUsers ? null : brandUsers.map(user => (
                    <Col className="d-flex align-items-center mb-4" sm={6}>
                        <div style={{ width: 140 }} className="mr-3">
                            <UserIcon />
                        </div>
                        <div>
                            <h3>{user.first_name} {user.last_name}</h3>
                            <p className="text-muted">{user.email}</p>
                            {/* <a onClick={() => handleRemove(user.id)} className="text-danger">Remove</a> */}
                        </div>
                    </Col>
                ))}
            </Row>
            <Channels />
        </section>
    )
}

export default Settings
