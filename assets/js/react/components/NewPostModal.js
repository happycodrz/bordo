import React, { useState, useReducer, useContext, createContext } from 'react'
import { useStateValue } from '../state'

import LoaderButton from './LoaderButton'
import Schedule from './NewPost.Schedule'
import { Variants } from './NewPost.Variants'
import { Content } from './NewPost.Content'
import { schedulePost } from '../utilities/api'

import Modal from 'react-bootstrap/Modal'
import Button from 'react-bootstrap/Button'
import Nav from 'react-bootstrap/Nav'

import { Calendar } from 'react-feather'
import moment from 'moment'
import { randomNotificationTitle } from '../utilities/helpers'

export const NewPostContext = createContext()

const NewPostWizard = ({ activePage, children }) => {
    return (
        <>
            {children.map((page, i) => (
                React.cloneElement(page, {
                    key: i,
                    show: activePage === i ? true : false
                })
            ))}
        </>
    )
}

const NewPostModal = ({ show, handleShow }) => {
    const [{ activeBrand }, dispatch] = useStateValue()
    const [{ title, dateTime, variants }] = useContext(NewPostContext)

    const [activePage, setActivePage] = useState(0)

    const nextPage = () => setActivePage(activePage + 1)
    const prevPage = () => setActivePage(activePage - 1)

    const pages = [
        <Content />,
        <Variants />,
        <Schedule />
    ]

    const handleSchedule = () => {
        console.log(dateTime)
        const body = {
            "post": {
                "title": title,
                "scheduled_for": dateTime.utc(),
                "post_variants": Object.values(variants).filter(v => v.active)
            }
        }

        
        schedulePost(activeBrand.id, body)
            .then(newPost => {
                
                dispatch({
                    type: 'addPosts',
                    posts: newPost
                })
                
                handleShow()
                
                const bodies = ['Your post is scheduled. Way to go!', 'Post scheduled. You deserve an award.', 'That post is ready to go!', 'Done and done. Post scheduled.']
                dispatch({
                    type: 'addNotification',
                    data: {
                        title: randomNotificationTitle('success'),
                        body: bodies[Math.floor(Math.random() * bodies.length)],
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
    }

    return (
        <Modal
            size="lg"
            centered={true}
            show={show}
            onHide={handleShow}
        >
            <Modal.Header className="flex-column pb-0">
                <div className="d-flex w-100">
                    <Modal.Title>{"Let's create a new post."}</Modal.Title>
                    <button type="button" class="close" onClick={handleShow}><span aria-hidden="true">×</span><span class="sr-only">Close</span></button>
                </div>
                <Nav
                    className="nav--modal"
                    activeKey={activePage}
                    onSelect={e => setActivePage(Number(e))}
                >
                    {pages.map((page, i) => (
                        <Nav.Item>
                            <Nav.Link eventKey={i}>{page.props.label}</Nav.Link>
                        </Nav.Item>
                    ))}
                </Nav>
            </Modal.Header>
            <Modal.Body>
                <NewPostWizard activePage={activePage}>
                    {pages}
                </NewPostWizard>
            </Modal.Body>
            <Modal.Footer className="justify-content-between">
                {activePage < 1 ? <span></span> : <Button variant="secondary" onClick={prevPage}>‹ Back</Button>}
                {activePage + 1 >= pages.length ? <span></span> : <Button variant="primary" onClick={nextPage} disabled={!dateTime}>Next ›</Button>}
                {/* {activePage + 1 < pages.length ? null : <Button variant="success" onClick={handleSchedule}><Calendar size={16} /> Schedule Post</Button>} */}
                {activePage + 1 < pages.length ? null : <LoaderButton variant="success" onClick={handleSchedule}><Calendar size={16} /> Schedule Post</LoaderButton>}
            </Modal.Footer>
        </Modal>
    )
}

const NewPost = ({ show, handleShow, key }) => {
    const initialState = {
        title: '',
        description: '',
        mediaId: '',
        dateTime: moment(),
        variants: []
    }

    const reducer = (state, action) => {
        switch (action.type) {
            case 'setDateTime':
                return {
                    ...state,
                    dateTime: action.dateTime,
                }

            case 'setTitle':
                return {
                    ...state,
                    title: action.title,
                }

            case 'setDescription':
                return {
                    ...state,
                    description: action.description,
                }

            case 'setMediaId':
                return {
                    ...state,
                    mediaId: action.mediaId,
                }

            case 'toggleVariantActive': {
                const newVariants = { ...state.variants }
                newVariants[action.network]['active'] = !state.variants[action.network]['active']

                return {
                    ...state,
                    variants: newVariants
                }
            }

            case 'createVariant': {
                const newVariants = { ...state.variants }
                newVariants[action.network] = {
                    network: action.network,
                    channel_id: action.channel_id,
                    content: action.content,
                    active: true
                }

                if(action.mediaId) {
                    newVariants[action.network]['post_variant_media'] = [{"media_id": action.mediaId}]
                }

                return {
                    ...state,
                    variants: newVariants
                }
            }

            case 'updateVariant': {
                const newVariants = { ...state.variants }
                newVariants[action.network][action.field] = action.value

                return {
                    ...state,
                    variants: newVariants
                }
            }

            default:
                return { ...state }
        }
    }

    return (
        <NewPostContext.Provider value={useReducer(reducer, initialState)} key={key}>
            <NewPostModal show={show} handleShow={handleShow} />
        </NewPostContext.Provider>
    )
}

export default NewPost