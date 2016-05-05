## 0.2.0 - 2016-05-05

### Added
* status-view to report query progress addressing [issue #5](https://github.com/mattgianni/sparql-ui/issues/5)

### Fixed
* fixed a minor bug in the json sparql parser when non-string typed literals appear in the results (unreported)

### Removed
* sparql-ui-endpoint.coffee - failed experiment

## 0.1.0 - 2016-04-30

### Added
* basic sparql search implemented - sparql-ui:runQuery <cntl>-<alt>-o
* quick 'describe' lookup from cursor position - sparql-ui:describeUri <cntl>-<alt>-k
* basic endpoint setting / viewing with sparql-ui:configure <cntl>-<alt>-p
* initial release
