#! /bin/bash
set -e

DOCKER_TAG=latest

docker build ${PWD} -f Docker/Dockerfile-vlbi -t vlbi-cwl:${DOCKER_TAG} #lofareosc/prefactor3-cwl:${DOCKER_TAG}
#docker push lofareosc/prefactor3-cwl:${DOCKER_TAG}
#! /bin/bash
set -e

DOCKER_TAG=latest

docker build ${PWD} -f Docker/Dockerfile-vlbi -t vlbi-cwl:${DOCKER_TAG} #lofareosc/prefactor3-cwl:${DOCKER_TAG}
#docker push lofareosc/prefactor3-cwl:${DOCKER_TAG}
