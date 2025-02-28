#!/bin/bash

read -p "Query: " query

api_key=$(cat ~/.ssh/api_key)

curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$api_key" \
-H 'Content-Type: application/json' \
-X POST \
-d '{
  "contents": [{
    "parts":[{"text": "'"$query"'"}]
    }]
   }'
