//= require sortablejs/Sortable.js

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function SortableParts (module) {
    this.module = module
  }

  SortableParts.prototype.init = function () {
    this.sortable = window.Sortable.create(this.module.querySelector('#parts'), {
      handle: ".part__drag-handle",
      chosenClass: 'part__drag-item--chosen',
      onSort: function() {
        this.updateOrderIndexes()
      }.bind(this)
    })
  }

  SortableParts.prototype.updateOrderIndexes = function() {
    var orderInputs = this.module.querySelectorAll('.edition-part__order')

    for (var i = 0; i < orderInputs.length; i++) {
      orderInputs[i].setAttribute('value', i + 1)
    }
  }

  Modules.SortableParts = SortableParts
})(window.GOVUK.Modules)
