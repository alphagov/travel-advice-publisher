#!/bin/bash

export INITIATING_REPO_NAME="alphagov/govuk-content-schemas"
export INITIATING_GIT_COMMIT=${SCHEMA_GIT_COMMIT}
export CONTEXT_MESSAGE="Verify travel-advice-publisher against content schemas"
export TEST_TASK="spec:schema"

exec ./jenkins.sh
