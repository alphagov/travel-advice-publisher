/* eslint-env jasmine, jquery */
/* global GOVUK */

describe('Parts module', function () {
  'use strict'

  var element, module

  beforeEach(function () {
    element = document.createElement('div')
    element.innerHTML = '<div class="parts-wrapper" data-module="parts">' +
      '<fieldset>' +
        '<div class="govuk-accordion" data-module="govuk-accordion" id="parts">' +
          '<div class="govuk-accordion__wrapper">' +
            '<div class="govuk-accordion__section">' +
              '<div class="govuk-accordion__section-header">' +
                '<h2 class="govuk-accordion__section-heading">' +
                  '<span class="govuk-accordion__section-button" id="parts-heading-0">' +
                    '<span class="part__drag-handle">Drag here</span> <span id="part-title-0">Part 1</span>' +
                  '</span>' +
                '</h2>' +
              '</div>' +
              '<div id="parts-content-0" class="govuk-accordion__section-content" aria-labelledby="parts-heading-0">' +
                '<div class="govuk-form-group">' +
                  '<label class="govuk-label govuk-!-font-weight-bold" for="title-0">' +
                  'Title' +
                  '</label>' +
                  '<input class="govuk-input js-part__title-input" data-part-index="0" id="title-0" name="edition[parts_attributes][0][title]" type="text" value="part 1">' +
                '</div>' +
                '<div class="gem-c-textarea govuk-form-group govuk-!-margin-bottom-6">' +
                  '<label for="textarea-2a4959d0" class="gem-c-label govuk-label govuk-label--s">Body</label>' +
                  '<textarea name="edition[parts_attributes][0][body]" class="govuk-textarea" id="textarea-2a4959d0" rows="15" spellcheck="false">' +
                  'part 1 content' +
                  '</textarea>' +
                '</div>' +
                '<div class="govuk-form-group">' +
                  '<label for="input-f6d57795" class="gem-c-label govuk-label govuk-label--s">Slug</label>' +
                  '<div id="hint-480f45d4" class="gem-c-hint govuk-hint govuk-!-margin-bottom-3">' +
                    'For example "title-of-part" (no spaces, apostrophes, etc).' +
                  '</div>' +
                  '<input aria-describedby="hint-480f45d4" class="gem-c-input govuk-input" id="input-f6d57795" name="edition[parts_attributes][0][slug]" spellcheck="false" type="text" value="part-1">' +
                '</div>' +
                '<input type="hidden" class="edition-part__id" name="edition[parts_attributes][0][id]" value="part-0-id">' +
                '<input type="hidden" class="edition-part__destroy" name="edition[parts_attributes][0][_destroy]" value="false">' +
                '<input type="hidden" class="edition-part__order" name="edition[parts_attributes][0][order]" value="1">' +
                '<div class="remove-part-button">' +
                  '<button class="gem-c-button govuk-button govuk-button--warning js-part__remove-button" type="submit" data-part-index="0">Remove part</button>' +
                '</div>' +
              '</div>' +
            '</div>' +
            '<div class="govuk-accordion__section">' +
              '<div class="govuk-accordion__section-header">' +
                '<h2 class="govuk-accordion__section-heading">' +
                  '<span class="govuk-accordion__section-button" id="parts-heading-1">' +
                    '<span class="part__drag-handle">Drag here</span> <span id="part-title-1">Part 2</span>' +
                  '</span>' +
                '</h2>' +
              '</div>' +
              '<div id="parts-content-1" class="govuk-accordion__section-content" aria-labelledby="parts-heading-1">' +
                '<div class="govuk-form-group">' +
                  '<label class="govuk-label govuk-!-font-weight-bold" for="title-1">' +
                  'Title' +
                  '</label>' +
                  '<input class="govuk-input js-part__title-input" data-part-index="0" id="title-1" name="edition[parts_attributes][0][title]" type="text" value="part 1">' +
                '</div>' +
                '<div class="gem-c-textarea govuk-form-group govuk-!-margin-bottom-6">' +
                  '<label for="textarea-2a4959d0" class="gem-c-label govuk-label govuk-label--s">Body</label>' +
                  '<textarea name="edition[parts_attributes][0][body]" class="govuk-textarea" id="textarea-2a4959d0a" rows="15" spellcheck="false">' +
                  'part 2 content' +
                  '</textarea>' +
                '</div>' +
                '<div class="govuk-form-group">' +
                  '<label for="input-f6d57795" class="gem-c-label govuk-label govuk-label--s">Slug</label>' +
                  '<div id="hint-480f45d4" class="gem-c-hint govuk-hint govuk-!-margin-bottom-3">' +
                    'For example "title-of-part" (no spaces, apostrophes, etc).' +
                  '</div>' +
                  '<input aria-describedby="hint-480f45d4a" class="gem-c-input govuk-input" id="input-f6d57795a" name="edition[parts_attributes][0][slug]" spellcheck="false" type="text" value="part-2">' +
                '</div>' +
                '<input type="hidden" class="edition-part__id" name="edition[parts_attributes][0][id]" value="part-1-id">' +
                '<input type="hidden" class="edition-part__destroy" name="edition[parts_attributes][0][_destroy]" value="false">' +
                '<input type="hidden" class="edition-part__order" name="edition[parts_attributes][0][order]" value="1">' +
                '<div class="remove-part-button">' +
                  '<button class="gem-c-button govuk-button govuk-button--warning js-part__remove-button" type="submit" data-part-index="0">Remove part</button>' +
                '</div>' +
              '</div>' +
            '</div>' +
          '</div>' +
        '</div>' +
        '<template id="new-part-template"> <div class="govuk-accordion__section"> <div class="govuk-accordion__section-header"> <h2 class="govuk-accordion__section-heading"> <span class="govuk-accordion__section-button" id="parts-heading-{{ insert-part-index-here }}"> <span class="part__drag-handle"> Drag here </span> <span id="part-title-{{ insert-part-index-here }}">Untitled part</span> </span> </h2> </div> <div id="parts-content-{{ insert-part-index-here }}" class="govuk-accordion__section-content" aria-labelledby="parts-heading-{{ insert-part-index-here }}"> <div class="govuk-form-group"> <label class="govuk-label govuk-!-font-weight-bold" for="title-{{ insert-part-index-here }}"> Title </label> <input class="govuk-input js-part__title-input" data-part-index="{{ insert-part-index-here }}" id="title-{{ insert-part-index-here }}" name="edition[parts_attributes][{{ insert-part-index-here }}][title]" type="text" value="Untitled part"> </div> <div class="gem-c-textarea govuk-form-group govuk-!-margin-bottom-6"> <label for="textarea-a78d8e5c" class="gem-c-label govuk-label govuk-label--s">Body</label> <textarea name="edition[parts_attributes][{{ insert-part-index-here }}][body]" class="govuk-textarea" id="textarea-a78d8e5c" rows="15" spellcheck="true"></textarea> </div> <div class="govuk-form-group"> <label for="input-9b01b0a2" class="gem-c-label govuk-label govuk-label--s">Slug</label> <div id="hint-8d675ddc" class="gem-c-hint govuk-hint govuk-!-margin-bottom-3"> For example "title-of-part" (no spaces, apostrophes, etc). </div> <input aria-describedby="hint-8d675ddc" class="gem-c-input govuk-input" id="input-9b01b0a2" name="edition[parts_attributes][{{ insert-part-index-here }}][slug]" spellcheck="false" type="text" value="untitled-part-{{ insert-part-index-here }}"> </div> <input type="hidden" class="edition-part__id" name="edition[parts_attributes][{{ insert-part-index-here }}][id]" value=""> <input type="hidden" class="edition-part__destroy" name="edition[parts_attributes][{{ insert-part-index-here }}][_destroy]" value="false"> <input type="hidden" class="edition-part__order" name="edition[parts_attributes][{{ insert-part-index-here }}][order]" value=""> <div class="remove-part-button"> <button class="gem-c-button govuk-button govuk-button--warning js-part__remove-button" type="submit" data-part-index="{{ insert-part-index-here }}">Remove part</button> </div> </div> </div></template>' +
        '<button class="gem-c-button govuk-button govuk-button--secondary js-add-new-part" type="submit">Add new part</button>' +
      '</fieldset>' +
    '</div>'

    module = new GOVUK.Modules.Parts(element)
    module.init()
  })

  afterEach(function () {
    element.remove()
  })

  describe('when starting', function () {
    it('initialises parts module', function () {
      expect(module.module).toEqual(element)
    })
  })

  describe('when add new part button is clicked', function () {
    it('adds new part and adds to end of list', function () {
      element.querySelector('.js-add-new-part').dispatchEvent(new Event('click'))

      var allParts = element.querySelectorAll('.govuk-accordion__section')
      var newPart = allParts[2]

      expect(allParts.length).toEqual(3)
      expect(newPart.querySelector('.edition-part__order').value).toEqual('3')
    })
  })

  describe('when remove part button is clicked', function () {
    it('removes and hides part', function () {
      var part = element.querySelector('.govuk-accordion__section')
      expect(part.classList.contains('part-accordion__section--hidden')).toEqual(false)
      expect(part.querySelector('.edition-part__destroy').value).toEqual('false')

      part.querySelector('.js-part__remove-button').dispatchEvent(new Event('click'))
      expect(part.classList.contains('part-accordion__section--hidden')).toEqual(true)
      expect(part.querySelector('.edition-part__destroy').value).toEqual('1')
    })
  })

  describe('when title is updated', function () {
    it('updates accordion title', function () {
      var part = element.querySelector('.govuk-accordion__section')
      expect(part.querySelector('#part-title-0').innerText).toEqual('Part 1')

      var titleInput = part.querySelector('#title-0')
      titleInput.value = 'Travel advice part 1'
      titleInput.dispatchEvent(new Event('change'))

      expect(part.querySelector('#part-title-0').innerText).toEqual('Travel advice part 1')
    })

    it('generates new slug', function () {
      var part = element.querySelector('.govuk-accordion__section')
      expect(part.querySelector('input[name="edition[parts_attributes][0][slug]"]').value).toEqual('part-1')

      var titleInput = part.querySelector('#title-0')
      titleInput.value = 'Travel advice part 1'
      titleInput.dispatchEvent(new Event('change'))

      expect(part.querySelector('input[name="edition[parts_attributes][0][slug]"]').value).toEqual('travel-advice-part-1')
    })
  })
})
