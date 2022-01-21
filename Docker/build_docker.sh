#! /bin/bash
set -e

DOCKER_TAG=latest

docker build ${PWD} -f Dockerfile -t lofareosc/prefactor3-cwl:${DOCKER_TAG}
docker push lofareosc/prefactor3-cwl:${DOCKER_TAG}
