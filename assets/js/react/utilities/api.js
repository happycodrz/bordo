import { createSlug } from '../utilities/helpers'
import Cookies from 'js-cookie'

const AUTH_TOKEN = Cookies.get('bdo-logged-in')

const API_ROOT_URL = process.env.REACT_APP_API_ENDPOINT

const GET_OPTIONS = {
    headers: {
        'Authorization': `Bearer ${AUTH_TOKEN}`
    }
}

const POST_OPTIONS = body => ({
    method: 'POST',
    headers: {
        'Authorization': `Bearer ${AUTH_TOKEN}`,    
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(body)
})

const PUT_OPTIONS = body => ({
    method: 'PUT',
    headers: {
        'Authorization': `Bearer ${AUTH_TOKEN}`,    
        'Content-Type': 'application/json'
    },
    body: JSON.stringify(body)
})

const DELETE_OPTIONS = {
    method: 'DELETE',
    headers: {
        'Authorization': `Bearer ${AUTH_TOKEN}`
    }
}

export const getUser = uuid => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/profile`, GET_OPTIONS)
            .then(res => res.json())
            .then(json => resolve(json.data))
            .catch(err => reject(err))
    })
}

export const getAllUsers = brandUuid => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands/${brandUuid}/users`, GET_OPTIONS)
            .then(res => {
                if(res.status === 200) {
                    return res.json()
                } else {
                    reject({message: 'Could not get users. Try again later.'})
                }
            })
            .then(json => resolve(json.data))
            .catch(err => reject(err))
    })
}

export const getAllBrands = () => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands`, GET_OPTIONS)
            .then(res => {
                if(res.status === 200) {
                    return res.json()
                } else {
                    reject({message: 'Unable to authenticate, try logging in again.'})
                }
            })
            .then(json => resolve(json.data))
            .catch(err => reject(err))
    })
}

export const getPosts = (brandId, year, month) => {
    let startDate = new Date(year, month, 1).toISOString()
    let endDate = new Date(year, month + 1, 0).toISOString()

    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands/${brandId}/posts?scheduled_for_after=${startDate}&scheduled_for_before=${endDate}`, GET_OPTIONS)
            .then(res => {
                if(res.status === 200) {
                    return res.json()
                } else {
                    reject({message: 'Could not get posts. Try again later.'})
                }
            })
            .then(json => resolve(json.data))
            .catch(err => reject(err))
    })
}

export const schedulePost = (brandId, body) => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands/${brandId}/posts`, POST_OPTIONS(body))
            .then(res => {
                if(res.status === 201) {
                    return res.json()
                } else {
                    reject({message: 'Could not schedule post. Try again later.'})
                }
            })
            .then(json => resolve(json.data))
            .catch(err => reject(err))
    })
}

export const updatePost = (brandId, postId, body) => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands/${brandId}/posts/${postId}`, POST_OPTIONS(body))
            .then(res => res.json())
            .then(json => resolve(json.data))
            .catch(err => reject(err))
    })
}

export const deletePost = (brandId, postId) => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands/${brandId}/posts/${postId}`, DELETE_OPTIONS)
            .then(() => resolve({ message: `Post has been deleted.` }) )
            .catch(err => reject(err))
    })
}

export const addNewBrand = brandName => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands`, POST_OPTIONS({
            "brand": {
                "name": brandName,
                "slug": createSlug(brandName)
            }
        }))
        .then(res => {
            if(res.status === 201) {
                return res.json()
            } else {
                reject({message: 'Could not create brand. Try again later.'})
            }
        })
        .then(json => resolve(json.data))
        .catch(err => reject(err))
    })
}

export const deleteBrand = (brandId) => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands/${brandId}`, DELETE_OPTIONS)
            .then(() => resolve({ message: `Brand has been deleted.` }) )
            .catch(err => reject(err))
    })
}

export const getChannels = brandId => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands/${brandId}/channels`, GET_OPTIONS)
            .then(res => {
                if(res.status === 200) {
                    return res.json()
                } else {
                    reject({message: 'Could not get channels. Try again later.'})
                }
            })
            .then(json => resolve(json.data))
            .catch(err => reject(err))
    })
}

export const getChannelAuth = (brandId, channel) => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/providers/${channel}/auth?brand_id=${brandId}`, GET_OPTIONS)
            .then(res => res.json())
            .then(json => resolve(json))
            .catch(err => reject(err))
    })
}

export const getChannelCallback = (channel, queryString) => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/providers/${channel}/callback${queryString}`, GET_OPTIONS)
            .then(res => res.json())
            .then(json => {
                if (json.error) {
                    reject(json.error)
                } else {
                    resolve(json.data)
                }
            })
            .catch(err => reject(err))
    })
}

export const addNewChannel = (brandId, channel) => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands/${brandId}/channels`, POST_OPTIONS({
            "channel": channel
        }))
            .then(res => {
                if(res.status === 201) {
                    return res.json()
                } else {
                    reject({message: 'Could not add new social channel. Try again later.'})
                }
            })
            .then(json => resolve(json.data))
            .catch(err => reject(err))
    })
}

export const deleteChannel = (brandId, channelId) => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands/${brandId}/channels/${channelId}`, DELETE_OPTIONS)
            .then(() => resolve({ message: `Channel has been deleted.` }) )
            .catch(err => reject(err))
    })
}

export const getMedia = brandId => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands/${brandId}/media`, GET_OPTIONS)
            .then(res => {
                if(res.status === 200) {
                    return res.json()
                } else {
                    reject({message: 'Could not get media. Try again later.'})
                }
            })
            .then(json => resolve(json.data))
            .catch(err => reject(err))
    })
}

export const createMedia = (brandId, title, {public_id, width, height, resource_type, bytes, created_at, secure_url, eager}) => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands/${brandId}/media`, POST_OPTIONS({
            "media": {
                "upload_date": created_at,
                "title": title,
                "public_id": public_id,
                "bytes": bytes,
                "width": width,
                "height": height,
                "resource_type": resource_type,
                "url": secure_url,
                "thumbnail_url": eager[0].secure_url,
            }
        }))
            .then(res => {
                if(res.status === 201) {
                    return res.json()
                } else {
                    reject({message: 'Could not add media. Try again later.'})
                }
            })
            .then(json => resolve(json.data))
            .catch(err => reject(err))
    })
}

export const deleteMedia = (brandId, mediaId) => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands/${brandId}/media/${mediaId}`, DELETE_OPTIONS)
            // .then(re s => res.json())
            .then(() => resolve({ message: `Media item #${mediaId} has been deleted.` }) )
            .catch(err => reject(err))
    })
}

export const updateBrand = (brandId, body) => {
    return new Promise((resolve, reject) => {
        fetch(`${API_ROOT_URL}/brands/${brandId}`, PUT_OPTIONS(body))
            .then(res => res.json())
            .then(json => resolve(json.data))
            .catch(err => reject(err))
    })
}