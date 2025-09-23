'use strict'
window.GOVUK = window.GOVUK || {}
window.GOVUK.vars = window.GOVUK.vars || {}
window.GOVUK.vars.extraDomains = [
  {
    name: 'production',
    domains: ['travel-advice-publisher.publishing.service.gov.uk'],
    initialiseGA4: true,
    id: 'GTM-P93SHJ4Z',
    gaProperty: 'UA-26179049-6'
  },
  {
    name: 'staging',
    domains: ['travel-advice-publisher.staging.publishing.service.gov.uk'],
    initialiseGA4: false
  },
  {
    name: 'integration',
    domains: ['travel-advice-publisher.integration.publishing.service.gov.uk'],
    initialiseGA4: true,
    id: 'GTM-P93SHJ4Z',
    auth: '8jHx-VNEguw67iX9TBC6_g',
    preview: 'env-50'
  }
]
