import React, { useEffect } from "react"
import { useStateValue } from './state'

import BrandWorkspace from "./components/BrandWorkspace"
import TeamSidebar from "./components/TeamSidebar"
import BrandSidebar from "./components/BrandSidebar"
import Loader from "./components/Loader"
import NotificationsList from "./components/Notifications"

const Layout = ({children, brandSlug}) => {
    const [{ loadingBrand, activeBrand, brands }, dispatch] = useStateValue()

    useEffect(() => {
        dispatch({
            type: 'setActiveBrand',
            data: brands.filter(b => b.slug === brandSlug)[0]
        })
    }, [brandSlug])

    return (
        !activeBrand ? <Loader /> :
        <>
            <div class="app__container">
                {loadingBrand ? <Loader /> : null}
                <TeamSidebar />
                <BrandSidebar />
                {/* <BrandWorkspace /> */}
                <div className="bdo-brandWorkspace">
                    {children}
                </div>
            </div>
            <NotificationsList />
        </>
    )
}

export default Layout
