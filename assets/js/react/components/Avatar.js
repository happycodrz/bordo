import React from 'react'
import { hexToRgb } from '../utilities/helpers'

const Avatar = props => {
    let { alt, src, shape, color, children, textColor } = props

    let rgb = hexToRgb(color)

    if (!textColor) {
        textColor = rgb && (rgb.r * 0.299 + rgb.g * 0.587 + rgb.b * 0.114) > 186 ? '#000000' : '#ffffff'
    }

    return (
        <div
            className={`bdo-avatar bdo-avatar--${shape}`}
            style={{
                background: src ? `url(${src})` : color,
                color: textColor,
            }}
            {...props}
        >
            {src ? <img src={src} alt={alt} /> : <span>{children}</span>}
        </div>
    )
}

Avatar.defaultProps = {
    color: '#ffffff',
    shape: 'circle'
}

export default Avatar