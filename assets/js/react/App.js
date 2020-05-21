import React from "react"

import { EIStateProvider } from './state'

import { Router, Redirect } from "@reach/router"

import Layout from "./Layout"
import Loader from "./components/Loader"
import StateInitializer from "./components/StateInitializer"

import { navigationList } from './utilities/navigation'
import Launchpad from "./components/Launchpad"
import Schedule from "./components/Schedule"
import Reports from "./components/Reports"
import Settings from "./components/Settings"
import Media from './components/Media'
import Complete from "./components/OAuth/Complete"
import LinkedIn from "./components/OAuth/LinkedIn"
import OAuth from "./components/OAuth/OAuth"

const App = () => {

    let initialState = {
        loadingBrand: false,
        activeBrand: null,
        brands: null,
        activeUser: null,
        posts: [],
        assets: null,
        notifications: []
    }

    const reducer = (state, action) => {
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
                let modifiedBrand = state.brands.findIndex(e => e.id === action.brand.id)
                return {
                    ...state,
                    brands: [...state.brands.slice(0, modifiedBrand), action.brand, ...state.brands.slice(modifiedBrand + 1)]
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
                    brands: brands
                }
            
            case 'setPosts':
                return {
                    ...state,
                    posts: action.posts
                }
            
            case 'addPosts': {
                let posts = state.posts || []
                posts = [...posts, action.posts]    
                return {
                    ...state,
                    posts: posts
                }
            }

            case 'deletePost': {
                let posts = state.posts
                posts = posts.filter(post => post.id !== action.postId)
                return {
                    ...state,
                    posts: posts
                }
            }

            case 'updatePost': {
                let posts = [...state.posts]
                let postIndex = posts.findIndex(p => p.id === action.data.postId)
                posts.splice(postIndex, 1)
                posts.push(action.data.post)

                return {
                    ...state,
                    posts: posts
                }
            }

            case 'setAssets':
                return {
                    ...state,
                    assets: action.assets
                }

            case 'addNotification':
                return {
                    ...state,
                    notifications: [
                        ...state.notifications,
                        action.data
                    ]
                }

            case 'deleteNotification':
                const newNotifications = state.notifications.filter(e => e.id !== action.id)

                return {
                    ...state,
                    notifications: newNotifications
                }

            default:
                return {...state}
        }
    }

    const pageComponents = {
        Launchpad,
        Schedule,
        Reports,
        Settings,
        Media,
    }

    return (
        <EIStateProvider initialState={initialState} reducer={reducer}>
            <StateInitializer
                loading={<Loader />}
            >
                <Router>
                    <OAuth path="oauth">
                        <Complete path="complete"/>
                        <LinkedIn path="linkedin" />
                    </OAuth>
                    <Layout path="/">
                        <div className="bdo-brandWorkspace" path=":brandSlug">
                            {navigationList.map((e, i) => {
                                const Component = pageComponents[e.componentName]

                                return (
                                    <Component path={e.path} key={i} />
                                )
                            })}
                        </div>
                    </Layout>
                </Router>
            </StateInitializer>
        </EIStateProvider>
    )
}

export default App
