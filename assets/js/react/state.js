import React, { createContext, useContext, useReducer } from 'react'

export const StateContext = createContext()

export const EIStateProvider = ({ reducer, initialState, children }) => (
  <StateContext.Provider value={useReducer(reducer, initialState)}>
    {children}
  </StateContext.Provider>
)

export const useStateValue = () => useContext(StateContext)

export const reducer = (state, action) => {
  switch (action.type) {
    case 'setActiveUser':
      return {
        ...state,
        activeUser: action.data,
      }

    case 'setActiveBrand':
      return {
        ...state,
        assets: null,
        posts: [],
        loadingBrand: false,
        activeBrand: action.data,
      }

    case 'updateBrand':
      let modifiedBrand = state.brands.findIndex(
        (e) => e.id === action.brand.id,
      )
      return {
        ...state,
        brands: [
          ...state.brands.slice(0, modifiedBrand),
          action.brand,
          ...state.brands.slice(modifiedBrand + 1),
        ],
      }

    case 'setLoadingBrand':
      return {
        ...state,
        loadingBrand: action.data,
      }

    case 'setBrands':
      return {
        ...state,
        brands: action.data,
      }

    case 'addBrand':
      let brands = state.brands || []
      brands = [...brands, action.brand]
      return {
        ...state,
        brands: brands,
      }

    case 'setPosts':
      return {
        ...state,
        posts: action.posts,
      }

    case 'addPosts': {
      let posts = state.posts || []
      posts = [...posts, action.posts]
      return {
        ...state,
        posts: posts,
      }
    }

    case 'deletePost': {
      let posts = state.posts
      posts = posts.filter((post) => post.id !== action.postId)
      return {
        ...state,
        posts: posts,
      }
    }

    case 'updatePost': {
      let posts = [...state.posts]
      let postIndex = posts.findIndex((p) => p.id === action.data.id)
      posts.splice(postIndex, 1, action.data.post)

      return {
        ...state,
        posts: posts,
      }
    }

    case 'setAssets':
      return {
        ...state,
        assets: action.assets,
      }

    case 'addNotification':
      return {
        ...state,
        notifications: [action.data],
      }

    case 'deleteNotification':
      const newNotifications = state.notifications.filter(
        (e) => e.id !== action.id,
      )

      return {
        ...state,
        notifications: newNotifications,
      }

    default:
      return { ...state }
  }
}

export let initialAppState = {
  loadingBrand: false,
  activeBrand: null,
  brands: null,
  activeUser: null,
  posts: [],
  assets: null,
  notifications: [],
}
