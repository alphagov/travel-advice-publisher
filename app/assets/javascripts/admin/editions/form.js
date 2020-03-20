var adminEditionsForm = {
  showChangeNotesIfMajorChange: function showChangeNotesIfMajorChange() {
    var $form                      = $(".js-edition-form");
    var $fieldset                  = $('.js-change-notes', this.$form);
    var $radio_buttons             = $('input[type=radio]', $fieldset);
    var $minor_change_radio_button = $('.js-edition-update-minor', $fieldset);
    var $change_notes_section      = $('.js-change-notes-section', $fieldset);

    $radio_buttons.change(showOrHideChangeNotes);
    showOrHideChangeNotes();

    function showOrHideChangeNotes() {
      if ($minor_change_radio_button.prop('checked')){
        $change_notes_section.slideUp(200);
      }
      else {
        $change_notes_section.slideDown(200);
      }
    }
  }
}
