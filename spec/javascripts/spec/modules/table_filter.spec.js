/* eslint-env jasmine, jquery */
/* global GOVUK */

describe('Table filter module', function () {
  'use strict'

  var element, module

  beforeEach(function () {
    element = document.createElement('div')
    element.innerHTML = '<div data-module="table-filter">' +
      '<div class="js-table-filter__input">' +
        '<div class="govuk-form-group">' +
        '<label for="input-49ccb04a" class="gem-c-label govuk-label">Filter countries</label>' +
        '<span class="gem-c-input__search-icon"></span>' +
        '<input class="gem-c-input govuk-input gem-c-input--with-search-icon" id="input-49ccb04a" name="table-filter" spellcheck="false" type="text">' +
      '</div>' +
      '<table class="gem-c-table govuk-table">' +
        '<thead class="govuk-table__head">' +
          '<tr class="govuk-table__row">' +
            '<th class="govuk-table__header" scope="col">Country</th>' +
            '<th class="govuk-table__header" scope="col">Status</th>' +
          '</tr>' +
        '</thead>' +
        '<tbody class="govuk-table__body">' +
          '<tr class="govuk-table__row"><td class="govuk-table__cell"><a class="govuk-link" href="/admin/countries/afghanistan">Afghanistan</a></td><td class="govuk-table__cell">No advice published</td></tr>' +
          '<tr class="govuk-table__row"><td class="govuk-table__cell"><a class="govuk-link" href="/admin/countries/bangladesh">Bangladesh</a></td><td class="govuk-table__cell">No advice published</td></tr>' +
          '<tr class="govuk-table__row"><td class="govuk-table__cell"><a class="govuk-link" href="/admin/countries/brunei">Brunei</a></td><td class="govuk-table__cell">No advice published</td></tr>' +
          '<tr class="govuk-table__row"><td class="govuk-table__cell"><a class="govuk-link" href="/admin/countries/cambodia">Cambodia</a></td><td class="govuk-table__cell">No advice published</td></tr>' +
          '<tr class="govuk-table__row"><td class="govuk-table__cell"><a class="govuk-link" href="/admin/countries/cayman-islands">Cayman Islands</a></td><td class="govuk-table__cell">No advice published</td></tr>' +
          '<tr class="govuk-table__row"><td class="govuk-table__cell"><a class="govuk-link" href="/admin/countries/zambia">Zambia</a></td><td class="govuk-table__cell">No advice published</td></tr>' +
        '</tbody>' +
      '</table>' +
    '</div>'

    module = new GOVUK.Modules.TableFilter(element)
    module.init()
  })

  afterEach(function () {
    element.remove()
  })

  describe('when starting', function () {
    it('initialises module', function () {
      expect(module.module).toEqual(element)
      expect(module.table).toEqual(element.querySelector('.gem-c-table'))
      expect(module.searchInput).toEqual(element.querySelector('input[name=table-filter]'))
    })

    it('should show all results when initialised', function () {
      var table = element.querySelector('.gem-c-table')
      var visibleRows = table.querySelectorAll('.govuk-table__body [class=govuk-table__row]:not([hidden])')

      expect(visibleRows.length).toEqual(6)
    })
  })

  describe('when searching', function () {
    it('should only see one result for part match', function () {
      var searchInput = element.querySelector('input[name=table-filter]')
      searchInput.value = 'Af'
      searchInput.dispatchEvent(new Event('keyup'))

      var table = element.querySelector('.gem-c-table')
      var visibleRows = table.querySelectorAll('.govuk-table__body [class=govuk-table__row]:not([hidden])')

      expect(visibleRows.length).toEqual(1)
    })

    it('should only see more than one result for multiple countries with the same two letters', function () {
      var searchInput = element.querySelector('input[name=table-filter]')
      searchInput.value = 'Ca'
      searchInput.dispatchEvent(new Event('keyup'))

      var table = element.querySelector('.gem-c-table')
      var visibleRows = table.querySelectorAll('.govuk-table__body [class=govuk-table__row]:not([hidden])')

      expect(visibleRows.length).toEqual(2)
    })

    it('should only no results where nothing in table matches', function () {
      var searchInput = element.querySelector('input[name=table-filter]')
      searchInput.value = 'somerandomstring'
      searchInput.dispatchEvent(new Event('keyup'))

      var table = element.querySelector('.gem-c-table')
      var visibleRows = table.querySelectorAll('.govuk-table__body [class=govuk-table__row]:not([hidden])')

      expect(visibleRows.length).toEqual(0)
    })

    it('should show everything when nothing is entered', function () {
      var searchInput = element.querySelector('input[name=table-filter]')
      searchInput.value = ''
      searchInput.dispatchEvent(new Event('keyup'))

      var table = element.querySelector('.gem-c-table')
      var visibleRows = table.querySelectorAll('.govuk-table__body [class=govuk-table__row]:not([hidden])')

      expect(visibleRows.length).toEqual(6)
    })
  })
})
