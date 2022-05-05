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
    this.initRemovePartBtns()
  }

  Parts.prototype.initSortable = function () {
    if (!this.module.querySelector("#parts")) return

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
    template.querySelector(".govuk-accordion__section-content").classList.add("part__show-by-default")
    template.querySelector(".edition-part__id").remove()
    this.initRemovePartBtn(template.querySelector(".js-part__remove-button"))

    return template
  }

  Parts.prototype.updateOrderIndexes = function() {
    var orderInputs = this.module.querySelectorAll(".edition-part__order")

    for (var i = 0; i < orderInputs.length; i++) {
      orderInputs[i].setAttribute("value", i + 1)
    }
  }

  Parts.prototype.initRemovePartBtns = function() {
    var buttons = this.module.querySelectorAll(".js-part__remove-button")

    for (var i = 0; i < buttons.length; i++) {
      this.initRemovePartBtn( buttons[i] )
    }
  }

  Parts.prototype.initRemovePartBtn = function( button ) {
    button.addEventListener('click', function(e) {
      e.preventDefault()

      var partIndex = e.currentTarget.getAttribute('data-part-index')
      var part = this.module.querySelectorAll('.govuk-accordion__section')[partIndex]

      part.querySelector('.edition-part__destroy').value = 1
      part.classList.add('part-accordion__section--hidden')
    }.bind(this))
  }

  Modules.Parts = Parts
})(window.GOVUK.Modules)
