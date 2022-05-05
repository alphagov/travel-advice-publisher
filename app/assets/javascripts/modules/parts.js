//= require sortablejs/Sortable.js

window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function Parts (module) {
    this.module = module
  }

  Parts.prototype.init = function () {
    this.initSortable()
    this.initAddNewPartBtn()
  }

  Parts.prototype.initSortable = function () {
    window.Sortable.create(this.module.querySelector("#parts"), {
      handle: ".part__drag-handle",
      chosenClass: "part__drag-item--chosen",
      onSort: function() {
        this.updateOrderIndexes()
      }.bind(this)
    })
  }

  Parts.prototype.initAddNewPartBtn = function() {
    var btn = this.module.querySelector(".js-add-new-part")

    btn.addEventListener('click', function(e) {
      e.preventDefault()

      var template = document.getElementById('new-part-template')
      template = template.content.cloneNode(true)
      template = this.initialiseTemplate(template)

      this.module.querySelector("#parts").append(template)
      this.updateOrderIndexes()
    }.bind(this))
  }

  Parts.prototype.initialiseTemplate = function( template ) {
    var newId = this.module.querySelectorAll('#parts .govuk-accordion__section').length + 1
    template.firstElementChild.innerHTML = template.firstElementChild.innerHTML.replaceAll('{{ insert-part-index-here }}', newId)
    template.querySelector('input[name="edition[parts_attributes][' + newId + '][id]"]').remove()

    return template
  }

  Parts.prototype.updateOrderIndexes = function() {
    var orderInputs = this.module.querySelectorAll(".edition-part__order")

    for (var i = 0; i < orderInputs.length; i++) {
      orderInputs[i].setAttribute("value", i + 1)
    }
  }

  Modules.Parts = Parts
})(window.GOVUK.Modules)
