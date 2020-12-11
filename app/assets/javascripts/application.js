//= require jquery-ui.custom.min
//= require jquery.mustache
//= require_tree .

var formtasticIds = {}

$(function () {
  $('.add-associated').click(function () {
    var elem = $(this)
    var targetId = elem.data('target')
    var target = $('#' + targetId)

    var templateId = elem.data('tmpl_id')
    var templateContents = $('#' + templateId).html()

    if (typeof (formtasticIds[templateId]) === 'undefined') {
      var currentId = target.find('.part').length - 1
      formtasticIds[templateId] = currentId
    }

    formtasticIds[templateId]++

    var html = $.mustache(templateContents, {
      index: formtasticIds[templateId]
    })

    target.append(html)
    $(this).trigger('associated-added')
    return false
  })

  $('body').on('click', '.remove-associated', function () {
    var cssSelector = $(this).data('selector')
    $(this).parents(cssSelector).hide()
    $(this).prev(':input').val('1')
    $('body').trigger('associated-removed')
    return false
  })
})

// Javascript specific to travel advice admin
$(function () {
  $('body')
    .on('change', 'input.title', function () {
      var elem = $(this)
      var value = elem.val()

      // Set slug on change.
      var slugField = elem.closest('.part').find('.slug')
      if (slugField.text() === '') {
        slugField.val(TravelAdviceUtils.convertToSlug(value))
      }

      // Set header on change.
      var header = elem.closest('fieldset').prev('h3').find('a')
      header.text(value)
    })

  $('.add-associated').bind('associated-added', function () {
    var activeIndex = $('#parts div.part').length
    var newPart = $('#parts .part:last-child')
    newPart.find('.accordion-body').attr('id', 'new-part-' + activeIndex).collapse('show')
    newPart.find('a.accordion-toggle').attr('href', '#new-part-' + activeIndex)

    newPart.find('input.order').val(activeIndex)
    newPart.find('.title').focus()
  })

  $('body').on('click', '#new-from-existing-edition', function () {
    $('#clone-edition').submit()
  })

  AdminEditionsForm.showChangeNotesIfMajorChange()

  $('.js-add-related-item').on('click', function () {
    var relatedItems = $('.js-related-items')
    var newRelatedItem = relatedItems.children('.row').first().clone()

    // Reset select value
    newRelatedItem.find('select').removeAttr('selected')
    newRelatedItem.find('select').val(0)

    // Append new item
    relatedItems.append(newRelatedItem)
  })

  $('.js-related-items').on('click', '.js-remove-related-item', function () {
    var that = $(this)
    that.parents('.js-related-item').remove()
  })
})
