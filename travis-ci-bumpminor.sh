#!/bin/bash +ex

# travis-ci-bumpminor
#
# Assumptions:
# GH_REF env variable (github.com/tomologic/wrench.git)
# GH_TOKEN env variable with Github Personal Token https://github.com/blog/1509-personal-api-tokens
#
# Dependencies:
# - git
# - semver.sh

# Check if HEAD already is tagged with a semver tag
git tag --contains HEAD | grep -q "v[0-9]*\.[0-9]*\.[0-9]*"
rc=$?

if [[ $rc == 0 ]]; then
  echo "HEAD is already tagged release. Doing nothing."
else
    git config user.name "Travis CI"
    git config user.email "notifications@travis-ci.org"

    git tag -a "v$(semver.sh bump minor)" -m "Version v$(semver.sh bump minor)"

    # Send stdout to dev/null to protect GH_TOKEN
    git push --quiet "https://${GH_TOKEN}@${GH_REF}" --tags > /dev/null 2>&1
fi
