#!/bin/sh

for i in AdmissionReviewExamples/*.json; do
    echo "=================== $i ==================="

    ANSWER=$(curl -k -X POST -H "Content-Type: application/json" -d @$i https://localhost:8000/mutate)

    echo $ANSWER | jq .

    B64=$(echo $ANSWER | jq -r .response.patch)

    echo ""
    echo "Patch looks like:"
    echo $B64 | base64 -d | jq .
done
