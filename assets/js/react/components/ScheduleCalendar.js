import React, { useState, useEffect } from 'react'

import Button from 'react-bootstrap/Button'
import OverlayTrigger from 'react-bootstrap/OverlayTrigger'
import Tooltip from 'react-bootstrap/Tooltip'

import { ChevronLeft, ChevronRight, CheckSquare, XSquare, Calendar } from 'react-feather'
import { Facebook, Twitter, LinkedIn } from './SocialLogos'
import { getPosts, updatePost } from '../utilities/api'
import { useStateValue } from '../state'
import NewPost from './NewPostModal'
import EditPostModal from './EditPostModal'
import { timeFormat, months, randomNotificationTitle } from '../utilities/helpers'
import { DragDropContext, Draggable, Droppable } from 'react-beautiful-dnd'

import moment from 'moment'

const CalendarHeader = ({ view }) => {
    const daysFull = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    const daysAbbr = ["Sun", "Mon", "Tues", "Wed", "Thurs", "Fri", "Sat"]
    const daysChar = ["S", "M", "T", "W", "Th", "F", "S"]

    const days = {
        full: daysFull,
        abbr: daysAbbr,
        char: daysChar,
    }

    return (
        <div className="calendar__header">
            {days[view].map((e, i) => <div key={i}>{e}</div>)}
        </div>
    )
}

const CalendarDayPosts = ({ index, today, post, onClick }) => {
    let { scheduled_for, title, post_variants } = post
    
    // let isPast = new Date(scheduled_for).getDate() < new Date().getDate()
    let isPast = moment(scheduled_for).isBefore(moment())
    let variant = isPast ? 'past' : 'future'

    const statusIcons = {
        posted: <CheckSquare size={8} />,
        failed: <XSquare size={8} />
    }

    const socialIcons = {
        facebook: <Facebook size={10} white />,
        twitter: <Twitter size={10} white />,
        linkedin: <LinkedIn size={10} white />
    }

    return (
        !isPast ?
            <OverlayTrigger
                placement="top"
                delay={{ show: 1000, hide: 500 }}
                overlay={<Tooltip className="small">
                    <strong>{title}</strong>
                </Tooltip>}
            >
                <Draggable
                    draggableId={post.id}
                    index={index}
                >
                    {(provided, snapshot) => (
                            <div
                                className={`bdo-scheduleCalendar__post bdo-scheduleCalendar__post--future`}
                                onClick={onClick}
                                ref={provided.innerRef}
                                {...provided.draggableProps}
                                {...provided.dragHandleProps}
                            >
                                <div className="d-flex align-items-center">
                                    <span className="text-truncate pr-1">{title}</span>
                                    <span>{timeFormat(scheduled_for, true)}</span>
                                </div>
                                <div className="d-flex align-items-center">
                                    <span>{post_variants.map(p => socialIcons[p.network])}</span>
                                </div>
                            </div>
                    )}
                </Draggable>
            </OverlayTrigger>
            :
            <div
                className={`bdo-scheduleCalendar__post bdo-scheduleCalendar__post--past`}
            >
                <div className="d-flex align-items-center">
                    <span className="text-truncate pr-1">{title}</span>
                    <span>{timeFormat(scheduled_for, true)}</span>
                </div>
                <div className="d-flex align-items-center">
                    <span>{post_variants.map(p => socialIcons[p.network])}</span>
                </div>
            </div>
    )
}

const CalendarDay = ({ date, today, muted, past, posts, handlePostClick }) => {
    let todayClass = today ? " calendar__day--today" : ""
    let mutedClass = muted ? " calendar__day--muted" : ""

    return (
        <div className={`calendar__day ${todayClass} ${mutedClass}`} key={date}>
            <sup>{date}</sup>
            {past && !muted ? 
                <div>
                    {!posts ? null :
                        posts.map((post, i) => <CalendarDayPosts key={i} post={post} onClick={() => handlePostClick(post)} index={i} />)
                    }
                </div>
            :
                <Droppable
                    droppableId={`${!muted ? '' : '_'}${date}`}
                >
                    {(provided, snapshot) => (
                        <div
                            ref={provided.innerRef}
                            style={{ backgroundColor: snapshot.isDraggingOver ? 'var(--light)' : 'transparent', minHeight: '100%', height: '100%' }}
                            {...provided.droppableProps}
                        >
                            {!posts ? null :
                                posts
                                    .sort((a, b) => new Date(a.scheduled_for) - new Date(b.scheduled_for))
                                    .map((post, i) => <CalendarDayPosts key={i} post={post} onClick={() => handlePostClick(post)} index={i} />)
                            }
                            {provided.placeholder}
                        </div>
                    )}
                </Droppable>
            }
        </div>
    )
}

