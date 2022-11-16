#!/usr/bin/env groovy

library("govuk@add-publishing-api-clone")

node {
  // Run against the MongoDB 3.6 Docker instance on GOV.UK CI
  govuk.setEnvar("TEST_MONGODB_URI", "mongodb://127.0.0.1:27036/travel-advice-publisher-test")

  govuk.buildProject(
    brakeman: true,
    extraParameters: [
            booleanParam(
            name: "USE_PUBLISHING_API_FOR_SCHEMAS",
            defaultValue: true,
            description: "whether to use publishing api for schemas"
          ),
          stringParam(
            name: "PUBLISHING_API_BRANCH",
            defaultValue: "add-content-schemas",
            description: "The branch of publishing api to test against"
          ),
        ],
  )
}
