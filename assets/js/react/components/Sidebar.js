import React from "react"
import TeamSidebar from "./TeamSidebar"
import BrandSidebar from "./BrandSidebar"

const Sidebar = () => {
    return (
        <aside className="sidebar">
            <TeamSidebar />
            <BrandSidebar />
        </aside>
    )
}

export default Sidebar
