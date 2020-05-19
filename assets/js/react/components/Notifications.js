import React, {useEffect} from 'react'
import { useStateValue } from '../state'

import Alert from 'react-bootstrap/Alert'

const Notification = ({notification}) => {
    const [{}, dispatch] = useStateValue()
    const {title, body, time, variant, id} = notification

    useEffect(() => {
        const interval = setInterval(() => {
            dispatch({
                type: 'deleteNotification',
                id: id
            })
        }, 3000)

        return () => {
            clearInterval(interval)
        }
    }, [])

    return (
        <Alert variant={variant} className="bdo-notifcation small" data-id={id}>
            <p className="font-weight-bolder mb-0">{title}</p>
            <p className="mb-0">{body}</p>
        </Alert>
    )
}

const NotificationsList = () => {
    const [{ notifications }, dispatch] = useStateValue()

    const variants = ['success', 'danger', 'info', 'warning']

    // useEffect(() => {
    //     setInterval(() => {
    //         dispatch({
    //             type: 'addNotification',
    //             data: {
    //                 title: 'Success!',
    //                 body: 'You did it!',
    //                 variant: variants[Math.floor(Math.random() * variants.length)],
    //                 id: Math.floor((Math.random() * 100) + 1)
    //             }
    //         })
    //     }, 1000)
    // }, [])
    
    return (
        <div className="p-3 d-flex flex-column justify-content-end" style={{ zIndex: 999, pointerEvents: 'none', position: 'fixed', right: 0, bottom: 0, top: 0, width: '300px' }}>
            {!notifications ? null : notifications.map(notification => (
                <Notification notification={notification} />
            ))}
        </div>
    )
}

export default NotificationsList