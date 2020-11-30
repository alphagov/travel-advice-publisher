window.AdminEditionsForm = {
  showChangeNotesIfMajorChange: function showChangeNotesIfMajorChange () {
    var $form = $('.js-edition-form')
    var $fieldset = $('.js-change-notes', $form)
    var $radioButtons = $('input[type=radio]', $fieldset)
    var $majorChangeRadioButton = $('.js-edition-update-major', $fieldset)
    var $changeNotesSection = $('.js-change-notes-section', $fieldset)

    $radioButtons.change(showOrHideChangeNotes)
    showOrHideChangeNotes()

    function showOrHideChangeNotes () {
      if ($majorChangeRadioButton.prop('checked')) {
        $changeNotesSection.removeClass('js-hidden')
      } else {
        $changeNotesSection.addClass('js-hidden')
      }
    }
  }
}
