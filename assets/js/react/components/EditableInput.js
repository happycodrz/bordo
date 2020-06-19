import React, { useState, useRef, useEffect } from "react"

import FormText from "react-bootstrap/FormText"
import FormGroup from "react-bootstrap/FormGroup"

export const EditableInput = ({ defaultValue, onSave }) => {
    const [editable, setEditable] = useState(false)
    const [value, setValue] = useState(defaultValue)

    const inputRef = useRef(null)
    
    const handleEditClick = () => setEditable(true)
    
    const handleCancelClick = () => {
        setValue(defaultValue)
        setEditable(false)
    }
    
    const handleSaveClick = () => {
        onSave(value)
        setEditable(false)
    }

    useEffect(() => {
        if (editable) {
          inputRef.current.focus()
        }
      }, [editable])

    return (<FormGroup className="mb-0">
        <input
            type="text"
            value={value}
            disabled={!editable}
            className={`bdo__editableInput ${editable ? 'bdo__editableInput--editable' : ''}`}
            onChange={e => setValue(e.target.value)}
            ref={inputRef}
        />
        {!editable ?
            <FormText as="a" href="#" className="mb-0" onClick={handleEditClick}>Edit</FormText>
            :
            <p className="mb-0">
                <FormText as="a" href="#" className="mb-0 d-inline text-danger" onClick={handleCancelClick}>Cancel</FormText> <span className="text-light">|</span> <FormText as="a" href="#" className="mb-0 d-inline" onClick={handleSaveClick}>Save</FormText>
            </p>}
    </FormGroup>)
}
