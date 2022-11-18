#!/usr/bin/env groovy

library("govuk@add-publishing-api-clone")

node {
  // Run against the MongoDB 3.6 Docker instance on GOV.UK CI
  govuk.setEnvar("TEST_MONGODB_URI", "mongodb://127.0.0.1:27036/travel-advice-publisher-test")

  govuk.buildProject(
    brakeman: true,
    parameters: [
      [$class: 'BooleanParameterValue',
        name: 'USE_PUBLISHING_API_FOR_SCHEMAS',
        value: true],
      [$class: 'StringParameterValue',
        name: 'PUBLISHING_API_SCHEMAS_BRANCH',
        value: 'add-content-schemas']
    ]
  )
}
