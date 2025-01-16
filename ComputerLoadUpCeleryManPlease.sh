# retreive opportunities from Grants.gov posted today
response=$(curl --location 'https://apply07.grants.gov/grantsws/rest/opportunities/search' \
--header 'Content-Type: application/json' \
--data '{
    "keyword": null,
    "cfda": null,
    "agencies": null,
    "sortBy": "openDate|desc",
    "rows": 5000,
    "eligibilities": null,
    "fundingCategories": null,
    "fundingInstruments": null,
    "dateRange": "1",
    "oppStatuses": "posted"
}')
echo "$response"
echo "$response" | python3 -m json.tool > fundingOpportunities.json
sleep 2
# extract the opportunity IDs from the JSON response
totalOppValue=0;
todaysOpps=($(jq -r '.oppHits[].id' fundingOpportunities.json))
echo "Today's Opportunity IDs: ${todaysOpps[@]}"
for oppId in "${todaysOpps[@]}"; do
    echo "Opportunity ID: $oppId"
    oppDetails=$(curl --location 'https://apply07.grants.gov/grantsws/rest/opportunity/details' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode "oppId=$oppId")
    opportunityTitle=$(echo "$oppDetails" | jq -r '.opportunityTitle')
    estimatedFunding=$(echo "$oppDetails" | jq -r '.synopsis.estimatedFunding')
    # add to sum total of wasted tax dollars
    totalOppValue=$((totalOppValue + estimatedFunding))
    formattedEstimatedFunding=$(printf "%'.0f" $estimatedFunding)
    echo "Estimated Funding: \$$formattedEstimatedFunding"
    echo "\$$formattedEstimatedFunding --> \"$opportunityTitle\" ... Read more: https://www.grants.gov/search-results-detail/$oppId" >> fundingMap.txt
done
sleep 1
# Format the totalOppValue to currency
formattedTotalOppValue=$(printf "%'.0f" $totalOppValue)
echo " ------------------------ "
echo " ------------------------ " >> fundingMap.txt
echo "Total funding for today's opportunities: \$$formattedTotalOppValue"  >> fundingMap.txt
