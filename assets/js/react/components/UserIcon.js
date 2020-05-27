import React from 'react'
import { useStateValue } from '../state'

import { LogOut } from 'react-feather'

import Dropdown from 'react-bootstrap/Dropdown'

export const Icon = () => {
    const [{ activeUser }] = useStateValue()

    return (
        <div
            className='bdo-avatar bdo-avatar--circle'
        >
            <img src={activeUser.image_url} alt={activeUser.first_name} />
        </div>
    )
}
const UserIcon = () => {
    const CustomToggle = React.forwardRef(({ children, onClick }, ref) => (
        <button
            className='bdo-avatar bdo-avatar--circle'
            ref={ref}
            onClick={(e) => onClick(e) }
        >
            {children}
        </button>
    ))

    return (
        <div className="p-2">
            <Dropdown>
                <Dropdown.Toggle
                    as={CustomToggle}
                    id='dropdown-custom-components'
                >
                    <Icon />
                </Dropdown.Toggle>

                <Dropdown.Menu>
                    {/* <Dropdown.Item eventKey="1">Settings</Dropdown.Item>
                    <Dropdown.Item eventKey="2">Help</Dropdown.Item>
                    <Dropdown.Divider /> */}
                    <Dropdown.Item eventKey="3" className="text-danger d-flex justify-content-between align-items-center" href="/logout">Log Out<LogOut size={14}/></Dropdown.Item>
                </Dropdown.Menu>
            </Dropdown>
            {/* <button className="btn text-center bg-white py-3 btn-block rounded-circle" onClick={() => }>
                {activeUser.first_name[0]}
            </button> */}
        </div>
    )
}

export default UserIcon