#!/bin/bash

SLACK_NOTIFICATION_WEBHOOK="https://hooks.slack.com/services/your_webhoook_id"

SLACK_MSG="Version \`$VERSION\` was successfully deployed to \`$CF_SPACE\` - :checkered_flag:"
PAYLOAD="{\"text\":\"${SLACK_MSG}\",\"username\": \"deployment-script\",\"icon_emoji\": \":robot_face:\"}"

# send notification to slack webhook, if given
curl -X POST -H 'Content-type: application/json' --data "${PAYLOAD}" "${SLACK_NOTIFICATION_WEBHOOK}"
