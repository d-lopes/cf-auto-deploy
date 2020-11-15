#!/bin/bash

SLACK_NOTIFICATION_WEBHOOK="https://hooks.slack.com/services/your_webhoook_id"

SLACK_MSG="Just so you know, the user \`$USER\` is deploying version \`$VERSION\` to \`$CF_SPACE\` - :hourglass_flowing_sand:"
PAYLOAD="{\"text\":\"${SLACK_MSG}\",\"username\": \"deployment-script\",\"icon_emoji\": \":robot_face:\"}"

# send notification to slack webhook
curl -X POST -H 'Content-type: application/json' --data "${PAYLOAD}" "${SLACK_NOTIFICATION_WEBHOOK}"
