import React from "react"

import { navigate } from '@reach/router'

import geometry from '../assets/geometry2.png'
import { useStateValue } from "../state"
import Card from "react-bootstrap/Card"
import CardDeck from "react-bootstrap/CardDeck"
import { Send, Calendar, Image } from "react-feather"
import UnsplashSearchModal from "./UnsplashSearch"

const LaunchpadCard = ({icon, title, variant, link, action}) => {
    return (
        <Card onClick={() => action ? action() : navigate(link)} style={{ textDecoration: 'none' }} className="text-dark bdo-launchpadCard">
            <Card.Body>
                <div class={`mb-5 bg-${variant} rounded-circle d-flex align-items-center justify-content-center mx-auto text-white`} style={{ width: 75, height: 75, marginTop: '-24%' }}>{icon}</div>
                <Card.Title class="mb-5 h5">{title}</Card.Title>
            </Card.Body>
            <Card.Footer className={`bg-${variant} text-light`}>Let's go!</Card.Footer>
        </Card>
    )
}

const Launchpad = () => {
    const [{ activeUser }] = useStateValue()

    let greetings = ['Hello', 'Welcome back', 'Howdy', 'What\'s up', 'Hola', 'Sup', 'Hey', 'Hey there']
    let greeting = greetings[Math.floor(Math.random() * greetings.length)]
    let first_name = activeUser.first_name || activeUser.email

    let launchpadCards = [
        { icon: <Send size={40} />, title: 'Schedule a new post', variant: 'primary', action: () => document.getElementById('newPostButton').click() },
        { icon: <Calendar size={40} />, title: 'See my upcoming posts', variant: 'danger', link: '/schedule' },
        { icon: <Image size={40} />, title: 'Upload a new image or graphic', variant: 'success', link: '/media' },
    ]

    return (
        <section className="h-100 d-flex align-items-center justify-content-center" style={{ backgroundImage: `url(${geometry})` }}>
            <header className="text-center">
                <p className="h2">{greeting}, <span className="text-primary">{first_name}</span>! <span className="wave" role="img">👋</span></p>
                <h1 className="mb-5">What do you want to accomplish today?</h1>
                <CardDeck className="pt-5">
                    {launchpadCards.map(card => <LaunchpadCard icon={card.icon} title={card.title} variant={card.variant} link={card.link} action={card.action} />)}
                </CardDeck>
            </header>
        </section>
    )
}

export default Launchpad
