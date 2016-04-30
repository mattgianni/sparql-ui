{ScrollView,TextEditorView} = require 'atom-space-pen-views'

module.exports =
class EndpointViewClass extends ScrollView
    constructor: (serializedState) ->
        @props = serializedState
        super

    @content: ->
        @div =>
            @div "Type your answer:"
            @subview 'answer', new TextEditorView(mini: true, placeholderText: 'Edit Me')

    initialize: ->
        super
        # @text('super long content that will scroll')

    getTitle: ->
        return 'Endpoint Configuration'
