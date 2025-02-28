#!/bin/bash

read -p "Query: " query
echo -e "\n"

api_key=$(cat ~/.ssh/api_key)
url="https://generativelanguage.googleapis.com/"
sub_url1="v1beta/models/gemini-2.0-flash:"
sub_url2="generateContent?key=$api_key"

curl --silent $url$sub_url1$sub_url2 \
-H 'Content-Type: application/json' \
-X POST \
-d '{
  "contents": [{
    "parts":[{"text": "'"$query"'"}]
    }]
   }' >> ~/tmp/initial_response.txt

response=$(grep "text" ~/tmp/initial_response.txt \
  | cut -d':' -f2)

echo -e $response | sed 's/"//g'
rm ~/tmp/initial_response.txt
