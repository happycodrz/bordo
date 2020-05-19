import React from "react"
import { useStateValue } from "../state"
import Cookies from 'js-cookie'

import { navigate, Link } from "@reach/router"

import Avatar from "./Avatar"

const BrandNavButton = ({ brand }) => {
    const [{ brands, activeBrand }, dispatch] = useStateValue()

    let label
    const name = brand.name.split(" ")

    if (name.length > 1) {
        label = `${name[0][0]}${name[1][0]}`
    } else {
        label = name[0][0]
    }

    const active = activeBrand && brand.id === activeBrand.id ? 'active' : null;

    // const handleBrandClick = () => {
    //     if (activeBrand.id === brand.id) {
    //         return null
    //     }

    //     dispatch({
    //         type: 'setActiveBrand',
    //         data: brands.filter(e => e.id === brand.id)[0]
    //     })
    //     Cookies.set('bdo-activeBrandId', brand.id)
    //     navigate('/')
    // }

    return (
        <div className={`brand-nav__button p-2 ${active}`}>
            <Link to={`/${brand.slug}/`}>
                <Avatar
                    shape='rounded'
                    // onClick={handleBrandClick}
                    src={brand.image_url || null}
                >
                    {brand.image_url ? '' : label}
                </Avatar>
            </Link>
        </div>
    )
}

export default BrandNavButton
