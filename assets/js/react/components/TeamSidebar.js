import React from "react"

import TeamNavigation from "./TeamNavigation"
import UserIcon from "./UserIcon"

const TeamSidebar = () => {
    return (
        <aside className="team__sidebar bg-dark text-light d-flex flex-column justify-content-between">
            <TeamNavigation />
            <UserIcon />
        </aside>
    )
}

export default TeamSidebar
