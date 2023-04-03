#!/bin/bash

set -o errexit

# Address of the registry that we'll be 
# performing the inspections against.
# This is necessary as the arguments we
# supply to the API calls don't include 
# such address (the address is used in the
# url itself).
readonly REGISTRY_ADDRESS="${REGISTRY_ADDRESS:-http://localhost:5000}"


# Entry point of the script.
# If makes sure that the user supplied the right
# amount of arguments (image_name and image_tag)
# and then performs the main workflow:
#       1.      retrieve the image digest
#       2.      retrieve the configuration for
#               that digest.
main() {
  check_args "$@"

  local image=$1
  local tag=$2
  local digest=$(get_digest $image $tag)

  get_image_configuration $image $digest
}


# Makes sure that we provided (from the cli) 
# enough arguments.
check_args() {
  if (($# != 2)); then
    echo "Error:
    Two arguments must be provided - $# provided.
    Usage:
      ./get-image-config.sh <image> <tag>
Aborting."
    exit 1
  fi
}


# Retrieves the digest of a specific image tag,
# that is, the address of the uppermost of a specific 
# tag of an image (see more at 
# https://docs.docker.com/registry/spec/api/#content-digests).
# 
# You can know more about the endpoint used at
# https://docs.docker.com/registry/spec/api/#pulling-an-image-manifest
get_digest() {
  local image=$1
  local tag=$2

  echo "Retrieving image digest.
    IMAGE:  $image
    TAG:    $tag
  " >&2

  curl \
    --silent \
    --header "Accept: application/vnd.docker.distribution.manifest.v2+json" \
    "$REGISTRY_ADDRESS/v2/$image/manifests/$tag" |
    jq -r '.config.digest'
}


# Retrieves the image configuration from a given
# digest.
# See more about the endpoint at:
# https://docs.docker.com/registry/spec/api/#pulling-a-layer
get_image_configuration() {
  local image=$1
  local digest=$2

  echo "Retrieving Image Configuration.
    IMAGE:  $image
    DIGEST: $digest
  " >&2

  curl \
    --silent \
    --location \
    "$REGISTRY_ADDRESS/v2/$image/blobs/$digest" |
    jq -r '.container_config' ||   curl \
    --silent \
    --location \
    "$REGISTRY_ADDRESS/v2/$image/blobs/$digest"
}


# Run the entry point with the CLI arguments
# as a list of words as supplied.
main "$@"