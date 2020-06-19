import React, { useState } from 'react'
import { Send } from 'react-feather'

import NewPostModal from './NewPostModal'

const SidebarNewPostButton = ({ brandId }) => {
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
      <div className="px-3 pb-2 mt-auto">
        <button
          className="btn btn-danger btn-lg btn-block d-flex align-items-center justify-content-center mb-2"
          id="newPostButton"
          onClick={() => handleNewPostModalShow()}
        >
          <Send className="mr-2" size={18} />
          New Post
        </button>
      </div>
      <NewPostModal
        show={showNewPostModal}
        handleShow={handleNewPostModalShow}
        brandId={brandId}
        key={key}
      />
    </div>
  )
}

export default SidebarNewPostButton
