#!/usr/bin/env groovy

node('mongodb-2.4') {
  def govuk = load '/var/lib/jenkins/groovy_scripts/govuk_jenkinslib.groovy'
  govuk.setEnvar("PUBLISHING_E2E_TESTS_COMMAND", "test-travel-advice-publisher")
  govuk.buildProject(publishingE2ETests: true)
}
