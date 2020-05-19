import React, { useState, useReducer, useContext, createContext } from 'react'
import Modal from 'react-bootstrap/Modal'

// import { schedulePost } from '../utilities/api'
// import { getChannels } from '../api'
import { schedulePost, deletePost } from '../utilities/api'
import { dateFormat, timeFormat, sentenceCase, randomNotificationTitle } from '../utilities/helpers'

import Button from 'react-bootstrap/Button'
import { Calendar, Facebook, Twitter, Instagram, Linkedin, Globe, MapPin, Save, Edit2, Trash2 } from 'react-feather'


import { useStateValue } from '../state'
import LoaderButton from './LoaderButton'
import Schedule from './NewPost.Schedule'
import moment from 'moment'
import { Content } from './NewPost.Content'
import { VariantEditor } from './NewPost.Variants'
import Form from 'react-bootstrap/Form'
import { Badge } from 'react-bootstrap'
import { EditableInput } from './EditableInput'

export const socialIcons = {
    facebook: Facebook,
    twitter: Twitter,
    instagram: Instagram,
    linkedin: Linkedin,
    google: Globe,
    pinterest: MapPin
}

export const PostContext = createContext()

const PostEditorModal = ({ post, show, handleShow }) => {
    const [{activeBrand}, dispatch] = useStateValue()
    const [title, setTitle] = useState('')

    const handleSchedule = () => {
        // const body = {
        //     "post": {
        //         "title": title,
        //         "scheduled_for": new Date(dateTime).toISOString(),
        //         "post_variants": Object.values(variants).filter(v => v.active)
        //     }
        // }

        // schedulePost(activeBrand.id, body)
        //     .then(post => {
        //         dispatch({
        //             type: 'addPosts',
        //             posts: post
        //         })

        //         handleShow()
        //     })
    }

    const handleDeleteClick = () => {
        deletePost(activeBrand.id, post.id)
            .then(json => {
                dispatch({
                    type: 'deletePost',
                    postId: post.id
                })

                dispatch({
                    type: 'addNotification',
                    data: {
                        title: randomNotificationTitle('success'),
                        body: json.message,
                        variant: 'success'
                    }
                })
                handleShow()
            })
    }

    const updateVariant = (network, field, value) => {
        dispatch({
            type: 'updateVariant',
            network: network,
            field: field,
            value: value
        })
    }

    return (
        <Modal
            size="lg"
            centered={true}
            show={show}
            onHide={handleShow}
        >
            <Modal.Header closeButton>
                <Modal.Title className="w-100">
                    {/* <Form.Control type="text" size="lg" value={title} onChange={e => setTitle(e.target.value)} placeholder="Title" className="border-0 p-0 mb-1" /> */}
                    <EditableInput defaultValue={post.title} onSave={e => setTitle(e)} />
                    <div className="text-muted d-block" style={{ fontSize: 12 }}><Calendar size={12} /> {dateFormat(post.scheduled_for)} at {timeFormat(post.scheduled_for)}</div>
                </Modal.Title>
            </Modal.Header>
            <Modal.Body>
                <Form>
                    <Form.Group controlId="title">
                    </Form.Group>
                    {post.post_variants.map(pv => {
                        let statusVariant
                        switch (pv.status) {
                            case 'success':
                                statusVariant = 'success'
                                break;
                            case 'failed':
                                statusVariant = 'danger'
                                break;
                            default:
                                statusVariant = 'light'
                                break;
                        }

                        return (
                                <>
                            <div className="mb-3 border-bottom pb-3">
                                <header className="mb-2">
                                    <h3 className="h5 mb-0">
                                        {sentenceCase(pv.network)} <Badge pill variant={statusVariant}>{sentenceCase(pv.status)}</Badge>
                                    </h3>
                                </header>
                                <VariantEditor showHeading={false} variant={pv} updateVariant={(field, value) => updateVariant(pv.network, field, value)} />
                            </div>
                                <hr/>
                            </>
                        )
                    })}
                </Form>
            </Modal.Body>
            <Modal.Footer className="justify-content-between">
                <LoaderButton variant="danger" onClick={handleDeleteClick}><Trash2 size={16} /> Delete Post</LoaderButton>
                <LoaderButton variant="success" onClick={handleSchedule}><Save size={16} /> Save Post</LoaderButton>
            </Modal.Footer>
        </Modal>
    )
}

export default PostEditorModal