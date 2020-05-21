import React from "react"
import { useStateValue } from "../state"

import { Link } from "@reach/router"

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

    return (
        <div className={`brand-nav__button p-2 ${active}`}>
            <Link to={`/${brand.slug}/`} onClick={() => dispatch({
                type: 'setActiveBrand',
                data: brands.filter(b => b.slug === brand.slug)[0]
            })} >
                <Avatar
                    shape='rounded'
                    src={brand.image_url || null}
                >
                    {brand.image_url ? '' : label}
                </Avatar>
            </Link>
        </div>
    )
}

export default BrandNavButton
