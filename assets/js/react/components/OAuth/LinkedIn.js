
import React, { useState, useEffect } from 'react'
import { Row, Col, Media } from 'react-bootstrap'
import bordoLoader from '../../assets/bordo-loader.svg'
import { getChannelCallback } from '../../utilities/api'

const LinkedIn = () => {
    const [profiles, setProfiles] = useState()
    const [channelId, setChannelId] = useState()

    useEffect(() => {
        getChannelCallback('linkedin', window.location.search)
            .then(data => {
                console.log('getChannelCallback data')
                console.log(data)
                const headers = { headers: { Authorization: `Bearer ${data.token}` } }
                setChannelId(data.id)

                fetch(`https://cors-anywhere.herokuapp.com/https://api.linkedin.com/v2/organizationalEntityAcls?q=roleAssignee`, headers)
                    .then(res => res.json())
                    .then(json => {
                        let profiles = json.elements
    
                        profiles = profiles.map((profile) => {
                            let profileId = profile.organizationalTarget.split('organization:')[1]
                            
                            if (!profileId)
                                return null

                            return fetch(`https://cors-anywhere.herokuapp.com/https://api.linkedin.com/v2/organizations/${profileId}?projection=(localizedName,$URN,logoV2(cropped~:playableStreams))`, headers)
                                .then(res => res.json())
                        })

                        Promise.all(profiles)
                            .then(res => {
                                console.log('profiles')
                                console.log(res)
                                setProfiles(res)
                            })
                    })
        })
    }, [])

    const handleProfileSelect = profile => {
        console.log('selected profile')
        console.log(profile)
        if (window.opener) {
            window.opener.postMessage({
                type: 'updateChannel',
                channel_id: channelId,
                data: {
                    channel: {
                        network: 'linkedin',
                        resource_id: profile.$URN
                    }
                }
            })
        }
    
        window.close()
    }

    return (
        <div className="p-5 text-center">
            <img src={bordoLoader} alt="Loading..." className="mb-4" style={{ maxWidth: '100px' }} />
            <h2>Choose a Page or Profile</h2>
            <p className="lead mb-5 text-muted">Select the LinkedIn profile or organization you want to post as.</p>
            {!profiles ? <div>Loading profiles...</div> :
                <Row>
                    {profiles.map(profile => {
                        if (!profile.localizedName || !profile.logoV2)
                            return null

                        return (
                            <Col xs={12} sm={6} >
                                <Media as="a" href="#" className="d-flex align-items-center" onClick={() => handleProfileSelect(profile)}>
                                    <img src={profile.logoV2["cropped~"].elements[0].identifiers[0].identifier} alt='Connect LinkedIn' className="w-25 mr-3 border" />
                                    <Media.Body className="text-left">
                                        <h5>{profile.localizedName}</h5>
                                        <p className="text-muted mb-0">Organization</p>
                                    </Media.Body>
                                </Media>
                            </Col>
                        )}
                    )}
                </Row>
            }
        </div>
    )
}

export default LinkedIn