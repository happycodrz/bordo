import React, { useState, useEffect, useContext } from 'react'
import { useStateValue } from '../state'
import { dateFormat, timeFormat, createSlug, sentenceCase } from '../utilities/helpers'
import { getChannels } from '../utilities/api'

import MediaSelecter from './MediaSelecter'
import ContentEditor from './ContentEditor'
import { NewPostContext } from './NewPostModal'

import Row from 'react-bootstrap/Row'
import Col from 'react-bootstrap/Col'
import Tab from 'react-bootstrap/Tab'
import Nav from 'react-bootstrap/Nav'
import Button from 'react-bootstrap/Button'
import Form from 'react-bootstrap/Form'
import { Link } from '@reach/router'

import { Facebook, Twitter, LinkedIn } from './SocialLogos'

const socialIcons = {
    facebook: <Facebook size={20} />,
    twitter: <Twitter size={20} />,
    linkedin: <LinkedIn size={20} />,
}

export const Variants = ({ show }) => {
    const [{ activeBrand }] = useStateValue()
    const [{ dateTime, title, description, mediaId, variants }, dispatch] = useContext(NewPostContext)
    const [noChannels, setNoChannels] = useState(false)
    const [channels, setChannels] = useState()

    useEffect(() => {
        getChannels(activeBrand.id)
            .then(channels => {
                if (channels && channels.length) {
                    setChannels(channels)
                }
                else {
                    setNoChannels(true)
                }
            })
    }, [])

    const variantExistsForNetwork = network => {
        return variants.hasOwnProperty(network)
    }
    
    const isVariantActive = network => {
        if (!variantExistsForNetwork(network))
            return false
        return variants[network]['active']
    }
    
    const toggleVariant = channel => {
        if (variantExistsForNetwork(channel.network)) {
            dispatch({
                type: 'toggleVariantActive',
                network: channel.network
            })
        } else {
            dispatch({
                type: 'createVariant',
                network: channel.network,
                content: description,
                mediaId: mediaId ? mediaId.id : '',
                channel_id: channel.id,
                active: true
            })
        }
    }

    const updateVariant = (network, field, value) => {
        dispatch({
            type: 'updateVariant',
            network: network,
            field: field,
            value: value
        })
    }
    
    const variantArray = Object.values(variants)
    
    return (<div style={{ display: show ? 'block' : 'none' }} className="py-4">
        <p className="text-center mb-5">
            <span className="lead">Where do you want to post this?</span>
            {!dateTime || !title ? null : <span className="small d-block text-muted">{title}<span className="mx-2">|</span>{dateFormat(dateTime)} at {timeFormat(dateTime)}</span>}
        </p>
        <Row>
            <Col className="text-center">
                {noChannels ? <span>This brand has no authorized social channels. Do you need to <Link to='/settings'>add some</Link>?</span> : null}
                {!channels ? null : channels.map((e, i) => {
                    let slug = e.network.toLowerCase().split(' ')[0]
                    return (<Button key={i} variant="outline-primary" size="sm" className="rounded-pill px-3 mx-1" active={isVariantActive(e.network)} onClick={() => toggleVariant(e)}>
                        {socialIcons[slug]} {sentenceCase(e.network)}
                    </Button>)
                })}
            </Col>
        </Row>
        {(!variantArray || variantArray.filter(n => n.active).length < 1) && !noChannels
            ?
            <p className="lead font-weight-bold text-center mt-4">Please choose a social channel.</p>
            :
            <>
                <hr className="my-4" />
                <Tab.Container id="left-tabs-example" defaultActiveKey="0">
                    <Row>
                        <Col sm={3}>
                            <Nav variant="pills" className="flex-column">
                                {variantArray.map((variant, i) => {
                                    //TODO: don't remove, just "disable" visually
                                    if (!variant.active)
                                        return null
                                    return (<Nav.Item key={i}>
                                        <Nav.Link eventKey={i} className="text-truncate">{sentenceCase(variant.network)}</Nav.Link>
                                    </Nav.Item>)
                                })}
                            </Nav>
                        </Col>
                        <Col sm={9}>
                            <Tab.Content>
                                {variantArray.map((variant, i) => {
                                    if (!variant.active)
                                        return null
                                    let slug = createSlug(variant.network)
                                    return (<Tab.Pane eventKey={i} key={i}>
                                        <VariantEditor variant={variant} mediaId={mediaId} updateVariant={(field, value) => updateVariant(variant.network, field, value)} />
                                    </Tab.Pane>)
                                })}
                            </Tab.Content>
                        </Col>
                    </Row>
                </Tab.Container>
            </>}
    </div>)
}

export const VariantEditor = ({ variant, mediaId, updateVariant, showHeading }) => {
    const [selectedImage, setSelectedImage] = useState(null)

    useEffect(() => {
        if (mediaId) {
            setSelectedImage(mediaId)
        }

        if (variant.media && variant.media.length) {
            setSelectedImage(variant.media[0])
        }
    }, [])
    
    let slug = variant.network.toLowerCase().split(' ')[0]
    let characterCount = slug === "twitter" ? 280 : null
    
    return (<div>
        {!showHeading ? null : <Row>
            <Col>
                <h4 className="mb-3">
                    {socialIcons[slug]} {sentenceCase(variant.network)} {!variant.username ? null : <small className="text-muted">{variant.username}</small>}
                </h4>
            </Col>
        </Row>}
        <Row>
            <Col sm={5}>
                <MediaSelecter
                    selected={selectedImage}
                    onSelect={selectedImage => {
                        setSelectedImage(selectedImage)
                        if (selectedImage) {
                            updateVariant('post_variant_media', [{"media_id": selectedImage.id}])
                        }
                    }}
                />
            </Col>
            <Col>
                <ContentEditor
                    content={variant.content}
                    onChange={e => updateVariant('content', e)} 
                    characterCount={characterCount}
                />
            </Col>
        </Row>
    </div>)
}

VariantEditor.defaultProps = {
    showHeading: true
}

Variants.defaultProps = {
    label: 'Social Networks'
}
