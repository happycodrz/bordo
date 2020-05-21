
import React, { useState, useEffect } from 'react'
import { Row, Col, Media } from 'react-bootstrap'
import bordoLoader from '../../assets/bordo-loader.svg'
import { getChannelCallback } from '../../utilities/api'

const LinkedIn = () => {
    const [profiles, setProfiles] = useState()

    // https://staging.bor.do/oauth/linkedin?code=AQSr6yEJoh4iJOfUnNrBj8Euy_JFhfvJyD8HRKBtwVFwAEDtKwGfscbp6k0kCtgg5taAjiV2itQ_8mWMzbLpU7hizTeyRvsYejzmAwdsD1hjB0qPQ8PU1l4wzdCFE2qmJyZewEVEjSbjk34pfqOEjtHbVfq45MaO-hrKQbcpuUQnQexr3zWJQSutAdda5A&state=brand_id%3D8ba3943b-9785-4be2-a94c-4f00b50b0d5a

    useEffect(() => {
        getChannelCallback('linkedin', window.location.search)
            .then(data => {
                fetch(`https://api.linkedin.com/v2/organizationalEntityAcls?q=roleAssignee`, {
                    headers: {
                        Authorization: `Bearer ${data.token}`
                    }
                })
                    .then(res => res.json())
                    .then(json => {
                        let profiles = json.elements
    
                        profiles.map(profile => {
                            let profileId = profile.split('organization:')[1]
                            return fetch(`https://api.linkedin.com/v2/organizations/${profileId}&projection=(elements*(entity~(localizedName,logoV2)))`)
                                .then(res => res.json())
                                .then(json => json.elements)
                        })
            
                        setProfiles(profiles)
                    })  
        })
    }, [])

    return (
        <div class="p-5 text-center">
            <img src={bordoLoader} alt="Loading..." className="mb-4" style={{ maxWidth: '100px' }} />
            <h2>Choose a Page or Profile</h2>
            <p className="lead mb-5 text-muted">Select the LinkedIn profile or organization you want to post as.</p>
            {!profiles ? <div>Loading profiles...</div> :
                <Row>
                    {profiles.map(profile => (
                        <Col xs={12} sm={6} >
                            <Media as="a" href="#" onClick={() => console.log(profile.entity)}>
                                <img src={profile['entity~'].logoV2.croppedImage.original} alt='Connect LinkedIn' />
                                <Media.Body>
                                    <h5>{profile['entity~'].localizedName}</h5>
                                </Media.Body>
                                <p className="text-muted pb-0">Organization</p>
                            </Media>
                        </Col>
                    ))}
                </Row>
            }
        </div>
    )
}

export default LinkedIn