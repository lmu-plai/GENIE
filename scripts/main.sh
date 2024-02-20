#!/bin/bash

SCRIPTS='scripts/'

SCRIPT_V=$SCRIPTS'variables.sh'
SCRIPT_S=$SCRIPTS'setup.sh'
SCRIPT_D=$SCRIPTS'delete.sh'
SCRIPT_R=$SCRIPTS'registry.sh'

source $SCRIPT_V

# Operation to work on the full NPM Repository
OPTION=$@

if [ ! -z "$OPTION" ]; then
    source $SCRIPT_R
    exit;
fi


PROGRAM_NAME='GENIE'
PS3="$PROGRAM_NAME > "

echo "GENIE | Select an action to perform..."
select action in 'Help' 'Exit' 'Setup' 'Delete'; do
    case $action in
        Help   ) REPLY='';;
        Exit   ) echo "Goodbye!"; exit 0;;
        Setup  ) source $SCRIPT_S; PS3="$PROGRAM_NAME > ";;
        Delete ) source $SCRIPT_D; PS3="$PROGRAM_NAME > ";;
        *      ) echo "Unknown action > $REPLY";;
    esac
done
