import React from 'react'

import { Icon } from './UserIcon'

import Row from 'react-bootstrap/Row'
import Col from 'react-bootstrap/Col'
import Button from 'react-bootstrap/Button'
import Modal from 'react-bootstrap/Modal'
import Table from 'react-bootstrap/Table'
import Form from 'react-bootstrap/Form'
import { getAllUsers } from '../utilities/api'

const UsersModal = ({users}) => {
    // TODO: get the users, setUsers
    // const [users, setUsers] = useState()

    // useEffect(() => {
    // })
    const updateUserRole = (userId, userRole) => {
        // TODO: actually update User's role
        console.log(userId, userRole)
    }
    return (
        <Modal
            size='lg'
            show={true}
        >
            <Modal.Header closeButton>
                <Modal.Title>Users</Modal.Title>
            </Modal.Header>
            <Modal.Body>
                <Table responsive>
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Role</th>
                        </tr>
                    </thead>
                    <tbody>
                        {users.map(user => (
                            <tr>
                                <td>
                                    {user.first_name} {user.last_name}
                                </td>
                                <td>
                                    <a href={`mailto:${user.email}`}>{user.email}</a>
                                </td>
                                <td>
                                    <Form.Control as="select" onChange={e => updateUserRole(user.id, e.target.value)}>
                                        <option value="1">Brand Manager</option>
                                        <option value="0">None</option>
                                    </Form.Control>
                                </td>
                            </tr>
                        ))}
                    </tbody>
                </Table>
            </Modal.Body>
            <Modal.Footer>
                <Button variant="success">Save Changes</Button>
            </Modal.Footer>
        </Modal>
    )
}

const Users = ({brandUsers}) => {
    return (
        <>
            <h2 className="mb-3">Team Members</h2>
            <Row>
                {!brandUsers ? null : brandUsers.map(user => (
                    <Col className="d-flex align-items-center mb-4" sm={6}>
                        <div style={{ width: 140 }} className="mr-3">
                            <Icon />
                        </div>
                        <div>
                            <h3>{user.first_name} {user.last_name}</h3>
                            <p className="text-muted mb-0">{user.email}</p>
                        </div>
                    </Col>
                ))}
            </Row>
            {/* <UsersModal users={brandUsers} /> */}
        </>
    )
}

export default Users