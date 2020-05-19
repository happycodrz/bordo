import React, { useRef } from "react"
import { Card, Button } from "react-bootstrap"

import { Twitter, Facebook, LinkedIn } from "./SocialLogos"
import { sentenceCase } from "../utilities/helpers"
import { X } from "react-feather"
import LoaderButton from "./LoaderButton"

const socialLogos = {
    twitter: <Twitter />,
    facebook: <Facebook />,
    linkedin: <LinkedIn />,
}

const Channel = ({ channel, handleRemoveClick }) => {
    return (
        <Card className="channel-card h-100">
            <Card.Header>
                {channel.resource_id ? `@${channel.resource_id}` : sentenceCase(channel.network)}
            </Card.Header>
            <Card.Body className="text-center d-flex align-items-center justify-content-center">
                <div class="w-75">
                    {socialLogos[channel.network]}
                </div>
            </Card.Body>
            <Card.Footer>
                <LoaderButton variant="secondary" size="sm" block onClick={() => handleRemoveClick(channel)}>Remove</LoaderButton>
            </Card.Footer>
        </Card>
    );
}

export default Channel