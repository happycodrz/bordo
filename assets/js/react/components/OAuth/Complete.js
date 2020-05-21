import React, { useEffect } from 'react'

const Complete = () => {
    useEffect(() => {
        if (window.opener) {
            window.opener.postMessage({
                type: 'oAuthComplete',
                queryString: window.location.search
            }, window.location.origin)
        }
    
        window.close()
    }, [])
    
    return (
        <p>Redirecting back to Bordo...</p>
    )
}

export default Complete