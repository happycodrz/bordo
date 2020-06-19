import React, { useState, createContext } from 'react'
import Modal from 'react-bootstrap/Modal'

import { deletePost, updatePost } from '../utilities/api'
import { sentenceCase, randomNotificationTitle } from '../utilities/helpers'

import { Facebook, Twitter, Instagram, Linkedin, Globe, MapPin, Save, Trash2 } from 'react-feather'


import { useStateValue } from '../state'
import LoaderButton from './LoaderButton'
import { VariantEditor } from './NewPost.Variants'
import Form from 'react-bootstrap/Form'
import { Badge } from 'react-bootstrap'
import { EditableInput } from './EditableInput'
import moment from 'moment'

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
    const [postData, setPostData] = useState(post)

    const handleSaveClick = () => {
        updatePost(activeBrand.id, postData.id, { post: postData })
            .then(post => {
                dispatch({
                    type: 'updatePost',
                    data: {
                        id: postData.id,
                        post: postData
                    }
                })

                handleShow()
            })
    }

    const handleDeleteClick = () => {
        if(window.confirm('Are you sure you want to delete this post?')) {
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
        } else {
            return
        }
    }

    const updateVariant = (network, field, value) => {
        const newPostData = {...postData}

        if (network) {
            newPostData.post_variants.map(pv => {
                if (pv.network === network) {
                    pv[field] = value
                }

                return pv
            })
        } else {
            newPostData[field] = value
        }

        setPostData(newPostData)
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
                    <EditableInput defaultValue={post.title} onSave={e => updateVariant(null, 'title', e)} />
                    <input
                        style={{ fontSize: 12 }}
                        class="text-muted border-0"
                        type="datetime-local"
                        id="scheduled_for"
                        name="scheduled_for"
                        value={moment(postData.scheduled_for).format('YYYY-MM-DDTHH:MM')}
                        min={moment.utc().format('YYYY-MM-DDTHH:MM')}
                        onChange={e => updateVariant(null, 'scheduled_for', moment(e.target.value).format())}
                    />
                </Modal.Title>
            </Modal.Header>
            <Modal.Body>
                <Form>
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
                <LoaderButton variant="success" onClick={handleSaveClick}><Save size={16} /> Save Post</LoaderButton>
            </Modal.Footer>
        </Modal>
    )
}

export default PostEditorModal