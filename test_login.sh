#!/bin/bash

echo "Testing login API with admin account..."
echo ""

curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email":"honangquy1@gmail.com","password":"Concac123!@#"}' \
  2>&1 | python3 -m json.tool

echo ""
echo "Done!"
