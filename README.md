# [sparql-ui](https://github.com/mattgianni/sparql-ui) package

SPARQL support for [Atom](http://atom.io/).

## Installation

[sparql-ui](https://github.com/mattgianni/sparql-ui) is not currently a registered package on [Atom.IO Packages](https://atom.io/packages). So the the built-in package installer cannot be used. The files need to be manually installed. The simplest method is to clone the repo into your *packages* folder:

```[bash]
pushd ~/.atom/packages
git clone https://github.com/mattgianni/sparql-ui.git
popd
```

[Atom](https://atom.io/) follows symbolic links when loading packages on startup. If you'd rather clone the repo to a different location, simply create a symbolic link to the alternative location in Atom's packages directory like so:

```[bash]
ln -s /path/to/repo ~/.atom/packages/sparql-ui
```

After installing the files, the Atom client needs to be restarted. You'll know the package is installed when you see it listed under Atom>Preferences>Packages>Installed Packages (or **[shft-cmd-p] Settings View:View Installed Packages**)

## Getting Started

Before you can execute a sparql query or update, you'll have to tell [sparql-ui](https://github.com/mattgianni/sparql-ui) which endpoint to use. This can be done by placing your cursor somewhere in the URL for the sparql endpoint and selecting the **[ctrl-alt-p]** command.

Try setting you endpoint to DBPedia for example:

```
# http://dbpedia.org/sparql
```

Once set, [sparql-ui](https://github.com/mattgianni/sparql-ui) will continue to use this endpoint for future queries until it is reset to a different endpoint. After setting the endpoint to DBPedia, try to following query:

```[sparql]
# endpoint: http://dbpedia.org/sparql
describe <http://www.wikidata.org/entity/Q10858737>
```

## Commands

[sparql-ui](https://github.com/mattgianni/sparql-ui) currently support three operations accessible via kaymaps or the command pallette (**[shft-cmd-P]**). Some of the commands are available through the menu system (under packages and the context menus).

* **[ctrl-alt-p]** (*Sparql UI:Configure*)
  * sets the endpoint to the currently selected text
  * displays the current endpoint if no text is selected
* **[ctrl-alt-o]** / **[alt-cmd-enter]** (*Sparql UI:RunQuery*)
  * sends the currently selected block of text as a query to the endpoint
  * sends entire window if no text is selected
* **[ctrl-alt-k]** (*Sparql UI:DescribeUri*)
  * executes sparql 'describe' on the currently selected block of text
  * executes a 'describe' query on the URI currently under the cursor if nothing selected
- **[ctrl-alt-u]** (*Sparql UI:RunUpdate*)
    - sends the currently selected block of text as an *update* to the endpoint
    - sends entire window if no text is selected
- **[ctrl-alt-l]** (*Sparql UI:InUri*)
  - query for all incoming edges for the URI in the selected block of text
  - use the URI under the cursor to query for incoming edges
- **[ctrl-alt-;]** (*Sparql UI:OutUri*)
  - same as **[ctrl-alt-l]**, but query for out-going edges

## Caveats

Everything is pretty much untested. Use at your own risk.
