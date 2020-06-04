import React, { useEffect } from "react"
import { useStateValue } from './state'

import BrandSidebar from "./components/BrandSidebar"
import Loader from "./components/Loader"
import NotificationsList from "./components/Notifications"
import { navigate } from "@reach/router"

const Layout = ({children}) => {
    const [{ loadingBrand, activeBrand, brands }, dispatch] = useStateValue()
    
    useEffect(() => {
        let brandSlug = window.location.pathname.split('/')[1]

        if(!brandSlug) {
            navigate(`/${brands[0].slug}/`, {}, true)
            dispatch({
                type: 'setActiveBrand',
                data: brands.filter(b => b.slug === brands[0].slug)[0]
            })
        }
        else {
            dispatch({
                type: 'setActiveBrand',
                data: brands.filter(b => b.slug === brandSlug)[0]
            })
        }
    }, [])

    return (
        !activeBrand ? <Loader /> :
        <>
            <div className="app__container">
                {loadingBrand ? <Loader /> : null}
                <BrandSidebar />
                {children}
            </div>
            <NotificationsList />
        </>
    )
}

export default Layout
