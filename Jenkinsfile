#!/usr/bin/env groovy

library("govuk")

node('mongodb-3.6') {
  govuk.setEnvar("PUBLISHING_E2E_TESTS_COMMAND", "test-travel-advice-publisher")
  govuk.buildProject(
    publishingE2ETests: true,
    brakeman: true
  )
}
