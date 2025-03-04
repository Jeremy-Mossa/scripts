#!/bin/bash

read -p "Query: " query
echo -e "\n"

api_key=$(cat ~/.ssh/api_key)
url="https://generativelanguage.googleapis.com/"
ver="v1beta/models/gemini-2.0-flash:"
key="generateContent?key=$api_key"

curl --silent $url$ver$key \
-H 'Content-Type: application/json' \
-X POST \
-d '{
  "contents": [{
    "parts":[{"text": "'"$query"'"}]
    }]
   }' >> ~/tmp/data.json

sleep 3
perl ~/perl/json_printer.pl
