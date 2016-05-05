{ Emitter } = require 'atom'

module.exports =
class StatusView
    constructor: (serializedState) ->
        # Create root element
        div = document.createElement 'div'
        div.classList.add 'inline-block'

        @span = document.createElement 'span'
        @span.classList.add 'icon-info'
        @span.textContent = 'SPARQL endpoint idle.'
        div.appendChild @span

        @element = div

    # Returns an object that can be retrieved when package is activated
    serialize: ->

    # Tear down any state and detach
    destroy: ->
        @element.remove()

    getElement: ->
        @element

    handleQueryStart: (data) =>
        console.debug 'status update: query start = ', data
        @span.textContent = 'SPARQL query executing ...'
        @span.classList.add 'text-warning'

    handleQueryEnd: (data) =>
        console.debug 'status update: query end = ', data
        @span.textContent = 'SPARQL endpoint idle.'
        @span.classList.remove 'text-warning'

    trackQuery: (query) ->
        query.onDidQueryStart @handleQueryStart
        query.onDidQueryEnd @handleQueryEnd
