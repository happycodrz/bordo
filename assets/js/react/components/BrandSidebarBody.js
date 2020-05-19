import React, { useState } from "react"
import { Send } from 'react-feather'

import BrandNavigation from "./BrandNavigation"
import NewPostModal from "./NewPostModal"

const BrandSidebarBody = () => {
    const [showNewPostModal, setShowNewPostModal] = useState()
    const [key, setKey] = useState(0)

    const handleNewPostModalShow = () => {
        if (showNewPostModal === false) {
            setKey(key + 1)
        }

        setShowNewPostModal(!showNewPostModal)
    }

    return (
        <div className="d-flex flex-column h-100">
            <BrandNavigation />
            <div class="px-3 pb-2 mt-auto">
                <button
                    className="btn btn-danger btn-lg btn-block d-flex align-items-center justify-content-center mb-2"
                    id="newPostButton"
                    onClick={() => handleNewPostModalShow()}
                >
                    <Send className="mr-2" size={18} />New Post
                </button>
                <p className="text-muted text-center mb-0" style={{ fontSize: '0.5em' }}>
                    v.{process.env.REACT_APP_BDO_VERSION}&nbsp;|&nbsp;
                    ©{new Date().getFullYear()} Bordo LLC
                    &nbsp;|&nbsp;
                    <a href="https://hellobordo.com/privacy-policy" target="_blank" rel="noopener noreferrer">
                        Privacy Policy
                    </a>
                </p>
            </div>
            <NewPostModal
                show={showNewPostModal}
                handleShow={handleNewPostModalShow}
                key={key}
            />
        </div>
    )
}

export default BrandSidebarBody
