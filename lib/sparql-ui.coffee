{CompositeDisposable} = require 'atom'
SparqlView = require './sparql-ui-view'
# EndpointView = require './sparql-ui-endpoint'
url = require 'url'

module.exports = SparqlUi =
    config:
        showQuery:
            type: 'boolean'
            default: false
            title: 'Show query in results report'
        showElapsed:
            type: 'boolean'
            default: false
            title: 'Show the elapsed time in results report'

    sparqlView: null
    endpointView: null
    modalPanel: null
    subscriptions: null
    data: null

    activate: (state) ->
        console.debug('sparql-ui:activate(' + JSON.stringify(state) + ')')
        if state?.version == 1
            @data = state
        else
            @data =
                version: 1
                endpoint: 'http://dbpedia.org/sparql'

        @sparqlView = new SparqlView(@data)
        # @endpointView = new EndpointView(@data)

        # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
        @subscriptions = new CompositeDisposable

        # Register command that toggles this view
        @subscriptions.add atom.commands.add 'atom-workspace', 'sparql-ui:configure': => @configure()
        @subscriptions.add atom.commands.add 'atom-workspace', 'sparql-ui:runQuery': => @runQuery()
        @subscriptions.add atom.commands.add 'atom-workspace', 'sparql-ui:describeUri': => @describeUri()

    deactivate: ->
        # console.debug('sparql-ui:deactive()')

    serialize: ->
        return @data

    configure: ->
        # pane = atom.workspace.getActivePane()
        # pane.addItem @endpointView
        # pane.activateItem @endpointView

        note = atom.workspace.notificationManager
        editor = atom.workspace.getActiveTextEditor()
        endpoint = editor.getSelectedText()

        if endpoint.length > 0
            ep = url.parse(endpoint)

            if (ep? && ep.hostname?)
                @data.endpoint = endpoint
                note.addSuccess('Endpoing set to ' + endpoint)
            else
                note.addError('Setting endpoing, but it seems fishy -- ignoring you.', detail: endpoint)
        else
            note.addInfo('Current endpoint<br/>' + @data.endpoint)

    runQuery: ->
        editor = atom.workspace.getActiveTextEditor()
        selectedText = editor.getSelectedText()
        query = if selectedText.length > 0 then selectedText else editor.getText()
        @sparqlView.runQuery(query)

    describeUri: ->
        termchar = (s) -> s in [' ', '\t', '\n']

        ed = atom.workspace.getActiveTextEditor()
        buf = ed?.getBuffer()
        pos = ed.getCursorBufferPosition()
        line = buf.getLines()[pos.row]

        start = if pos.column > 0 then pos.column-1 else pos.column

        while (start >= 0 && !termchar(line[start]))
            start--
        start++

        end = start + 1
        while (end < line.length && !termchar(line[end]))
            end++

        uri = line.substring(start, end)
        uri = '<' + uri if !uri.startsWith '<'
        uri = uri + '>' if !uri.endsWith '>'

        # console.debug uri
        @sparqlView.runQuery("describe #{uri}")
