import React, { useState, useEffect } from "react"
import { redirectTo } from "@reach/router"

import { useStateValue } from '../state'
// import { getBrand } from "../api"
import { getUser, getAllBrands } from "../utilities/api"
// import { getUser, getAllBrands } from "../api"
import Alert from "react-bootstrap/Alert"

const StateInitializer = ({ loading, children }) => {
    const [stateLoading, setStateLoading] = useState(true)
    const [hasError, setHasError] = useState(null)
    const [{ activeUser, activeBrand, brands }, dispatch] = useStateValue()

    useEffect(() => {
        const authToken = document.querySelector(`meta[name="auth-token"]`).getAttribute('content')

        if (!authToken || authToken === 'undefined') {
            window.location = process.env.REACT_APP_LOGIN_URL
        }

        getUser()
            .then(user => {
                dispatch({
                    type: 'setActiveUser',
                    data: user
                })
            })

        getAllBrands()
            .then(brands => {
                if (brands.length < 1) {
                    setHasError("Hmm...we couldn't get any data for your login information. This should never happen. Maybe just try logging in again.")
                }

                dispatch({
                    type: 'setBrands',
                    data: brands
                })
            })
            .catch(err => setHasError(JSON.stringify(err)))
    }, [])

    useEffect(() => {
        if (activeUser && brands) {
            setStateLoading(false)
        }
    }, [activeUser, activeBrand, brands])

    return (
        <>
            {stateLoading ? loading : children}
            {hasError ? <Alert variant="danger" className="m-5">{hasError}</Alert> : null}
        </>
    )
}

export default StateInitializer