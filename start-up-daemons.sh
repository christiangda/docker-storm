#!/bin/bash
#set -x

STORM=$(which storm)

# validate arguments
if [[ $# == 0 || $# > 5 ]] ; then
    echo "You need to send name of daemons like: [nimbus|supervisor|drpc|ui|logviewer]"
    exit 1;
fi

# Start up apache storm daemons
for argument in "$@"; do

  if [[ "$argument" =~ ^(nimbus|supervisor|drpc|ui|logviewer)$ ]]; then

    echo "Starting ${argument} ..." >> /opt/apache-storm/logs/${argument}.log
    ${STORM} ${argument} 2>&1 1>> /opt/apache-storm/logs/${argument}.log &

  else

    echo "${argument} is different from [nimbus|supervisor|drpc|ui|logviewer]"

  fi

done

# Show all logs
tail -f /opt/apache-storm/logs/*.log
