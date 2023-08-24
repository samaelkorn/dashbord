#!/usr/bin/env bash

trap "echo 'Shutting down'; kill \$!; exit" SIGINT SIGTERM

SCHEDULE_COMMAND="${@:-echo 'scheduler ticked'}";
FIRST_START_DELAY="${FIRST_START_DELAY:-2}";
SCHEDULE_PERIOD="${SCHEDULE_PERIOD:-60}";

STDOUT="${STDOUT:-/proc/1/fd/1}";
STDERR="${STDERR:-/proc/1/fd/2}";

echo "[ Info ] Command to execute: \"$SCHEDULE_COMMAND\". Delay between executions: $SCHEDULE_PERIOD";
echo '[ Info ] Press [CTRL+C] to stop';

sleep "$FIRST_START_DELAY";

while :; do
  # Stop freeze on large delay
  for (( i=1; i<=$SCHEDULE_PERIOD; i+=1)); do
    sleep 1;
  done;

  # Execute command
  ${SCHEDULE_COMMAND} > ${STDOUT} 2> ${STDERR};
done;
