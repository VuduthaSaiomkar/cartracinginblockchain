#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

jq --version > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Please Install 'jq' https://stedolan.github.io/jq/ to execute this script"
	echo
	exit 1
fi

echo "POST request Enroll on Org1  ..."
echo
export company_TOKEN=$(curl -s -X POST \
  http://localhost:4000/users \
  -H "content-type: application/x-www-form-urlencoded" \
  -d 'username=Jim&orgName=dealer')
echo $company_TOKEN
export company_TOKEN=$(echo $company_TOKEN | jq ".token" | sed "s/\"//g")
echo
echo "company token is $company_TOKEN"
echo



echo
export TRX_ID=$(curl -s -X POST \
  http://localhost:4000/initledger \
  -H "authorization: Bearer $company_TOKEN" \
  -H "content-type: application/json" \
  -d '{
	"peers": ["peer0.company.example.com","peer0.rto.example.com","peer0.dealer.example.com"],
	"fcn":"queryCar",
	"args":["CAR0"]
}')
echo "Transacton ID is $TRX_ID"
echo
echo

echo "GET query chaincode on peer1 of Org1"
echo
curl -s -X GET \
  http://localhost:4000/queryCar?peer=peer0.dealer.example.com&fcn=queryAllCars&args= \
  -H "authorization: Bearer $company_TOKEN" \
  -H "content-type: application/json"
echo


echo "GET query Transaction by TransactionID"
echo
curl -s -X GET http://localhost:4000/channels/mychannel/transactions/$TRX_ID?peer=peer0.org1.example.com \
  -H "authorization: Bearer $company_TOKEN" \
  -H "content-type: application/json"
echo
echo
