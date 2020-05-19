import { callWaiting } from './utilities/helpers'

// `${endpoint}/posts/?startDate=###&endDate=###`

const channels = [
    {
        "network": "facebook",
        "token": "1219317465982951424-z3KmF3yoep3sJrpSHdkFQIKWjz39Pi",
        "token_secret": "4tE8B7yD54O1uZFvJ6bSwyfAJog5XrmE5sr8tYFxm4hbG",
        "uuid": "f771cafe"
    },
    {
        "network": "twitter",
        "token": "1219317465982951424-z3KmF3yoep3sJrpSHdkFQIKWjz39Pi",
        "token_secret": "4tE8B7yD54O1uZFvJ6bSwyfAJog5XrmE5sr8tYFxm4hbG",
        "uuid": "f771caff"
    },
    {
        "network": "instagram",
        "token": "1219317465982951424-z3KmF3yoep3sJrpSHdkFQIKWjz39Pi",
        "token_secret": "4tE8B7yD54O1uZFvJ6bSwyfAJog5XrmE5sr8tYFxm4hbG",
        "uuid": "f771cafg"
    },
    // { name: 'LinkedIn', uuid: 'defghi', active: false, username: '/in/piedpiper' },
    // { name: 'Google My Business', uuid: 'efghij', active: false, username: null },
    // { name: 'Pinterest', uuid: 'fghijk', active: false, username: '/piedpiper' },
]

const brands = [
    {
        "uuid": "zX3F2Mar",
        "name": "Pied Piper",
        "icon_url": "/zX3F2Mar_400x400.jpg",
        "created_at": "2020-02-18T14:06:20.818326+00:00",
        "updated_at": "2020-02-18T14:06:20.818326+00:00"
    },
    {
        "uuid": "useV72GN",
        "name": "Git Bent",
        "icon_url": "/useV72GN_400x400.png",
        "created_at": "2020-02-18T14:06:20.818326+00:00",
        "updated_at": "2020-02-18T14:06:20.818326+00:00"
    },
    {
        "uuid": "oROpi2Ew",
        "name": "Alloy",
        // "icon_url": "/oROpi2Ew_400x400.jpg",
        "created_at": "2020-02-18T14:06:20.818326+00:00",
        "updated_at": "2020-02-18T14:06:20.818326+00:00"
    },
]

const assets = [
    {
        uuid: "abc123",
        title: "This is the title of the image",
        date: "2020-02-18T14:06:20.818326+00:00",
        type: "image",
        media: {
            thumbnail: "/abc123_thumb.jpg",
            url: "/abc123.jpg"
        },
    },
    {
        uuid: "bcd234",
        title: "This is another image",
        date: "2020-02-18T14:06:20.818326+00:00",
        type: "image",
        media: {
            thumbnail: "/bcd234_thumb.jpg",
            url: "bcd234.jpg"
        },
    },
    {
        uuid: "cde345",
        title: "spring_sale_2020",
        date: "2020-02-18T14:06:20.818326+00:00",
        type: "video",
        media: {
            thumbnail: "/cde345_thumb.jpg",
            url: "/cde345.jpg"
        },
    },
    {
        uuid: "def456",
        title: "short",
        date: "2020-02-18T14:06:20.818326+00:00",
        type: "image",
        media: {
            thumbnail: "/def456_thumb.jpg",
            url: "/def456.jpg"
        },
    },
]

export const getUser = () => {
    return new Promise((resolve, reject) => {
        callWaiting(() => {
            resolve({
                "uuid": 'abc123',
                "first_name": "Michael",
                "last_name": "Panik",
                "email": "michaelpanik92@gmail.com",
                "user_type": "employee"
            })
        })
    })
}

export const getBrand = uuid => {
    return new Promise((resolve, reject) => {
        callWaiting(() => {
            brands.forEach(brand => {
                if(brand.uuid === uuid) {
                    resolve(brand)
                }
            })

            reject(new Error(`Could not find brand ${uuid}`))
        })
    })
}

export const getAllBrands = () => {
    return new Promise((resolve, reject) => {
        callWaiting(() => {
            resolve(brands)

            reject(new Error(`Could not load brands.`))
        })
    })
}

export const addNewBrand = brandName => {
    return new Promise((resolve, reject) => {
        callWaiting(() => {
            resolve({
                "uuid": "95643eaf",
                "id": 22,
                "name": brandName,
            })
        
            reject(new Error(`Could not load brands.`))
        })
    })
}

export const getEvents = (year, month) => {
    return new Promise((resolve, reject) => {
        callWaiting(() => {
            if (month === 3) {
                resolve({
                    "events": [
                        {
                            title: "Spring sale teaser",
                            datetime: "2020-04-08T14:06:20.818326+00:00",
                        },
                        {
                            title: "Spring sale announcement post number one",
                            datetime: "2020-04-03T14:06:20.818326+00:00",
                        },
                        {
                            title: "New hours announcement",
                            datetime: "2020-04-13T14:06:20.818326+00:00",
                        },
                        {
                            title: "Spring sale 2",
                            datetime: "2020-04-18T14:06:20.818326+00:00",
                        },
                        {
                            title: "COVID-19 announcement",
                            datetime: "2020-04-18T14:06:20.818326+00:00",
                        },
                        {
                            title: "Giveaway teaser",
                            datetime: "2020-04-26T14:06:20.818326+00:00",
                        },
                    ]
                })
            } else {
                resolve({"events": []})
            }

            reject(new Error(`Could not load events.`))
        })
    })
}

export const getMedia = () => {
    return new Promise((resolve, reject) => {
        callWaiting(() => {
            resolve(assets)

            reject(new Error(`Could not load events.`))
        })
    })
}

export const getChannels = () => {
    return new Promise((resolve, reject) => {
        callWaiting(() => {
            resolve(channels)

            reject(new Error(`Could not load networks.`))
        })
    })
}

export const schedulePost = (body) => {
    return new Promise((resolve, reject) => {
        callWaiting(() => {
            resolve(body)

            reject(new Error(`Could not load networks.`))
        })
    })
}