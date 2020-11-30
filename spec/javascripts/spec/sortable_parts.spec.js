describe('A sortable parts module', function () {
  'use strict'

  var element,
    module

  beforeEach(function () {
    element = $('<div>' +
      '<div class="part">1. <input class="order" value="10" /><div class="js-sort-handle"></div></div>' +
      '<div class="part">2. <input class="order" value="x" /><div class="js-sort-handle"></div></div>' +
      '<div class="part">3. <input class="order" /><div class="js-sort-handle"></div></div>' +
    '</div>')
    $('body').append(element)
    module = new GOVUKAdmin.Modules.SortableParts()
    spyOn(element, 'sortable')
    module.start(element)
  })

  afterEach(function () {
    element.remove()
  })

  describe('when starting', function () {
    it('initialises a jQuery UI sortable list', function () {
      expect(element.sortable).toHaveBeenCalled()
    })
  })

  describe('when a part is moved', function () {
    var firstPart

    beforeEach(function () {
      var stopFn = element.sortable.calls.mostRecent().args[0].stop

      firstPart = element.find('.part')
      stopFn(null, { item: firstPart })
    })

    it('highlights the moved part', function () {
      expect(firstPart.find('.yellow-fade').length).toBeTruthy()
    })

    it('updates the input order based on index', function () {
      var inputValues = $.map(element.find('.order'), function (elm) {
        return $(elm).val()
      })
      expect(inputValues).toEqual(['1', '2', '3'])
    })
  })
})
