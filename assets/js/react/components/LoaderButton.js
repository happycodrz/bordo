import React, { useState } from 'react'
import Button from 'react-bootstrap/Button'
import BEMHelper from 'react-bem-helper'
import { componentPrefix } from '../utilities/helpers'

const LoaderButton = (props) => {
    const [loading, setLoading] = useState(false)

    const classes = new BEMHelper({
        name: 'loaderButton',
        prefix: componentPrefix
    })

    const handleClick = () => {
        setLoading(!loading)
        props.onClick()
    }

    return (
        <Button {...props} {...classes(null, loading ? 'loading' : null)} onClick={handleClick}>
            <span {...classes('icon')}>
                <span className="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span>
            </span>
            <span {...classes('text')}>
                {props.children}
            </span>
        </Button>
    )
}

export default LoaderButton