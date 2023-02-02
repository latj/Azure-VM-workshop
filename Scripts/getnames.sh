#!/bin/bash

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -u|--createdby)
      CREATEDBY="$2"
      shift # past argument
      shift # past value
      ;;
    -c|--costcenter)
      COSTCENTER="$2"
      shift # past argument
      shift # past value
      ;;
    -r|--resourcegroup)
      RESOURCEGROUP="$2"
      shift # past argument
      shift # past value
      ;;
    --windows)
      OS=windows
      shift # past argument
      ;;
    --linux)
      OS=linux
      shift # past argument
      ;;
    --generate)
      GENERATE=YES
      shift # past argument
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

OS=${OS:-linux}
CREATEDBY=${CREATEDBY:-$USER}
RESOURCEGROUP=${RESOURCEGROUP:-"test"}
COSTCENTER=${COSTCENTER:-"noway"}

if [ -z ${GENERATE+x} ]; then 
    curl 'https://generatehostnamedemo.azurewebsites.net/api/Listhostnames?code=UaCqmEHNDe0jYLfEL-xI2UZy06Au24sx8Yt8L_aYEc-eAzFuC67iiA==&type='$OS | jq -r '.hostnames[][].name'
else 
    curl -X POST -H "Content-Type: application/json" \
      -d "{'type': '$OS', 'createdby': '$CREATEDBY', 'resourcegroup': '$RESOURCEGROUP', 'costcenter': '$COSTCENTER', GENERATE: 'true'}" \
      "https://generatehostnamedemo.azurewebsites.net/api/Gethostname?code=FD7Xdx777b3iObR31DMWoWJEzXwmy1zmNA_gG9rJb_ftAzFuwdHCNg==" | jq -r '.hostnames[].name'
fi
