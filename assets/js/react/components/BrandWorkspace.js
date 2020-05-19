import React from "react"

import { navigationList } from '../utilities/navigation'

import Launchpad from "./Launchpad"
import Schedule from "./Schedule"
import Reports from "./Reports"
import Settings from "./Settings"
import Media from '../components/Media'

const BrandWorkspace = () => {
    const pageComponents = {
        Launchpad,
        Schedule,
        Reports,
        Settings,
        Media,
    }

    return (
        <div className="bdo-brandWorkspace">
            {navigationList.map((e, i) => {
                const Component = pageComponents[e.componentName]
                
                return (
                    <Component path={e.path} key={i} />
                )
            })}
        </div>
    )
}

export default BrandWorkspace
