import React from 'react'

import bordoLoader from '../assets/bordo-loader.svg'

const Loader = () => {
    const style = {
        height: '100vh',
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        background: 'rgba(255,255,255,0.5)',
    }
    return (
        <div className="d-flex align-items-center justify-content-center" style={style}>
            <div className="text-center">
                <img src={bordoLoader} alt="Loading..." className="mb-3" style={{ maxWidth: '150px' }} />
                <div>We're getting things ready...</div>
            </div>
        </div>
    )
}

export default Loader