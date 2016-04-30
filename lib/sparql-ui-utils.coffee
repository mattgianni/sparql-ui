http = require('http')
url = require('url')
querystring = require('querystring');

module.exports =
class SparqlUiUtils

    constructor: (endpoint, type = 'text') ->
        @resultBuffer = ''
        @endpoint = endpoint
        @type = type

    query: (query, callback, default_graph=null) =>
        pep = url.parse @endpoint

        data = { query: query }
        @postData = querystring.stringify(data)

        console.debug 'querying this endpoing: ' + JSON.stringify(pep)
        console.debug @postData

        options =
            hostname: pep.hostname ? 'dbpedia.org'
            port: pep.port ? 80
            path: pep.path ? '/sparql'
            method: 'POST'
            headers:
                'Content-type': 'application/x-www-form-urlencoded' # 'application/sparql-query'
                Accept: 'application/sparql-results+json,application/n-triples'
                'Content-length': @postData.length # query.length

        console.debug options
        req = http.request options, (res) =>
            console.debug "STATUS: #{res.statusCode}"
            console.debug "HEADERS: #{JSON.stringify res.headers}"

            res.setEncoding 'utf8'
            res.on 'data', (chunk) => @resultBuffer += chunk
            res.on 'end', =>
                if res.statusCode >= 400 then console.error res
                callback(@resultBuffer, res.statusCode, res.headers['content-type']) if callback?

        req.on 'error', (error) =>
            console.error error.message
            message = """Endpoint: #{@endpoint}
                Message: #{error.message}"""
            atom.workspace.notificationManager.addError 'Connection failed', detail: message

        req.write @postData # query
        req.end
