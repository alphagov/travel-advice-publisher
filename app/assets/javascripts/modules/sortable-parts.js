//= require sortablejs/Sortable.js

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function SortableParts (module) {
    this.module = module
  }

  SortableParts.prototype.init = function () {
    new Sortable(this.module.querySelector('#parts'), {
      handle: ".part__drag-handle",
      chosenClass: 'part__drag-item--chosen'
    })
  }

  Modules.SortableParts = SortableParts
})(window.GOVUK.Modules)
