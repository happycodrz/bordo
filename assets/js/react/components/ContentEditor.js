import React, { useState } from 'react'
import { EditorState, ContentState } from 'draft-js'
import Editor from 'draft-js-plugins-editor'

import createLinkifyPlugin from 'draft-js-linkify-plugin'
import createHashtagPlugin from 'draft-js-hashtag-plugin'

import 'draft-js-hashtag-plugin/lib/plugin.css'
import 'draft-js-linkify-plugin/lib/plugin.css'

const linkifyPlugin = createLinkifyPlugin()
const hashtagPlugin = createHashtagPlugin()

const ContentEditor = ({content, onChange}) => {
    const startingState = content ? EditorState.createWithContent(ContentState.createFromText(content)) : EditorState.createEmpty()
    const [editorState, setEditorState] = useState(startingState)

    return (
        <Editor
            editorState={editorState}
            onChange={e => {
                onChange(e.getCurrentContent().getPlainText())
                setEditorState(e)
            }}
            plugins={[
                linkifyPlugin,
                hashtagPlugin
            ]}
        />
    )
}

export default ContentEditor