import React from 'react'
import { XCircle } from 'react-feather'
import Button from 'react-bootstrap/Button'

const Drawer = ({ title, show, handleShow, children }) => {
    return (
        <div className={`drawer__container ${show ? 'active' : ''}`}>
            <div className="drawer">
                <div className="drawer__header">
                    <h2 className="drawer__title">{title}</h2>
                    <Button
                        variant="link"
                        className="text-white"
                        onClick={() => handleShow()}
                    >
                        <XCircle />
                    </Button>
                </div>
                <div className="drawer__content">
                    {children}
                </div>
            </div>
        </div>
    )
}

export default Drawer