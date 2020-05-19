import React, { useState } from 'react'

import Button from 'react-bootstrap/Button'
import MediaSelectModal from './MediaSelectModal'

const Select = ({ onSelect }) => {
    const [show, setShow] = useState(false)
    const [key, setKey] = useState(false)

    const handleShow = () => {
        if (show === true) {
            setKey(key + 1)
        }

        setShow(!show)
    }

    return (
        <>
            <Button variant="secondary" block onClick={handleShow}>Choose Media</Button>
            <MediaSelectModal show={show} handleShow={handleShow} handleSelect={e => onSelect(e)} key={key} />
        </>
    )
}

const MediaSelecter = ({ selected, onSelect }) => {
    return (
        <div className="p-3 bg-light border rounded-lg h-100 d-flex flex-column justify-content-center">
            {selected ?
                <img src={selected.thumbnail_url} alt={selected.title} onClick={() => onSelect(null)}
                    style={{
                        height: '100%',
                        width: '100%',
                        objectFit: 'contain'
                    }}
                /> :
                <>
                    <Select onSelect={onSelect} />
                </>
            }
        </div>
    )
}

export default MediaSelecter