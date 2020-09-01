import React, { useCallback, useState } from 'react'
import axios from 'axios'

import Modal from 'react-bootstrap/Modal'
import Form from 'react-bootstrap/Form'
import Image from 'react-bootstrap/Image'

import { useDropzone } from 'react-dropzone'
import Button from 'react-bootstrap/Button'

import BEMHelper from 'react-bem-helper'
import { componentPrefix } from '../utilities/helpers'
import { Trash } from 'react-feather'
import { ProgressBar } from 'react-bootstrap'
import { useStateValue } from '../state'
import { createMedia } from '../utilities/api'

const FileUploadDropzone = ({ setFileData, setFileType }) => {
    const classes = BEMHelper({
        name: 'fileUpload',
        prefix: componentPrefix
    })

    const onDrop = useCallback((acceptedFiles) => {
        acceptedFiles.forEach((file) => {
            setFileType(file.type.split('/')[0])

            const reader = new FileReader()

            //   reader.onabort = () => console.log('file reading was aborted')
            //   reader.onerror = () => console.log('file reading has failed')
            reader.onload = () => {
                const binaryStr = reader.result
                setFileData(binaryStr)
            }
            reader.readAsDataURL(file)
        })
    }, [])

    const { getRootProps, getInputProps, fileRejections } = useDropzone({
        onDrop: onDrop,
        multiple: false,
        accept: 'image/*'
    })

    return (
        <div {...classes()} {...getRootProps()}>
            <input {...getInputProps()} />
            <p {...classes('text')}>Drag your files here, or click to select.</p>
        </div>
    )
}

const MediaUploadModal = ({ show, handleShow, onUpload, key, withTitle }) => {
    const [fileData, setFileData] = useState(null)
    const [fileType, setFileType] = useState(null)
    const [title, setTitle] = useState(null)
    const [uploadProgress, setUploadProgress] = useState(null)

    const handleSave = () => {
        let formData = new FormData()
        formData.append('upload_preset', `bdo_${fileType}_frontend_upload`)
        formData.append('file', fileData)

        axios.request({
            method: 'POST',
            url: `https://api.cloudinary.com/v1_1/bordo/upload`,
            data: formData,
            onUploadProgress: p => {
                setUploadProgress(100 / (p.total / p.loaded))
            }
        })
            .then(res => onUpload(res, title))
    }

    return (
        <Modal
            centered={true}
            show={show}
            onHide={handleShow}
        >
            <Modal.Header>
                <Modal.Title>Upload new media.</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                {!fileData ?
                    <FileUploadDropzone setFileData={setFileData} setFileType={setFileType} />
                    :
                    <>
                        <Button variant="danger" size="sm" className="position-absolute" onClick={() => setFileData(null)} style={{ zIndex: 999 }}><Trash size={18} /></Button>
                        <div className="mb-3">
                            {fileType === 'video' ? <div className="embed-responsive embed-responsive-16by9"><video className="embed-responsive-item" src={fileData} controls /></div> : <Image fluid src={fileData} />}
                            {uploadProgress ? <ProgressBar now={uploadProgress} /> : null}
                        </div>
                        {withTitle ? <Form.Group controlId="editMediaTitle">
                            <Form.Control type="text" placeholder="Title" value={title} onChange={e => setTitle(e.target.value)} />
                        </Form.Group> : null}
                    </>
                }
            </Modal.Body>
            <Modal.Footer>
                <Button variant="outline-danger" onClick={handleShow}>Cancel</Button>
                {!fileData ? null : <Button variant="success" disabled={!title && withTitle} onClick={handleSave}>Save</Button>}
            </Modal.Footer>
        </Modal>
    )
}

MediaUploadModal.defaultProps = {
    withTitle: true,
}

export default MediaUploadModal