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
            .querySelector('.js-broken-links__text')
            .innerHTML = '<strong>Error occured when checking for broken links.</strong><br/><br/>' +
              'Status code ' + res.currentTarget.status + ': ' + res.currentTarget.statusText + '<br/><br/>' +
              'Please refresh the page and try again.'
        }
      }.bind(this)
      request.send()

      e.currentTarget.remove()
      this.module
        .querySelector('.js-broken-links__text')
        .innerHTML = '<strong>Please wait. Broken link report in progress.</strong><br/><br/>Refresh the page to view to see the result.'
    }.bind(this))
  }

  Modules.BrokenLinks = BrokenLinks
})(window.GOVUK.Modules)
