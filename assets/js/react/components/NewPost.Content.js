import React, { useState, useContext } from 'react'
import Row from 'react-bootstrap/Row'
import Col from 'react-bootstrap/Col'
import Form from 'react-bootstrap/Form'
import { dateFormat, timeFormat } from '../utilities/helpers'
import MediaSelecter from './MediaSelecter'
import { NewPostContext } from './NewPostModal'
import ContentEditor from './ContentEditor'
export const Content = ({ show }) => {
    const [{ dateTime, title, description, mediaId }, dispatch] = useContext(NewPostContext)
    const [selectedImage, setSelectedImage] = useState(null)
    const setTitle = title => {
        dispatch({
            type: 'setTitle',
            title: title
        })
    }
    const setDescription = description => {
        dispatch({
            type: 'setDescription',
            description: description
        })
    }
    const setMediaId = mediaId => {
        setSelectedImage(mediaId)
        dispatch({
            type: 'setMediaId',
            mediaId: mediaId
        })
    }
    return (<div style={{ display: show ? 'block' : 'none' }} className="py-4">
        <p class="text-center mb-5">
            <span class="lead">What do you want to post about?</span>
            {!dateTime ? null : <span className="small d-block text-muted">{dateFormat(dateTime)} at {timeFormat(dateTime)}</span>}
        </p>
        <Row>
            <Col sm={5}>
                <MediaSelecter selected={selectedImage} onSelect={selectedImage => setMediaId(selectedImage)} />
            </Col>
            <Col>
                <Form.Group controlId="title">
                    <Form.Control type="text" value={title} onChange={e => setTitle(e.target.value)} placeholder="Title" />
                    <Form.Text className="text-muted small">Give this post a title so you can find it later. Nobody will see this text besides you.</Form.Text>
                </Form.Group>
                {/* <Form.Group controlId="title" className="mb-0">
                    <Form.Control as="textarea" style={{ resize: 'none' }} rows="6" value={description} onChange={e => setDescription(e.target.value)} placeholder="Description" />
                    <Form.Text className="text-muted text-right">{!description ? 0 : description.length}</Form.Text>
                </Form.Group> */}
                <ContentEditor
                    placeholder="The content of your posts – say something nice!"
                    onChange={e => {
                        setDescription(e)
                    }}
                />
            </Col>
        </Row>
    </div>)
}

Content.defaultProps = {
    label: 'Post Content'
}