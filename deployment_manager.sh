#!/bin/bash

SPEC_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/specs"
SPEC_FILES="step_1_volumes.yaml step_2_webapp_and_database.yaml step_3_ingress.yaml"
OPERATIONS="create delete"

usage()
{
cat << EOF

Options:

    -h/--help                           Show this message.
    -v                                  Be verbose (level 1)
    -o/--operation                      Choose between $OPERATIONS
    -s/--show-status			Shows the status of the deployment
EOF

}


function parseArguments()
{
    OPTS=`getopt -o hvso: -l help,operation:,show-status -- "$@"`

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

}

function reverse_array ()
{
    local array=$1
    printf '%s\n' $(echo "${array[@]}") | tac | tr '\n' ' '; echo
}

function create_hostPath ()
{
    [[ ! -d /mnt/data/antoniocamas ]] && mkdir /mnt/data/antoniocamas
}

function add_domanin_to_hosts ()
{
    local domain="www.mywebdomain.com"
    cat /etc/hosts | grep $domain
    if [[ $? -eq 0 ]]
    then
	[[ $OPERATION == "delete" ]] && sed "/.*$domain$/d" -i /etc/hosts > /dev/null
	return 0
    fi
    echo -e "$(minikube ip)\t$domain" >> /etc/hosts
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

function show_deployment_status ()
{
    [[ "$BE_VERBOSE" == "y" ]] && echo "kubectl get pods,deployments,services,pv,pvc"
    kubectl get pods,deployments,services,pv,pvc,ingress
}

#####################
#### MAIN METHOD ####
#####################
parseArguments $@



create_hostPath
add_domanin_to_hosts
execute_spec_files
show_deployment_status

