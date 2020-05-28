import React, { useContext, useEffect, useState } from 'react'
import { Calendar, Clock } from 'react-feather'

import Form from 'react-bootstrap/Form'

import { NewPostContext } from './NewPostModal'
import * as Helpers from '../utilities/helpers'

import moment from 'moment'
import { Button } from 'react-bootstrap'

const Schedule = ({ show }) => {
    const [{ dateTime }, dispatch] = useContext(NewPostContext)
    const [times, setTimes] = useState()
    const [dates, setDates] = useState([])
    const [months, setMonths] = useState([])

    const handleDateSelect = dateTime => {
        console.log(dateTime)
        dispatch({
            type: 'setDateTime',
            dateTime: moment(dateTime)
        })
    }

    const today = moment()
    today.set({ hour: 0, minute: 0, second: 0, millisecond: 0 })

    const daysInMonth = today.daysInMonth()
    const allDates = Array.from(Array(daysInMonth).keys())

    const allMonths = [...Helpers.months]

    const years = [today.year(), today.add(1, 'y').year()]

    let allTimes = []
    const ap = ['am', 'pm']

    let i = 0
    while (i < 24 * 60) {
        var hh = Math.floor(i / 60); // getting hours of day in 0-24 format
        var mm = (i % 60); // getting minutes of the hour in 0-55 format
        allTimes.push({
            hour: hh,
            minute: mm,
            label: `${hh % 12 === 0 ? 12 : hh % 12}:${mm.toString().padStart(2, '0')} ${ap[Math.floor(hh / 12)]}`
        })

        i = i + 15
    }

    useEffect(() => {
        let startTime = dateTime.format('YYYYMD') === moment().format('YYYYMD') ? (moment().format('k') * 60) + (Math.ceil(moment().minute() / 15) * 15) : 0
        setTimes(allTimes.slice(startTime / 15))
        
        let startDate = dateTime.month() === moment().month() ? moment().date() - 1 : 0
        setDates(allDates.slice(startDate))
        
        let startMonth = dateTime.year() === moment().year() ? moment().month() : 0
        setMonths(allMonths.slice(startMonth))
    }, [dateTime])

    const presets = [
        {
            dateTime: moment(),
            label: "Now"
        },
        {
            dateTime: moment().add(1, 'hour').set({ minute: 0, second: 0, millisecond: 0 }),
            label: "Today"
        },
        {
            dateTime: moment().add(1, 'd').set({ hour: 12, minute: 0, second: 0, millisecond: 0 }),
            label: "Tomorrow"
        },
        {
            dateTime: moment().add(1, 'w').set({ hour: 12, minute: 0, second: 0, millisecond: 0 }),
            label: "Next Week"
        },
        {
            dateTime: moment(dateTime).set({ hour: 9, minute: 0, second: 0, millisecond: 0 }),
            label: "9:00 am"
        },
        {
            dateTime: moment(dateTime).set({ hour: 10, minute: 30, second: 0, millisecond: 0 }),
            label: "10:30 am"
        },
        {
            dateTime: moment(dateTime).set({ hour: 12, minute: 0, second: 0, millisecond: 0 }),
            label: "Noon"
        },
        {
            dateTime: moment(dateTime).set({ hour: 15, minute: 0, second: 0, millisecond: 0 }),
            label: "3:00p"
        },
    ]

    return (<div style={{ display: show ? 'block' : 'none' }} className="py-5">
        <p className="lead text-center mb-5">When do you want this post to go out?</p>
        <Form inline>
            <Form.Row className="justify-content-center align-items-center w-100 mb-4">
                <Calendar className="mr-2 text-muted" />
                <Form.Control as="select" className="mr-2" size="lg" onChange={e => handleDateSelect(dateTime.month(e.target.value))}>
                    {months.map((month, i) => {
                        let selected = dateTime.format('MMMM') === i
                        return <option value={i} selected={selected}>{month}</option>
                    })}
                </Form.Control>
                <Form.Control as="select" className="mr-2" size="lg" onChange={e => handleDateSelect(dateTime.date(e.target.value))}>
                    {dates.map(day => {
                        day = day + 1
                        let selected = dateTime.date() === day
                        return <option value={day} selected={selected}>{day}</option>
                    })}
                </Form.Control>
                <Form.Control as="select" className="mr-4" size="lg" onChange={e => handleDateSelect(dateTime.year(e.target.value))}>
                    {years.map(year => {
                        let selected = dateTime.year() === year
                        return <option value={year} selected={selected}>{year}</option>
                    })}
                </Form.Control>
                <Clock className="mr-2 text-muted" />
                <Form.Control as="select" size="lg" onChange={e => {
                    handleDateSelect(dateTime.set({
                        hour: e.target.selectedOptions[0].dataset.hour,
                        minute: e.target.selectedOptions[0].dataset.minute
                    }))
                }}>
                    {!times ? null : times.map(time => {
                        let selected = moment(dateTime).hour() === time.hour && moment(dateTime).minute() === time.minute
                        return <option data-minute={time.minute} data-hour={time.hour} selected={selected}>{time.label}</option>
                    })}
                </Form.Control>
            </Form.Row>
            <Form.Row className="justify-content-center align-items-center w-75 mx-auto" style={{ margin: '-4px' }}>
                {presets.map((p, i) => {
                    return (
                        <Button onClick={() => handleDateSelect(p.dateTime)} variant="outline-secondary" className="rounded-pill px-4 m-1" size="sm">{p.label}</Button>
                    )
                })}
            </Form.Row>
        </Form>
    </div>)
}

export default Schedule

Schedule.defaultProps = {
    label: 'Schedule'
}