const CalendarDays = ({ year, month }) => {
    const [{ activeBrand, posts }, dispatch] = useStateValue()
    const [activePost, setActivePost] = useState(null)
    const [key, setKey] = useState(0)
    const [showPostEditor, setShowPostEditor] = useState(false)

    const daysInMonth = new Date(year, month + 1, 0).getDate()
    const startingDay = new Date(year, month, 1).getDay()
    const endingDay = new Date(year, month + 1, 0).getDay()
    const lastMonthEndingDate = new Date(year, month, -1).getDate()

    let days = Array.from(Array(daysInMonth).keys()).map((e, i) => ({ date: i, muted: false }))

    days = !posts.length ? days : days.map(x => {
        let todaysPosts = posts.filter(y => {
            return new Date(Date.parse(y.scheduled_for)).getDate() - 1 === x.date
        }) || null
        x.posts = todaysPosts
        return x
    })

    const previousMonthDays = startingDay ? new Array(startingDay).fill().map((item, index) => ({ date: lastMonthEndingDate - index, muted: true })).reverse() : []
    const nextMonthDays = Array.from(Array(6 - endingDay).keys()).map((e, i) => ({ date: i, muted: true }))
    const currentDay = new Date().setHours(0, 0, 0, 0)

    const handlePostClick = post => {
        if (!activePost) {
            setActivePost(post)
        }
    }

    return (
        <>
            {!activePost ? null : <EditPostModal post={activePost} show={activePost} handleShow={() => setActivePost(false)} key={key} />}
            <DragDropContext
                onDragEnd={result => {
                    const {draggableId, source, destination} = result

                    if (!destination)
                        return

                    if (destination.droppableId === source.droppableId)
                        return

                    let updatedPost = posts.filter(p => p.id === draggableId)[0]
                    let newDate = moment.utc(updatedPost.scheduled_for).set('date', destination.droppableId).format()
                    updatedPost.scheduled_for = newDate

                    console.log(updatedPost)

                    dispatch({
                        type: 'updatePost',
                        data: {
                            id: draggableId,
                            post: updatedPost
                        }
                    })

                    updatePost(activeBrand.id, draggableId, {
                        post: updatedPost
                    })
                }}
            >
                <div className="calendar__body">
                    {previousMonthDays.map((e, i) => {
                        return (
                            <CalendarDay
                                key={i}
                                posts={e.posts}
                                muted={true}
                                date={e.date !== null ? e.date + 1 : ''}
                            />
                        )
                    })}
                    {days.map((e, i) => {
                        return (
                            <CalendarDay
                                key={i}
                                posts={e.posts}
                                muted={e.muted}
                                past={moment(`${e.date + 1} 00:00:00`, 'DD hh:mm:ss').isBefore(moment('00:00:00', 'hh:mm:ss'))}
                                today={currentDay === new Date(year, month, e.date + 1).getTime()}
                                date={e.date !== null ? e.date + 1 : ''}
                                handlePostClick={handlePostClick}
                            />  
                        )
                    })}
                    {nextMonthDays.map((e, i) => {
                        return (
                            <CalendarDay
                                key={i}
                                posts={e.posts}
                                muted={true}
                                date={e.date !== null ? e.date + 1 : ''}
                            />
                        )
                    })}
                </div>
            </DragDropContext>
        </>
    )
}

const ScheduleCalendar = () => {
    const [{ activeBrand, posts }, dispatch] = useStateValue()

    const [month, setMonth] = useState(new Date().getMonth())
    const [year, setYear] = useState(new Date().getFullYear())
    const [showSpinner, setShowSpinner] = useState(false)

    const setPosts = posts => dispatch({ type: 'setPosts', posts: posts })

    useEffect(() => {
        setShowSpinner(true)
        getPosts(activeBrand.id, year, month)
            .then(posts => {
                if (posts) {
                    setPosts(posts)
                }
                setShowSpinner(false)
            })
            .catch(error => {
                dispatch({
                    type: 'addNotification',
                    data: {
                        title: randomNotificationTitle('failure'),
                        body: error.message,
                        variant: 'danger'
                    }
                })
            })
    }, [month])

    const nextMonth = () => {
        setPosts([])
        if (month + 1 === months.length) {
            setYear(year + 1)
            setMonth(0)
        } else {
            setMonth(month + 1)
        }
    }

    const prevMonth = () => {
        setPosts([])
        if (month - 1 < 0) {
            setYear(year - 1)
            setMonth(months.length - 1)
        } else {
            setMonth(month - 1)
        }
    }

    return (
        <section className="bdo-scheduleCalendar">
            <header className="d-flex align-items-center justify-content-between">
                <h1><strong>{months[month]}</strong> {year}</h1>
                <div>
                    <Button variant="link" onClick={prevMonth}><ChevronLeft /></Button>
                    <Button variant="link" onClick={nextMonth}><ChevronRight /></Button>
                </div>
            </header>
            <div className="calendar__loader" style={{ display: showSpinner ? 'flex' : 'none' }}>
                <div className="spinner-border text-primary" role="status">
                    <span className="sr-only">Loading...</span>
                </div>
            </div>
            <CalendarHeader view="full" />
            <CalendarDays year={year} month={month} />
        </section>
    )
}

export default ScheduleCalendar