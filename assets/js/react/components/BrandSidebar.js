import React from "react"

import BrandSidebarHeader from "./BrandSidebarHeader"
import BrandSidebarBody from "./BrandSidebarBody"

const BrandSidebar = () => {
    return (
        <aside className="bdo-brandSidebar d-flex flex-column">
            <BrandSidebarHeader />
            <BrandSidebarBody />
        </aside>
    )
}

export default BrandSidebar
