window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function TableFilter (module) {
    this.module = module
    this.table = module.querySelector('.gem-c-table')
    this.searchInput = module.querySelector('input[name=table-filter]')
  }

  TableFilter.prototype.init = function () {
    this.searchInput.addEventListener('keyup', function (e) {
      var filterValue = e.currentTarget.value
      var rows = this.table.querySelectorAll('.govuk-table__body .govuk-table__row')

      rows.forEach(function (row) {
        var columns = row.querySelectorAll('.govuk-table__cell')
        var hideRow = true

        for (let index = 0; index < columns.length; index++) {
          var column = columns[index]
          var columnText = column.innerText
          var found = columnText.toUpperCase().indexOf(filterValue.toUpperCase()) > -1

          if (found) {
            hideRow = false
            break
          }
        }

        row.hidden = hideRow
      })
    }.bind(this))
  }

  Modules.TableFilter = TableFilter
})(window.GOVUK.Modules)
