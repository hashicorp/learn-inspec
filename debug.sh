docker rm -f hashi_inspec &>/dev/null
docker run \
    -e VAULT_ADDR='http://127.0.0.1:8200' \
    --name hashi_inspec \
    -ti hashi_inspec
