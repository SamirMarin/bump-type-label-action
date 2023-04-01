#!/bin/sh
BUMP_VERSION=${{ inputs.defaut_bump }}
LABEL_PREFIX=${{ inputs.label_prefix }}
if [[ ${{ github.event_name }} != 'pull_request' ]]; then
  REPOSITORIES=$(curl \
    -H "Accept: application/vnd.github+json" \
    -H "Authorization: Bearer ${{ secrets.GITHUB_TOKEN }}" \
    https://api.github.com/repos/${{ github.event.repository.owner.login }}/${{ github.event.repository.name }}/commits/${GITHUB_SHA}/pulls)
  LENGTH=$(echo "$REPOSITORIES" | jq length)
  if [[  "$LENGTH" != "1" ]]; then
    printf "\t|- Failed to find single PR with latest commit sha\n"
    exit 1
  fi
  LABELS=$(echo "$REPOSITORIES" | jq '.[0].labels | .[].name')
  if echo "${LABELS}" | grep "${LABEL_PREFIX}:major" ; then
    BUMP_VERSION="major"
  elif echo "${LABELS}" | grep "${LABEL_PREFIX}:minor" ; then
    BUMP_VERSION="minor"
  elif echo "${LABELS}" | grep "${LABEL_PREFIX}:patch" ; then
    BUMP_VERSION="patch"
  elif echo "${LABELS}" | grep "${LABEL_PREFIX}:ignore" ; then
    BUMP_VERSION="ignore"
  fi
else
  if ${{ contains(github.event.pull_request.labels.*.name, '${LABEL_PREFIX}:major') }}; then
    BUMP_VERSION="major"
  elif ${{ contains(github.event.pull_request.labels.*.name, '${LABEL_PREFIX}:minor') }}; then
    BUMP_VERSION="minor"
  elif ${{ contains(github.event.pull_request.labels.*.name, '${LABEL_PREFIX}:patch') }}; then
    BUMP_VERSION="patch"
  elif ${{ contains(github.event.pull_request.labels.*.name, '${LABEL_PREFIX}:ignore') }}; then
    BUMP_VERSION="ignore"
  fi
fi
echo "The bump value is: $BUMP_VERSION"
echo "value=${BUMP_VERSION}" >> $GITHUB_OUTPUT
