#!/bin/bash

# https://stackoverflow.com/questions/23442173/bash-reading-from-a-file-to-an-associative-array/23442355
# az account list -o tsv | awk -F"\t" '{print $3"\t"$6}' >subscriptions-id-name.tsv
declare -A Asubs
while IFS=$'\t' read -r -a lines; do
  Asubs["${lines[@]:0:1}"]="${lines[@]:1}"
done < <(az account list -o tsv --all | awk -F"\t" '{print $3"\t("$7") "$6}')

echo -e "End\t\tBegin\t\tSubscription name"
for id in "${!Asubs[@]}"; do
  [ "$id" = "f759ccaa-7539-4d4b-a2d5-bd16361c48e0" ] && continue # skip Kovac
  # must use process substition, because "cmd | read xx" would use subshell and lose the variable
  IFS=$'\t' read -r Stop Start Others  < <(az billing period list -o tsv --subscription $id|head -1)
  echo -e "${Stop}\t${Start}\t${Asubs[$id]}"
done | sort -n
