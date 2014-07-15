var TravelAdviceUtils = {
  convertToSlug: function(title) {
    return title.toLowerCase().replace(/[^\w ]+/g,'').replace(/ +/g,'-');
  },
  setChangeDescriptionVisibility: function($elem) {
    if ($elem.is(':checked')) {
      $("#major_update_input").hide();
    } else {
      $("#major_update_input").show();
    }
  }
}
