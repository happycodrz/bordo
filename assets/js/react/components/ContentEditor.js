import React, { useState } from 'react'
import { EditorState, ContentState } from 'draft-js'
import Editor from 'draft-js-plugins-editor'

import createLinkifyPlugin from 'draft-js-linkify-plugin'
import createHashtagPlugin from 'draft-js-hashtag-plugin'

import 'draft-js-hashtag-plugin/lib/plugin.css'
import 'draft-js-linkify-plugin/lib/plugin.css'

const linkifyPlugin = createLinkifyPlugin()
const hashtagPlugin = createHashtagPlugin()

const ContentEditor = ({content, onChange, placeholder}) => {
    const startingState = content ? EditorState.createWithContent(ContentState.createFromText(content)) : EditorState.createEmpty()
    const [editorState, setEditorState] = useState(startingState)
    const [placeholderValue, setPlaceholderValue] = useState(placeholder)

    return (
        <Editor
            placeholder={placeholderValue}
            editorState={editorState}
            spellCheck={true}
            stripPastedStyles={true}
            onFocus={() => setPlaceholderValue('')}
            onBlur={e => {
                console.log(e.target.value)
                if(!e.target.value) {
                    setPlaceholderValue(placeholder)
                }
            }}
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