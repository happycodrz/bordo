import React from "react"
import { Link } from "@reach/router"
import * as Icon from 'react-feather'

import { navigationList } from '../utilities/navigation'
import { useStateValue } from "../state"

const NavLink = props => (
    <Link
        {...props}
        getProps={({ isCurrent }) => {
            return {
                className: props.className + (isCurrent ? " active" : "")
            }
        }}
    />
)

const BrandNavigation = () => {
    const [{activeBrand}] = useStateValue()
    return (
        <nav className="nav flex-column">
            {navigationList.map(e => {
                const IconElement = Icon[e.icon]

                return (
                    <div className="nav-item">
                        <NavLink to={`/${activeBrand.slug}${e.path}`} className="bdo-brandNav__link nav-link p-3 d-flex align-items-center">
                            <IconElement size={20} className="mr-3" />
                            {e.label}
                        </NavLink>
                    </div>
                )
            })}
        </nav>
    )
}

export default BrandNavigation
