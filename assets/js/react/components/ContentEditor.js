import React, { useState } from 'react'
import { EditorState, ContentState } from 'draft-js'
import Editor from 'draft-js-plugins-editor'

import createLinkifyPlugin from 'draft-js-linkify-plugin'
import createHashtagPlugin from 'draft-js-hashtag-plugin'
import createCounterPlugin from 'draft-js-counter-plugin'

import 'draft-js-hashtag-plugin/lib/plugin.css'
import 'draft-js-linkify-plugin/lib/plugin.css'

const linkifyPlugin = createLinkifyPlugin()
const hashtagPlugin = createHashtagPlugin()
const counterPlugin = createCounterPlugin()

const { CharCounter } = counterPlugin

const ContentEditor = ({content, onChange, placeholder, characterCount}) => {
    content = characterCount ? content.substring(0, characterCount-1) : content
    const startingState = content ? EditorState.createWithContent(ContentState.createFromText(content)) : EditorState.createEmpty()
    const [editorState, setEditorState] = useState(startingState)
    const [placeholderValue, setPlaceholderValue] = useState(placeholder)

    return (
        <>
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
                    const contentState = e.getCurrentContent()
                    const oldContent = editorState.getCurrentContent()

                    if(!characterCount || contentState === oldContent || contentState.getPlainText().length <= characterCount) {
                        onChange(e.getCurrentContent().getPlainText())
                        setEditorState(e)
                    } else {
                        e = EditorState.moveFocusToEnd(
                            EditorState.push(
                                e,
                                ContentState.createFromText(oldContent.getPlainText())
                            )
                        )

                        onChange(e.getCurrentContent().getPlainText())
                        setEditorState(e)
                    }
                }}
                plugins={[
                    linkifyPlugin,
                    hashtagPlugin,
                    counterPlugin
                ]}
            />
            {!characterCount ? null : <div className="text-right text-muted small"><CharCounter editorState={editorState} />/{characterCount}</div>}
        </>
    )
}

export default ContentEditor