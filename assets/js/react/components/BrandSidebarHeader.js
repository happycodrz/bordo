import React from "react"
import { useStateValue } from "../state"

const BrandSidebarHeader = () => {
    const [{ activeBrand }] = useStateValue()

    return (
        <header className="bg-white px-3 py-5 d-flex justify-content-between align-items-center">
            <h2 className="m-0">{activeBrand.name}</h2>
        </header>
    )
}

export default BrandSidebarHeader
