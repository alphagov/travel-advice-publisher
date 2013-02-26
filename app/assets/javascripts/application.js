//= require jquery
//= require jquery_ujs
//= require jquery-ui.custom.min
//= require jquery.mustache
//= require twitter/bootstrap
//= require_tree .

var formtastic_ids = {};

$(function () {
  $('.add-associated').click(function () {
    elem = $(this);
    var target_id = elem.data('target');
    var target = $('#' + target_id);

    var template_id = elem.data('tmpl_id');
    template_contents = $('#' + template_id).html();

    if (typeof(formtastic_ids[template_id]) == 'undefined') {
      var current_id = target.find('.part').length - 1;
      formtastic_ids[template_id] = current_id;
    }

    formtastic_ids[template_id]++;

    var html = $.mustache(template_contents, {
      index: formtastic_ids[template_id]
    });

    target.append(html);
    $(this).trigger('associated-added');
    return false;
  });

  $('.remove-associated').live('click', function () {
    var css_selector = $(this).data('selector');
    $(this).parents(css_selector).hide();
    $(this).prev(':input').val('1');
    $('body').trigger('associated-removed');
    return false;
  });
});

// Javascript specific to travel advice admin
$(function() {
  // collapse the parts using the bootstrap accordion
  $(".collapse").collapse();

  var sortable_opts = {
    axis: "y",
    handle: "a.accordion-toggle",
    stop: function(event, ui) {
      $('.part').each(function (i, elem) {
        $(elem).find('input.order').val(i + 1);
        ui.item.find("a.accordion-toggle").addClass("highlight");
        setTimeout(function() { $("a.accordion-toggle.highlight").removeClass("highlight") }, 20 )
      });
    }
  }
  $('#parts').sortable(sortable_opts)
      .find("a.accordion-toggle").css({cursor: 'move'});

  // simulate a click on the first part to open it
  // TODO: This doesn't behave well as the accordion closes then opens rather
  // than leaving the first part open.
  // $('#parts .part .accordion-body').first().one('hidden', function(){
  //   $('#parts .part .accordion-body').first().collapse('show');
  // });

  $('input.title').
    live('change', function () {
      var elem = $(this);
      var value = elem.val();

      // Set slug on change.
      var slug_field = elem.closest('.part').find('.slug');
      if (slug_field.text() === '') {
        slug_field.val(TravelAdviceUtils.convertToSlug(value));
      }

      // Set header on change.
      var header = elem.closest('fieldset').prev('h3').find('a');
      header.text(value);
    });

  $('.add-associated').bind('associated-added', function () {
    var active_index = $('#parts div.part').length;
    var new_part = $('#parts .part:last-child');
    new_part.find('.accordion-body').attr('id', 'new-part-' + active_index).collapse('show');
    new_part.find('a.accordion-toggle').attr('href', '#new-part-' + active_index);

    new_part.find('input.order').val(active_index);
    new_part.find('.title').focus();
  });

  $("#new-from-existing-edition").live('click', function() {
    $("#clone-edition").submit();
  });

  $("#edition_minor_update").change(function() {
    TravelAdviceUtils.setChangeDescriptionVisibility($(this));
  });
  TravelAdviceUtils.setChangeDescriptionVisibility($("#edition_minor_update"));
});

var TravelAdviceUtils = {
  convertToSlug: function(title) {
    return title.toLowerCase().replace(/[^\w ]+/g,'').replace(/ +/g,'-');
  },
  setChangeDescriptionVisibility: function($elem) {
    if ($elem.attr('checked')) {
      $("#edition_change_description_input").hide();
    } else {
      $("#edition_change_description_input").show();
    }
  }
}
