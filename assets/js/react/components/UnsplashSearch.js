import React, { useEffect, useState, useRef } from 'react'
import _ from 'lodash'

import Modal from 'react-bootstrap/Modal'
import ModalBody from 'react-bootstrap/ModalBody'
import Form from 'react-bootstrap/Form'
import ModalHeader from 'react-bootstrap/ModalHeader'
import ModalTitle from 'react-bootstrap/ModalTitle'
import Button from 'react-bootstrap/Button'
import Media from 'react-bootstrap/Media'
import Card from 'react-bootstrap/Card'
import CardColumns from 'react-bootstrap/CardColumns'
import ModalFooter from 'react-bootstrap/ModalFooter'
import axios from 'axios'

import { createMedia } from '../utilities/api'
import { useStateValue } from '../state'

import LoaderButton from './LoaderButton'

export const UnsplashLogo = ({size, className, white}) => {
    const fillColor = white ? '#fff' : '#000000'
    return <svg className={className} width={size} xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400"><g><g><polygon style={{ fill: fillColor }} points="274.14 177.12 400 177.12 400 400 0 400 0 177.12 125.86 177.12 125.86 288.33 273.68 288.33 273.68 177.12 274.14 177.12"/><polygon style={{ fill: fillColor }} points="274.14 0 125.86 0 125.86 111.67 273.68 111.67 273.68 0 274.14 0"/></g></g></svg>
}

UnsplashLogo.defaultProps = { size: 18, white: false }

const UnsplashImageCard = ({ image, selected, handleSelect}) => {
    selected = selected ? 'bdo-unsplashSearch__card--selected' : ''

    return (
        <Card className={`bdo-unsplashSearch__card ${selected}`} onClick={() => handleSelect(image)}>
            <Card.Img variant="top" src={image.urls.small} />
            <Card.ImgOverlay className="d-flex align-items-end" style={{ background: 'linear-gradient(10deg, rgba(0,0,0,0.4), transparent)' }}>
                <Card.Text>
                    <Media className="text-light align-items-center">
                        <img src={image.user.profile_image.small} alt={image.user.name} className="rounded-circle mr-3" />
                        <Media.Body >{image.user.name}</Media.Body>
                    </Media>
                </Card.Text>
            </Card.ImgOverlay>
        </Card>
        // <div className="bdo-UnsplashSearch__item">
        //     <img src={image.urls.small} alt={image.description} className="bdo-UnsplashSearch__thumbnail" />
        //     <div className="bdo-UnsplashSearch__overlay">
        //         <div>
        //             <img src={image.user.profile_image.small} alt={image.user.name} />
        //             <span>{image.user.name}</span>
        //         </div>
        //     </div>
        // </div>
    )
}

const UnsplashSearch = ({ selectedImage, setSelectedImage }) => {
    const [inputValue, setInputValue] = useState('')
    const [query, setQuery] = useState('')
    const [page, setPage] = useState(1)
    const [results, setResults] = useState([])

    useEffect(() => {
        if (!query)
            return

        fetch(`https://api.unsplash.com/search/photos?page=${page}&query=${query}&client_id=oEPr7PwuQW8HmQB7q6JPdzC5y2pxQtnErE5zuZO1lTY`)
            .then(res => res.json())
            .then(json => setResults(json.results))
    }, [query])

    useEffect(() => {
        if (!query)
            return

        fetch(`https://api.unsplash.com/search/photos?page=${page}&query=${query}&client_id=oEPr7PwuQW8HmQB7q6JPdzC5y2pxQtnErE5zuZO1lTY`)
            .then(res => res.json())
            .then(json => setResults([...results, ...json.results]))
    }, [page])

    const delayedQuery = useRef(_.debounce(q => setQuery(q), 500)).current

    const handleSearch = e => {
        const value = e.target.value
        setInputValue(value)
        delayedQuery(value)
    }

    return (
        <div>
            <Form.Control type="text" placeholder="Search free high-resolution photos" size="lg" className="mb-3" value={inputValue} onChange={handleSearch} />
            <div style={{maxHeight: '73vh', overflow: 'scroll'}} className="p-1">
                <CardColumns style={{ maxHeight: page * 800 }}>
                    {results.map(image => {
                        let selected = !selectedImage ? null : selectedImage.id === image.id
                        return (
                            <UnsplashImageCard
                                image={image}
                                handleSelect={image => setSelectedImage(image)}
                                selected={selected}
                            />
                        )
                    })}
                </CardColumns>
                {!results.length ? null : <div className="text-center">
                    <Button
                        variant="outline-secondary"
                        onClick={() => setPage(page + 1)}
                    >
                        Load More
                    </Button>
                </div>}
            </div>
        </div>
    )
}

export const UnsplashButton = ({children}) => {
    const [showModal, setShowModal] = useState(false)

    const childElement = children ? React.cloneElement(
        children,
        {
            onClick: () => setShowModal(true)
        }
    ) : null

    return (
        <>
            <UnsplashSearchModal
                show={showModal}
                handleShow={setShowModal}
                onSelectImage={null}
            />
            {childElement}
        </>
    )
}

const UnsplashSearchModal = ({ show, handleShow }) => {
    const [{activeBrand, assets}, dispatch] = useStateValue()
    const [selectedImage, setSelectedImage] = useState(null)

    const handleUpload = image => {
        let formData = new FormData()
        formData.append('upload_preset', `bdo_image_frontend_upload`)
        formData.append('file', image.urls.full)

        axios.request({
            method: 'POST',
            url: `https://api.cloudinary.com/v1_1/bordo/upload`,
            data: formData
        })
            .then(res => {
                createMedia(activeBrand.id, image.description || image.id, res.data)
                    .then(data => {
                        dispatch({
                            type: 'setAssets',
                            assets: [data, ...assets]
                        })

                        handleShow()
                    })
            })
    }

    return (
        <Modal size="lg"
            show={show}
            onHide={handleShow}
            handleShow={handleShow}
            handleCl
            centered
        >
            <ModalHeader closeButton>
                <ModalTitle><UnsplashLogo size={32} /> Unsplash</ModalTitle>
            </ModalHeader>
            <ModalBody>
                <UnsplashSearch
                    selectedImage={selectedImage}
                    setSelectedImage={setSelectedImage}
                />
            </ModalBody>
            {!selectedImage ? null : <ModalFooter><LoaderButton variant="success" onClick={() => handleUpload(selectedImage)}>Select Image</LoaderButton></ModalFooter>}
        </Modal>
    )
}

export default UnsplashSearchModal