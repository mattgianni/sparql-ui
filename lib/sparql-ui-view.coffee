SparqlUtils = require './sparql-ui-utils'
{ Emitter } = require 'atom'

module.exports =
class SparqlUiView

    constructor: (serializedState) ->
        @props = serializedState
        @cachefn = "/tmp/query_results"
        @emitter = new Emitter()

    # Returns an object that can be retrieved when package is activated
    serialize: ->
        return @props

    # Tear down any state and detach
    destroy: ->

    parseSparqlJson: (results) ->

        if results.length is 0
            return "<empty resultset>\n\n"

        # tease out the header / data
        { head: { vars }, results: { bindings } } = JSON.parse(results)

        if bindings.length is 0
            return "<empty resultset>\n\n"

        # custom padding / trimming / converting to strings (TODO: the trimming part ...)
        pad = (value, n) ->
            s = value.toString()
            return if n <= s.length then ' ' + s + ' |' else ' ' + s + Array(n - s.length).join(' ') + ' |'

        # determine the column widths
        m = bindings.map( (binding) -> vars.map( (column) ->
            binding[column].value.toString().length))

        vmax = m.reduce (v1, v2) -> v1.map( (n, i) -> Math.max(n, v2[i]))

        # make a border
        border = "+" + (vmax.map (n) -> Array(n+3).join('-')).join("+") + "+" + "\n"

        # make a header
        header = '|' + (vars.map( (column, i) -> pad(column, vmax[i]+1)).join("") ) + "\n"

        data_array = bindings.map( (binding) ->
            '|' + (vars.map( (column, i) -> pad(binding[column].value, vmax[i]+1)).join("") ))
        data_string = (data_array.reduce (l1, l2) -> l1 + '\n' + l2) + "\n"

        border + header + border + data_string + border

    parseText: (results) ->
        results

    guid: ->
        s4 = () ->
            Math.floor((1 + Math.random()) * 0x10000)
                .toString(16)
                .substring(1);
        s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();

    onDidQueryStart: (callback) ->
        @emitter.on 'did-sparql-query-start', callback

    onDidQueryEnd: (callback) ->
        @emitter.on 'did-sparql-query-end', callback

    submitSparql: (query, editor) ->
        atom.workspace.notificationManager.addInfo 'Executing query', detail: query
        queryId = @guid()

        @emitter.emit 'did-sparql-query-start', { id: queryId, query: query }

        util = new SparqlUtils(@props.endpoint)

        @st = (new Date()).getTime()
        util.query query, (query_results, code, contentType) =>
            console.debug 'Query results are of type: ' + contentType
            @emitter.emit 'did-sparql-query-end', { id: queryId, statusCode: code }

            if code >= 400
                editor.setText(@parseText(query_results))
                atom.workspace.notificationManager.addError 'Query fail!', detail: query_results
                return;
            else
                dt = (new Date()).getTime() - @st
                atom.workspace.notificationManager.addSuccess "<strong>Nice job!</strong><br/>Query completed in: #{dt}ms"

                console.info "sparql query completed in: #{dt}ms"
                elapsedMsg =
                    if atom.config.get('sparql-ui.showElapsed')
                        "\n# query completed in: #{dt}ms\n"
                    else
                        ""
                queryMsg =
                    if atom.config.get('sparql-ui.showQuery')
                        "# endpoint: #{@props.endpoint}\n#{query}\n"
                    else
                        ""

                if contentType.startsWith('application/sparql-results+json') > 0
                    editor.setText(@parseSparqlJson(query_results) + elapsedMsg + queryMsg)
                else
                    editor.setText(@parseText(query_results) + elapsedMsg + queryMsg)


    runQuery: (query) ->
        editors = atom.workspace.getTextEditors()
        existingEditor = editors.find((e) => (e.getPath() is @cachefn))
        if existingEditor?
            @submitSparql query, existingEditor
        else
            atom.workspace.open(@cachefn).then (editor) =>
                editor.setGrammar(atom.grammars.grammarForScopeName('source.rq'))
                @submitSparql query, editor
