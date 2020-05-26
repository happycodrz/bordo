import React, { useState } from "react"
import { useStateValue } from "../state";
import Cookies from 'js-cookie'

import BrandNavButton from './BrandNavButton'
import Avatar from "./Avatar";
import { Plus } from "react-feather";
import { Modal, Button, FormControl } from "react-bootstrap";

import { addNewBrand } from '../utilities/api'
import { navigate } from "@reach/router";

const AddNewBrandButton = () => {
    const [{ brands }, dispatch] = useStateValue()
    const [show, setShow] = useState(false);
    const [brandName, setBrandName] = useState('');

    const toggleShow = () => setShow(!show)

    return (
        <>
            <div className='brand-nav__button bdo-teamNav__addButton p-2'>
                <Avatar
                    shape='rounded'
                    color="#1A7EBD"
                    textcolor="#A7DAFA"
                    onClick={toggleShow}
                >
                    <Plus size={30} />
                </Avatar>
            </div>
            <Modal show={show} onHide={toggleShow} centered onEntered={() => document.getElementById('newBrandNameInput').focus()}>
                <Modal.Body>
                    <FormControl id="newBrandNameInput" placeholder="New brand name" size="lg" value={brandName} onChange={e => setBrandName(e.target.value)} autoFocus={true} />
                </Modal.Body>
                <Modal.Footer className="d-flex justify-content-start flex-row-reverse">
                    <Button
                        variant="success"
                        className="d-flex align-items-center"
                        onClick={() => {
                            addNewBrand(brandName)
                                .then(newBrand => {
                                    dispatch({
                                        type: 'addBrand',
                                        brand: newBrand
                                    })

                                    dispatch({
                                        type: 'setActiveBrand',
                                        data: newBrand
                                    })

                                    navigate(`/${newBrand.slug}/`)

                                    setBrandName('')
                                    toggleShow()
                                })
                        }}
                    >
                        <Plus size={18} className="mr-2" />Add Brand
                    </Button>
                    <Button variant="link" className="d-flex align-items-center text-danger" onClick={toggleShow}>
                        Cancel
                    </Button>
                </Modal.Footer>
            </Modal>
        </>
    )
}

const TeamNavigation = () => {
    const [{ brands }] = useStateValue()

    return (
        <div style={{ overflow: 'scroll', width: '100%' }}>
            {brands.map((brand, i) => (
                <BrandNavButton brand={brand} key={i} />
            ))}
            <AddNewBrandButton />
        </div>
    )
}

export default TeamNavigation
