import React, { useState, useEffect } from "react"
import { redirectTo } from "@reach/router"

import { useStateValue } from '../state'
// import { getBrand } from "../api"
import { getUser, getAllBrands } from "../utilities/api"
// import { getUser, getAllBrands } from "../api"
import Alert from "react-bootstrap/Alert"

import Cookies from 'js-cookie'

const StateInitializer = ({ loading, children, brandSlug }) => {
    const [stateLoading, setStateLoading] = useState(true)
    const [hasError, setHasError] = useState(null)
    const [{ activeUser, activeBrand, brands }, dispatch] = useStateValue()

    useEffect(() => {
        const authToken = Cookies.get('bdo-logged-in')
        // const activeBrandCookie = Cookies.get('bdo-activeBrandId')

        if (!authToken || authToken === 'undefined') {
            window.location = process.env.REACT_APP_LOGIN_URL || '/login'
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

                // dispatch({
                //     type: 'setActiveBrand',
                //     data: brands.filter(b => b.slug === brandSlug)[0]
                // })
            })
            .catch(err => setHasError(JSON.stringify(err)))
    }, [])

    // useEffect(() => {
    //     if (!brands)
    //         return

    //     const activeBrandCookie = Cookies.get('bdo-activeBrandId')
    //     dispatch({
    //         type: 'setActiveBrand',
    //         data: activeBrandCookie ? brands.filter(b => b.id === activeBrandCookie)[0] : brands[0]
    //     })
    // }, [brands])

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