let AUTH_TOKEN

if (document.querySelector(`meta[name="auth-token"]`)) {
  AUTH_TOKEN = document
    .querySelector(`meta[name="auth-token"]`)
    .getAttribute('content')
} else {
  AUTH_TOKEN = ''
}

const API_ROOT_URL = process.env.REACT_APP_API_ENDPOINT || ''

const GET_OPTIONS = {
  headers: {
    Authorization: `Bearer ${AUTH_TOKEN}`,
  },
}

const POST_OPTIONS = (body) => ({
  method: 'POST',
  headers: {
    Authorization: `Bearer ${AUTH_TOKEN}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify(body),
})

const PUT_OPTIONS = (body) => ({
  method: 'PUT',
  headers: {
    Authorization: `Bearer ${AUTH_TOKEN}`,
    'Content-Type': 'application/json',
  },
  body: JSON.stringify(body),
})

const DELETE_OPTIONS = {
  method: 'DELETE',
  headers: {
    Authorization: `Bearer ${AUTH_TOKEN}`,
  },
}

const errorHandler = (error, reject) => {
  if (error.status === 401) {
    window.location = process.env.REACT_APP_LOGIN_URL
  } else {
    reject(error)
  }
}

/* --- */

export const schedulePost = (brandId, body) => {
  return new Promise((resolve, reject) => {
    fetch(`${API_ROOT_URL}/brands/${brandId}/posts`, POST_OPTIONS(body))
      .then((res) => {
        if (res.status === 201) {
          return res.json()
        } else {
          reject({ message: 'Could not schedule post. Try again later.' })
        }
      })
      .then((json) => resolve(json.data))
      .catch((err) => errorHandler(err, reject))
  })
}

export const getChannels = (brandId) => {
  return new Promise((resolve, reject) => {
    fetch(`${API_ROOT_URL}/brands/${brandId}/channels`, GET_OPTIONS)
      .then((res) => {
        if (res.status === 200) {
          return res.json()
        } else {
          reject({ message: 'Could not get channels. Try again later.' })
        }
      })
      .then((json) => resolve(json.data))
      .catch((err) => errorHandler(err, reject))
  })
}

export const getMedia = (brandId) => {
  return new Promise((resolve, reject) => {
    fetch(`${API_ROOT_URL}/brands/${brandId}/media`, GET_OPTIONS)
      .then((res) => {
        if (res.status === 200) {
          return res.json()
        } else {
          reject({ message: 'Could not get media. Try again later.' })
        }
      })
      .then((json) => resolve(json.data))
      .catch((err) => errorHandler(err, reject))
  })
}

export const createMedia = (
  brandId,
  title,
  {
    public_id,
    width,
    height,
    resource_type,
    bytes,
    created_at,
    secure_url,
    eager,
  },
) => {
  return new Promise((resolve, reject) => {
    fetch(
      `${API_ROOT_URL}/brands/${brandId}/media`,
      POST_OPTIONS({
        media: {
          upload_date: created_at,
          title: title,
          public_id: public_id,
          bytes: bytes,
          width: width,
          height: height,
          resource_type: resource_type,
          url: secure_url,
          thumbnail_url: eager[0].secure_url,
        },
      }),
    )
      .then((res) => {
        if (res.status === 201) {
          return res.json()
        } else {
          reject({ message: 'Could not add media. Try again later.' })
        }
      })
      .then((json) => resolve(json.data))
      .catch((err) => errorHandler(err, reject))
  })
}

export const updateMedia = (brandId, mediaId, { title }) => {
  return new Promise((resolve, reject) => {
    fetch(
      `${API_ROOT_URL}/brands/${brandId}/media/${mediaId}`,
      PUT_OPTIONS({
        media: {
          title: title,
        },
      }),
    )
      .then((res) => {
        if (res.status === 200) {
          return res.json()
        } else {
          reject({ message: 'Could not update media. Try again later.' })
        }
      })
      .then((json) => resolve(json.data))
      .catch((err) => errorHandler(err, reject))
  })
}

export const deleteMedia = (brandId, mediaId) => {
  return new Promise((resolve, reject) => {
    fetch(`${API_ROOT_URL}/brands/${brandId}/media/${mediaId}`, DELETE_OPTIONS)
      // .then(re s => res.json())
      .then(() =>
        resolve({ message: `Media item #${mediaId} has been deleted.` }),
      )
      .catch((err) => errorHandler(err, reject))
  })
}

export const updateBrand = (brandId, body) => {
  return new Promise((resolve, reject) => {
    fetch(`${API_ROOT_URL}/brands/${brandId}`, PUT_OPTIONS(body))
      .then((res) => res.json())
      .then((json) => resolve(json.data))
      .catch((err) => errorHandler(err, reject))
  })
}
