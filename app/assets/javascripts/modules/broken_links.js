window.GOVUK = window.GOVUK || {}
window.GOVUK.Modules = window.GOVUK.Modules || {};

(function (Modules) {
  function BrokenLinks (module) {
    this.module = module
  }

  BrokenLinks.prototype.init = function () {
    this.initFormListener()
  }

  BrokenLinks.prototype.initFormListener = function () {
    var form = this.module.querySelector('.js-broken-links__form')
    if (!form) return

    form.addEventListener('submit', function (e) {
      e.preventDefault()

      var request = new XMLHttpRequest()
      request.open('POST', e.currentTarget.action, true)
      request.setRequestHeader('x-csrf-token', document.querySelector('meta[name=csrf-token]').content)
      request.onreadystatechange = function (res) {
        if (res.currentTarget.readyState === 4 && res.currentTarget.status !== 200) {
          this.module
            .querySelector('.js-broken-links__content')
            .innerHTML = '<p class="govuk-body"><strong>Error occured when checking for broken links.</strong></p>' +
              '<p class="govuk-body">Status code ' + res.currentTarget.status + ': ' + res.currentTarget.statusText + '</p>' +
              '<p class="govuk-body">Please refresh the page and try again (please save any changes before refreshing).</p>'
        }
      }.bind(this)
      request.send()

      this.module
        .querySelector('.js-broken-links__content')
        .innerHTML = '<p class="govuk-body"><strong>Please wait. Broken link report in progress.</strong></p>' +
          '<p class="govuk-body">Refresh the page to view to see the result (please save any changes before refreshing).</p>'
      e.currentTarget.remove()
    }.bind(this))
  }

  Modules.BrokenLinks = BrokenLinks
})(window.GOVUK.Modules)
