import React, { useState, useEffect } from 'react'
import BEMHelper from 'react-bem-helper'

import Navbar from 'react-bootstrap/Navbar'
import Form from 'react-bootstrap/Form'
import FormControl from 'react-bootstrap/FormControl'
import Modal from 'react-bootstrap/Modal'
import Button from 'react-bootstrap/Button'
import InputGroup from 'react-bootstrap/InputGroup'
import { Search, Edit2, Image, Video, Download, ExternalLink, Trash2 } from 'react-feather'
import MediaUploadModal from './MediaUploadModal'
import Row from 'react-bootstrap/Row'
import Card from 'react-bootstrap/Card'
import Col from 'react-bootstrap/Col'
import LoaderButton from './LoaderButton'

import { getMedia, deleteMedia, createMedia, updateMedia } from '../utilities/api'
import { dateFormat, componentPrefix, randomNotificationTitle } from '../utilities/helpers'
import { useStateValue } from '../state'
import CanvaButton from './CanvaButton'
import { UnsplashButton, UnsplashLogo } from './UnsplashSearch'
import DropdownButton from 'react-bootstrap/DropdownButton'
import Dropdown from 'react-bootstrap/Dropdown'
import axios from 'axios'


const MediaNavbar = ({ handleUploadModalShow, activeFilter, handleFiltering, activeSearch, handleSearch }) => {
    const [{activeBrand, assets}, dispatch] = useStateValue()

    const classes = new BEMHelper({
        name: 'mediaNavbar',
        prefix: componentPrefix
    })

    const onDesignOpen = designId => console.log(designId)
    const onDesignPublish = (exportUrl, designId) => {
        let formData = new FormData()
        formData.append('upload_preset', `bdo_image_frontend_upload`)
        formData.append('file', exportUrl)

        axios.request({
            method: 'POST',
            url: `https://api.cloudinary.com/v1_1/bordo/upload`,
            data: formData
        })
            .then(res => {
                createMedia(activeBrand.id, designId, res.data)
                    .then(data => {
                        dispatch({
                            type: 'setAssets',
                            assets: [data, ...assets]
                        })
                    })
            })
    }

    const filters = [
        { label: "All", slug: "all" },
        { label: "Images", slug: "image" },
        { label: "Videos", slug: "video" },
    ]

    return (
        <Navbar bg="light" {...classes()}>
            <Form className="mr-auto" inline>
                <InputGroup>
                    <InputGroup.Prepend>
                        <InputGroup.Text id="search-addon"><Search size={18} /></InputGroup.Text>
                    </InputGroup.Prepend>
                    <FormControl
                        type="text"
                        describedby="search-addon"
                        placeholder="Search"
                        className="mr-sm-2"
                        value={activeSearch}
                        onChange={e => handleSearch(e)}
                    />
                </InputGroup>
                <InputGroup>
                    {filters.map(({ label, slug }, i) => {
                        const checked = slug === activeFilter

                        return <Form.Check
                            key={i}
                            type="radio"
                            name="filter"
                            label={label}
                            value={slug}
                            checked={checked}
                            id={`bdo-mediaFilter--${slug}`}
                            onChange={e => handleFiltering(e)}
                            {...classes('filter', checked ? 'checked' : '')}
                        />
                    })}
                </InputGroup>

            </Form>
            <div>
                <DropdownButton
                    alignRight
                    title="Add Media Items"
                    variant="primary"
                >
                    <Dropdown.Item onClick={() => handleUploadModalShow()}>Upload Image/Video</Dropdown.Item>
                    <Dropdown.Divider />
                    <CanvaButton
                        onDesignOpen={onDesignOpen}
                        onDesignPublish={onDesignPublish}
                    >
                        <Dropdown.Item className="d-flex align-items-center">
                            <i className="mr-2" style={{ width: 18, height: 18, background: '#00c4cc', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                <svg width='38' height='38' viewBox='0 0 32 32' fill='none' xmlns='http://www.w3.org/2000/svg'><mask id='mask0' mask-type='alpha' maskUnits='userSpaceOnUse' x='2' y='2' width='28' height='28'><path d='M16 29.3334C23.3638 29.3334 29.3333 23.3638 29.3333 16C29.3333 8.63622 23.3638 2.66669 16 2.66669C8.63619 2.66669 2.66666 8.63622 2.66666 16C2.66666 23.3638 8.63619 29.3334 16 29.3334Z' fill='white' /></mask><g mask='url(%23mask0)'><path fill-rule='evenodd' clip-rule='evenodd' d='M1.33331 1.33337H30.6666V30.6667H1.33331V1.33337Z' fill='%2300C4CC' /><path fill-rule='evenodd' clip-rule='evenodd' d='M21.4773 18.628C21.4479 18.498 21.3762 18.3814 21.2734 18.2965C21.1706 18.2115 21.0426 18.1631 20.9093 18.1587C20.8021 18.1551 20.696 18.182 20.6035 18.2363C20.511 18.2906 20.4358 18.37 20.3866 18.4654C20.3306 18.5507 20.28 18.6374 20.232 18.7187C20.1965 18.7797 20.16 18.8402 20.1226 18.9C19.496 19.8867 19.0026 20.324 17.8333 20.936C17.3078 21.2065 16.7269 21.352 16.136 21.3614C14.416 21.3614 13.416 19.8387 13.0826 18.5347C12.496 16.2254 13.4693 13.352 14.736 11.708C15.4546 10.7734 16.2573 10.2347 16.9386 10.232C17.1224 10.2379 17.3021 10.2874 17.463 10.3765C17.6239 10.4655 17.7613 10.5915 17.864 10.744C18.2213 11.3187 18.3373 11.8027 17.9306 12.712C17.8729 12.8495 17.8671 13.0032 17.9145 13.1446C17.9618 13.2859 18.0591 13.4052 18.188 13.48C18.528 13.6614 18.9466 13.4574 19.4013 12.8054C19.8813 12.1187 19.912 11.04 19.472 10.3494C18.9293 9.50005 17.8786 8.97205 16.7093 8.97205C15.893 8.97931 15.0946 9.21236 14.4026 9.64538C11.5226 11.4654 9.87196 15.668 10.724 19.012C11.028 20.2054 11.6973 21.284 12.5586 21.9747C12.8973 22.2414 14.112 23.112 15.5853 23.112H15.6026C17.088 23.1054 18.216 22.4747 18.9386 21.9987C19.728 21.4734 20.416 20.7507 21.0453 19.7894C21.0973 19.7107 21.148 19.6294 21.1973 19.5467L21.336 19.3214C21.4063 19.2219 21.4552 19.1089 21.4795 18.9896C21.5038 18.8702 21.5031 18.7471 21.4773 18.628ZM15.5853 22.8067V22.808V22.8067Z' fill='white' /></g></svg>
                            </i>
                            Design on Canva
                        </Dropdown.Item>
                    </CanvaButton>
                    <UnsplashButton>
                        <Dropdown.Item className="d-flex align-items-center">
                            <UnsplashLogo className="mr-2"/>
                            Unsplash
                        </Dropdown.Item>
                    </UnsplashButton>
                </DropdownButton>
            </div>
        </Navbar>
    )
}

const MediaAsset = ({ uuid, title, thumbnail, date, type, handleMediaSelect, selected, editable }) => {
    const classes = new BEMHelper({
        name: 'mediaAsset',
        prefix: componentPrefix
    })

    const Icons = {
        image: Image,
        video: Video,
    }
    const TypeIcon = Icons[type]

    return (
        <Col md={4} className="mb-4">
            <Card {...classes(null, type)} onClick={e => handleMediaSelect(e)} data-uuid={uuid} data-selected={selected}>
                <div {...classes('header')}>
                    <div {...classes('iconBar')}>
                        <TypeIcon  {...classes('icon', 'type')} />
                        {editable ? <Edit2 {...classes('icon', 'edit')} /> : null}
                    </div>
                    <Card.Img variant="top" src={thumbnail}  {...classes('thumbnail')} />
                </div>
                <Card.Body {...classes('body')}>
                    <Card.Subtitle {...classes('date')}>{dateFormat(date)}</Card.Subtitle>
                    <Card.Title {...classes('title')}>{title}</Card.Title>
                </Card.Body>
            </Card>
        </Col>
    )
}

const MediaDetailModal = ({ media, show, handleShow, handleSave, handleDelete }) => {
    const classes = new BEMHelper({
        name: 'mediaDetailModal',
        prefix: componentPrefix
    })

    const [title, setTitle] = useState()

    const fileSize = media.bytes < 1024000 ? `${Number(media.bytes / 1024).toFixed(2)} KB` : `${Number(media.bytes / 1024 / 1024).toFixed(2)} MB`

    useEffect(() => {
        setTitle(media.title)
    }, [media])

    return (
        !media ? null :
            <Modal centered show={show} onHide={handleShow} {...classes()}>
                <Modal.Body className="pt-0">
                    <Row className="mb-4" style={{ marginLeft: "-16px", marginRight: "-16px" }}>
                        {media.resource_type === 'image' ?
                            <img alt='' src={media.thumbnail_url} {...classes('image')} /> :
                            <div className='embed-responsive embed-responsive-16by9'>
                                <video src={media.url} controls className='embed-responsive-item' {...classes('video')} />
                            </div>
                        }
                    </Row>
                    <Row>
                        <Col>
                            <Form>
                                <Form.Group controlId="editMediaTitle" as={Row}>
                                    <Form.Label column sm={3} {...classes('label')}>Title</Form.Label>
                                    <Col>
                                        <Form.Control type="text" value={title} onChange={e => setTitle(e.target.value)} />
                                    </Col>
                                </Form.Group>
                                <Form.Group controlId="editMediaUploadDate" as={Row} className="mb-0">
                                    <Form.Label column sm={3} {...classes('label', 'small')}>Uploaded</Form.Label>
                                    <Col sm="9">
                                        <Form.Control plaintext readOnly defaultValue={dateFormat(media.inserted_at)} className="form-control-sm" />
                                    </Col>
                                </Form.Group>
                                <Form.Group controlId="editMediaDimensions" as={Row} className="mb-0">
                                    <Form.Label column sm={3} {...classes('label', 'small')}>Dimensions</Form.Label>
                                    <Col sm="9">
                                        <Form.Control plaintext readOnly defaultValue={`${media.width}px × ${media.height}px`} className="form-control-sm" />
                                    </Col>
                                </Form.Group>
                                <Form.Group controlId="editMediaFileSize" as={Row} className="mb-0">
                                    <Form.Label column sm={3} {...classes('label', 'small')}>File Size</Form.Label>
                                    <Col sm="9">
                                        <Form.Control plaintext readOnly defaultValue={fileSize} className="form-control-sm" />
                                    </Col>
                                </Form.Group>
                                <hr />
                                <Form.Group controlId="editMediaFileUrl" as={Row} className="mb-0">
                                    <Form.Label column sm={3} {...classes('label', 'small')}>File URL</Form.Label>
                                    <Col>
                                        <InputGroup>
                                            <Form.Control readOnly defaultValue={media.url} className="form-control-sm" />
                                            <InputGroup.Append>
                                                <Button as="a" href={media.url} target="_blank" variant="outline-secondary" size="sm"><ExternalLink size={18} /></Button>
                                            </InputGroup.Append>
                                            <InputGroup.Append>
                                                <Button as="a" href={media.url} download variant="outline-primary" size="sm"><Download size={18} /></Button>
                                            </InputGroup.Append>
                                        </InputGroup>
                                    </Col>
                                </Form.Group>
                            </Form>
                        </Col>
                    </Row>
                </Modal.Body>
                <Modal.Footer className="d-flex justify-content-between">
                    <Button variant="outline-danger" onClick={handleDelete}>
                        <Trash2 size={14} className="mr-2" style={{ marginTop: '-5px' }} />
                    Delete
                </Button>
                    <div>
                        <Button variant="outline-secondary" className="mr-2" onClick={handleShow}>Cancel</Button>
                        <LoaderButton variant="success"
                            onClick={() => {
                                let updatedMedia = media
                                updatedMedia.title = title
                                handleSave(updatedMedia)
                            }}
                        >
                            Save
                        </LoaderButton>
                    </div>
                </Modal.Footer>
            </Modal>
    )
}

export const MediaGallery = ({ isSelecter, onSelect }) => {
    const [{ activeBrand, assets }, dispatch] = useStateValue()
    const [showUploadModal, setShowUploadModal] = useState()
    const [key, setKey] = useState()
    const [showEditModal, setShowEditModal] = useState()

    // const [assets, setAssets] = useState()
    const [filteredAssets, setFilteredAssets] = useState()
    const [activeMedia, setActiveMedia] = useState('')
    const [activeFilter, setActiveFilter] = useState('all')
    const [activeSearch, setActiveSearch] = useState('')

    useEffect(() => {
        if (assets)
            return

        getMedia(activeBrand.id)
            .then(json => {
                dispatch({
                    type: 'setAssets',
                    assets: json
                })

                setFilteredAssets(json)
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

    const handleUploadModalShow = () => {
        setKey(key + 1)
        setShowUploadModal(!showUploadModal)
    }

    const handleEditModalShow = () => {
        setShowEditModal(!showEditModal)
    }

    const handleMediaSelect = assetId => {
        const selectedImage = assets.filter(a => a.id === assetId)[0]

        setActiveMedia(selectedImage)

        if (!isSelecter) {
            setShowEditModal(true)
        } else if (onSelect) {
            onSelect(selectedImage)
        }
    }

    const addMedia = data => {
        dispatch({
            type: 'setAssets',
            assets: [data, ...assets]
        })
    }

    const handleMediaDelete = mediaId => {
        let confirmDelete = window.confirm("Are you sure you want to delete this asset?")

        if (confirmDelete) {
            deleteMedia(activeBrand.id, mediaId)
                .then(json => {
                    dispatch({
                        type: 'setAssets',
                        assets: assets.filter(a => a.id !== mediaId)
                    })

                    setShowEditModal(false)

                    dispatch({
                        type: 'addNotification',
                        data: {
                            title: randomNotificationTitle('success'),
                            body: json.message,
                            variant: 'success'
                        }
                    })
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
        } else {
            return null
        }
    }

    const handleMediaSave = media => {
        updateMedia(activeBrand.id, media.id, { title: media.title })
            .then(json => {
                setShowEditModal(false)
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
    }

    const handleMediaUpload = (res, title) => {
        createMedia(activeBrand.id, title, res.data)
            .then(data => {
                addMedia(data)

                dispatch({
                    type: 'addNotification',
                    data: {
                        title: randomNotificationTitle('success'),
                        body: 'The file was added to your media gallery.',
                        variant: 'success'
                    }
                })

                handleUploadModalShow(false)
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
    }

    const handleFiltering = e => {
        setActiveFilter(e.target.value)
    }

    const handleSearch = e => {
        setActiveSearch(e.target.value)
    }

    useEffect(() => {
        console.log(assets)
        if (!assets)
            return

        if (activeFilter === 'all') {
            setFilteredAssets(assets.filter(e => e.title.toLowerCase().includes(activeSearch.toLowerCase())))
        } else {
            setFilteredAssets(assets.filter(e => e.title.toLowerCase().includes(activeSearch.toLowerCase()) && e.resource_type === activeFilter))
        }
    }, [assets, activeFilter, activeSearch])

    return (
        <>
            <MediaUploadModal show={showUploadModal} handleShow={handleUploadModalShow} onUpload={handleMediaUpload} key={key} />
            <section>
                <MediaNavbar
                    handleUploadModalShow={handleUploadModalShow}
                    handleSearch={handleSearch}
                    activeSearch={activeSearch}
                    handleFiltering={handleFiltering}
                    activeFilter={activeFilter}
                />
                <MediaDetailModal media={activeMedia} show={showEditModal} handleShow={handleEditModalShow} handleSave={data => handleMediaSave(data)} handleDelete={() => handleMediaDelete(activeMedia.id)} />
                <Row>
                    {!filteredAssets ? 'Loading...' :
                        !filteredAssets.length ?
                        <div className="p-5 mx-auto w-50 text-center h3">Looks like you don't have any media yet. Add some to get started!</div> :
                        filteredAssets.map((asset, i) => {
                                return <MediaAsset
                                    title={asset.title}
                                    date={asset.inserted_at}
                                    type={asset.resource_type}
                                    thumbnail={asset.thumbnail_url}
                                    // id={asset.id}
                                    handleMediaSelect={() => handleMediaSelect(asset.id)}
                                    key={i}
                                    selected={isSelecter && activeMedia.id ? asset.id === activeMedia.id : false}
                                    editable={!isSelecter}
                                />
                        })
                    }
                </Row>
            </section>
        </>
    )
}

const Media = () => {
    return (
        <MediaGallery isSelecter={false} />
    )
}

export default Media