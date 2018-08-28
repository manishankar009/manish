#!/bin/bash

if [ -z "$1" ]; then
 echo "Usage:"
 echo "ENV=some-env `basename $0` pull "
 echo "ENV=some-env `basename $0` push "
 exit 0
fi

function push {
echo "push monolit-secrets to keyvault"
cat secrets.yaml | base64 > secrets.enc
split -b 20k secrets.enc secrets-
secrets=$(ls -lh | grep secrets- | awk '{print $NF}')
for secrets in $secrets
do
az keyvault secret set --vault-name $ENV --name $secrets --value "$(cat $secrets)"
done
#cleanup
rm secrets.enc secrets-* > /dev/null 2>&1
}

function pull {
echo "pull monolit-secrets from keyvault"
files=$(az keyvault secret list --vault-name $ENV | jq  ".[]|.id" | grep secrets- | awk -F "/" '{print $NF}'| sed 's/\"//g')
for files in $files
do
# az keyvault secret delete --vault-name $ENV --name $files
az keyvault secret show --vault-name $ENV --name $files | jq -r '.value' | base64 --decode >> secrets.yaml
done

}

$1
