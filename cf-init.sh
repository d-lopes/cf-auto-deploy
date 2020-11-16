#!/bin/bash

if [ "${CF_CLIENT_ID}x" = "x" ] || [ "${CF_CLIENT_SECRET}x" = "x" ] || [ "${CF_CREDENTIALS_URL}x" = "x" ] || [ "${CF_TOKEN_URL}x" = "x" ] || [ "${CF_SPACE}x" = "x" ]; then
    echo "CF_CLIENT_ID, CF_CLIENT_SECRET, CF_CREDENTIALS_URL, CF_TOKEN_URL and CF_SPACE must be defined."
    exit 1
fi

CLIENT_ID="${CF_CLIENT_ID}"
CLIENT_SECRET="${CF_CLIENT_SECRET}"
CREDENTIALS_URL="${CF_CREDENTIALS_URL}"
TOKEN_URL="${CF_TOKEN_URL}"

echo "Login with ..."
echo "  Client ID: $CLIENT_ID"
echo "  Client Secret: ********"
echo "  Credentials URL: $CREDENTIALS_URL"
echo "  Token URL: $TOKEN_URL"
echo "  Space: $CF_SPACE"

BEARER_TOKEN=$(curl --user "${CLIENT_ID}":"${CLIENT_SECRET}" -d "grant_type=client_credentials" "${TOKEN_URL}" | jq .access_token -r)
USER_CREDENTIALS=$(curl -H "Authorization: Bearer ${BEARER_TOKEN}" "${CREDENTIALS_URL}")

# login
CF_API_URL=$(echo "$USER_CREDENTIALS" | jq .cf_api_url -r)
CF_USERNAME=$(echo "$USER_CREDENTIALS" | jq .username -r)
CF_PASSWORD=$(echo "$USER_CREDENTIALS" | jq .password -r)
cf login -a "${CF_API_URL}" -u "${CF_USERNAME}" -p "${CF_PASSWORD}"
