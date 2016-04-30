SparqlUtils = require './sparql-ui-utils'

module.exports =
class SparqlUiView

    constructor: (serializedState) ->
        @props = serializedState
        @cachefn = "/tmp/query_results"

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

        # custom padding / trimming strings (TODO: the trimming part ...)
        pad = (s, n) ->
            return if n <= s.length then ' ' + s + ' |' else ' ' + s + Array(n - s.length).join(' ') + ' |'

        # determine the column widths
        m = bindings.map( (binding) -> vars.map( (column) -> binding[column].value.length))
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

    submitSparql: (query, editor) ->
        console.debug('submit sparl')
        # editor.setText('hey there, Im running\n' + query)
        atom.workspace.notificationManager.addInfo 'Executing query', detail: query
        util = new SparqlUtils(@props.endpoint)

        @st = (new Date()).getTime()
        util.query query, (query_results, code, contentType) =>
            console.warn 'Query results are of type: ' + contentType

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
