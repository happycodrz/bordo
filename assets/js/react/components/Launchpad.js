import React from 'react'

import { navigate } from '@reach/router'

import Card from 'react-bootstrap/Card'
import CardDeck from 'react-bootstrap/CardDeck'
import { Send, Calendar, Image } from 'react-feather'

const LaunchpadCard = ({ icon, title, variant, link, action }) => {
  return (
    <Card
      onClick={() => (action ? action() : navigate(link))}
      style={{ textDecoration: 'none' }}
      className="text-dark bdo-launchpadCard"
    >
      <Card.Body>
        <div
          className={`mb-5 bg-${variant} rounded-circle d-flex align-items-center justify-content-center mx-auto text-white`}
          style={{ width: 75, height: 75, marginTop: '-24%' }}
        >
          {icon}
        </div>
        <Card.Title className="mb-5 h5">{title}</Card.Title>
      </Card.Body>
      <Card.Footer className={`bg-${variant} text-light`}>
        Let's go!
      </Card.Footer>
    </Card>
  )
}

const Launchpad = ({ brandSlug }) => {
  let launchpadCards = [
    {
      icon: <Send size={40} />,
      title: 'Schedule a new post',
      variant: 'primary',
      action: () => document.getElementById('newPostButton').click(),
    },
    {
      icon: <Calendar size={40} />,
      title: 'See my upcoming posts',
      variant: 'danger',
      link: `/${brandSlug}/schedule`,
    },
    {
      icon: <Image size={40} />,
      title: 'Upload a new image or graphic',
      variant: 'success',
      link: `/${brandSlug}/media`,
    },
  ]

  return (
    <CardDeck className="pt-5">
      {launchpadCards.map((card) => (
        <LaunchpadCard
          icon={card.icon}
          title={card.title}
          variant={card.variant}
          link={card.link}
          action={card.action}
        />
      ))}
    </CardDeck>
  )
}

export default Launchpad
