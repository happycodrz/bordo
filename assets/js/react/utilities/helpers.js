export const dateFormat = date => new Date(date).toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })

export const timeFormat = (date, short=false) => {
    let time = new Date(date)
    let hours = time.getHours() % 12
    hours = hours ? hours : 12
    let minutes = time.getMinutes().toString().padStart(2, '0')
    let ampm = hours >= 12 ? 'AM' : 'PM'

    if (!short) {
        return `${hours}:${minutes} ${ampm}`
    } else {
        let output = hours
        output = minutes !== '00' ? output + `:${minutes}` : output
        output += ampm.toLowerCase()[0]
        return output
    }
}

export const isPM = date => new Date(date).getHours() >= 12

export const createSlug = string => string.toLowerCase().replace(/\s/g, '-')

export const sentenceCase = string => string.split(' ').map(word => word[0].toUpperCase() + word.slice(1)).join(' ')

export const hexToRgb = hex => {
    let result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)

    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null
}

export const randomNotificationTitle = (type) => {
    const titles = {
        success: ['Woohoo!', 'Awww yeah!', 'Nice!', 'Heck yeah!', 'Go you!', 'Boom!', 'Crushing it!'],
        failure: ['Aw shucks!', 'Daggumit.', 'Oh boy...', 'Oh no!', 'Rats!', 'Bad news, buck-o.', 'Well this is embarassing...']
    }

    return titles[type][Math.floor(Math.random() * titles[type].length)]
}

export const months = ["January","February","March","April","May","June","July","August","September","October","November","December"]

export const componentPrefix = 'bdo-'

export const canvaApiKey = process.env.REACT_APP_CANVA_API

const INSTANT_LOAD = true
export const callWaiting = callback => {
    setTimeout(callback, INSTANT_LOAD ? 0 : Math.random() * 1000)
}