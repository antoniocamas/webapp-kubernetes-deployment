#!/bin/bash

DOMAIN="www.antoniocamaswebdomain.com"
PERSISTENT_VOLUME_PATH=/mnt/data/antoniocamas

THIS_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
SPEC_PATH="$THIS_PATH/specs"
SPEC_FILES="step_1_volumes.yaml step_2_webapp_and_database.yaml step_3_ingress.yaml"
OPERATIONS="create delete"
HELM_CHART=$THIS_PATH/charts/webapp
HELM_DEPLOYMENT_NAME="antoniocamas-helm-deployed-webapp"
MODES="specs helm"
MODE="helm"

usage()
{
cat << EOF

Options:

    -h/--help                           Show this message.
    -v                                  Be verbose (level 1)
    -o/--operation                      Choose one of [$OPERATIONS]
    -m/--mode			        Choose one of [$MODES]
    -s/--show-status			Shows the status of the deployment
EOF

}


function parseArguments()
{
    OPTS=`getopt -o hvso:m: -l help,operation:,mode:,show-status -- "$@"`

    eval set -- "$OPTS"

    while [ $# -gt 0 ]
    do
	case $1 in
	    -h | --help)
		usage
		exit 0
		;;
	    -o | --operation)
		OPERATION=$2
		if [[ "$OPERATION" == "delete" ]]
		then
		    SPEC_FILES=$(reverse_array "${SPEC_FILES[@]}")
		fi
		shift; shift
		;;
	    -m | --mode)
		MODE=$2
		shift; shift
		;;
	    -v)
		BE_VERBOSE='y'
		shift;
		;;
	    -s | --show-status)
		show_deployment_status
		exit 0
		shift;
		;;

	    --)
		shift
		break
		;;
	    (-*)
		echo "$0: unrecognized option $1" 1>&2
		exit 1
	    (*)
		break
		;;
	esac
    done

    if [[ ! " ${OPERATIONS[@]} " =~ " $OPERATION " ]]
    then
	echo "Unknown operation. "
	usage
    exit 1
    fi

    if [[ ! " ${MODES[@]} " =~ " $MODE " ]]
    then
	echo "Unknown mode. "
	usage
    exit 1
    fi
}

function reverse_array ()
{
    local array=$1
    printf '%s\n' $(echo "${array[@]}") | tac | tr '\n' ' '; echo
}

function create_hostPath ()
{
    [[ ! -d "$PERSISTENT_VOLUME_PATH" ]] && mkdir $PERSISTENT_VOLUME_PATH
}

function add_domanin_to_hosts ()
{
    cat /etc/hosts | grep $DOMAIN
    if [[ $? -eq 0 ]]
    then
	[[ $OPERATION == "delete" ]] && sed "/.*${DOMAIN}$/d" -i /etc/hosts > /dev/null
	return 0
    fi
    echo -e "$(minikube ip)\t${DOMAIN}" >> /etc/hosts
}

function execute_spec_files ()
{
    for spec in $SPEC_FILES
    do
	[[ "$BE_VERBOSE" == "y" ]] && echo "kubectl $OPERATION -f $spec"
	kubectl $OPERATION -f $SPEC_PATH/$spec
    done
    sleep 1
    echo 
}

function execute_helm_chart ()
{
    if [[ $OPERATION == "create" ]]
    then
	helm install --name $HELM_DEPLOYMENT_NAME $HELM_CHART
    else
	helm $OPERATION $HELM_DEPLOYMENT_NAME --purge
    fi
}

function show_deployment_status ()
{
    [[ "$BE_VERBOSE" == "y" ]] && echo "kubectl get pods,deployments,services,pv,pvc"
    kubectl get pods,deployments,services,pv,pvc,ingress
    if [[ "$MODE" == "helm" ]]
    then
	[[ "$BE_VERBOSE" == "y" ]] && echo "helm list"
	echo
	helm list
    fi
}

#####################
#### MAIN METHOD ####
#####################
parseArguments $@

create_hostPath
add_domanin_to_hosts
if [[ "$MODE" == "specs" ]]
then
    execute_spec_files
elif [[ "$MODE" == "helm" ]]
then
    execute_helm_chart
fi
show_deployment_status

