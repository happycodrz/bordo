import React, { useState, useEffect } from "react"
import { Card, Row, Col, Popover, OverlayTrigger, ListGroup } from "react-bootstrap"
import { Plus } from 'react-feather'
import { useStateValue } from '../state'
import Channel from './Channel'
import PopoutWindow from 'react-popout'
import { getChannelAuth, getChannels, getChannelCallback, deleteChannel } from "../utilities/api"
import { createSlug, randomNotificationTitle, sentenceCase } from "../utilities/helpers"

const Channels = () => {
    const [externalAuthUrl, setExternalAuthUrl] = useState(null)
    const [currentChannelToAdd, setCurrentChannelToAdd] = useState(null)
    const [{ activeBrand }, dispatch] = useStateValue()
    
    const [channels, setChannels] = useState([])
    const [supportedChannels, setSupportedChannels] = useState([])
    
    useEffect(() => {
        if (!currentChannelToAdd)
            return

        const authComplete = e => {
            if (e.data.type !== 'oAuthComplete')
                return
    
            getChannelCallback(currentChannelToAdd, e.data.queryString)
                .then(data => {
                    setCurrentChannelToAdd(null)
                    setChannels([...channels, data])
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

        window.addEventListener('message', authComplete, false)
    }, [currentChannelToAdd])

    useEffect(() => {
        if (window.opener && window.location.search) {
            window.opener.postMessage({
                type: 'oAuthComplete',
                queryString: window.location.search
            }, window.location.origin)

            window.close()
            return
        }

        getChannels(activeBrand.id)
            .then(json => {
                setChannels(json)
            })
    }, [])

    useEffect(() => {
        if (!channels.length)
            return 

        const authorizedChannels = channels.map(channel => channel.network)
        const filteredChannels = ["twitter", "facebook", "linkedin"].filter(channel => !authorizedChannels.includes(createSlug(channel)))
        console.log(filteredChannels)
        setSupportedChannels(filteredChannels)
    }, [channels])

    const AddChannelCard = () => {
        return (
            <OverlayTrigger trigger="click" rootClose placement="top" overlay={addChannelPopover}>
                <Card style={{ cursor: 'pointer' }} className="channel-card bg-light text-primary h-100">
                    <Card.Body className="d-flex align-items-center justify-content-center">
                        <Plus strokeWidth={2} size={72} />
                    </Card.Body>
                </Card>
            </OverlayTrigger>
        )
    }

    const handleAddChannelClick = channel => {
        let channel_slug = createSlug(channel)
        setCurrentChannelToAdd(channel)

        //close the popover, by losing focus
        document.body.click()

        getChannelAuth(activeBrand.id, channel_slug)
            .then(data => {
                setExternalAuthUrl(data.url)
            })
    }

    const handleRemoveChannelClick = channel => {
        deleteChannel(activeBrand.id, channel.id)
            .then(data => {
                setChannels(channels.filter(c => c.id !== channel.id))
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

    const addChannelPopover = (
        <Popover id="popover-basic">
            <Popover.Title as="h3">Add new channel</Popover.Title>
            <Popover.Content>
                <ListGroup>
                    {!supportedChannels.length ? null : supportedChannels.map(channel => (
                        <ListGroup.Item onClick={() => handleAddChannelClick(channel)} action variant="light">
                            {sentenceCase(channel)}
                        </ListGroup.Item>
                    ))}
                </ListGroup>
            </Popover.Content>
        </Popover>
    )

    return (
        <>
            {!externalAuthUrl ? null :
            <PopoutWindow
                url={externalAuthUrl}
                title={`Add new channel: ${currentChannelToAdd}`}
                options={{ width: 1024, height: 768 }}
            />}
            <Row className="mb-3">
                <Col><h2>Channels</h2></Col>
            </Row>
            <Row>
                {!channels.length ? null : channels.map(c => (
                    <Col md={2}>
                        <Channel channel={c} handleRemoveClick={handleRemoveChannelClick} />
                    </Col>
                ) )}
                {!supportedChannels.length ? null : 
                    <Col md={2}>
                        <AddChannelCard />
                    </Col>
                }
            </Row>
        </>
    )
}

export default Channels
