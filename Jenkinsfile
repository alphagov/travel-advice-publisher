#!/usr/bin/env groovy

library("govuk")

node('mongodb-2.4') {
  govuk.setEnvar("PUBLISHING_E2E_TESTS_COMMAND", "test-travel-advice-publisher")
  govuk.buildProject(
    beforeTest: { sh("yarn install") },
    rubyLintDiff: false,
    publishingE2ETests: true,
    brakeman: true
  )
}
