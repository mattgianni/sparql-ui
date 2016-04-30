# sparql-ui package

SPARQL support in [Atom](http://atom.io/).

## Documentation

sparql-ui currently support three operations accessible via kaymaps:

- [ctrl-alt-p] - sets the endpoint to the currently selected text / displays the current endpoint if no text is selected
- [ctrl-alt-o] - sends the currently selected block of text as a query to the endpoint / sends entire window if no text is selected
- [ctrl-alt-k] - executes a 'describe' query on the URI currently under the cursor / if a block of text is currently selected, this block will be used as the URI to describe

## Caveats

Everything is pretty much untested. Use at your own risk.
