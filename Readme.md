### How to reproduce the issue

Start the containers
```sh
docker compose up -d
```

Generate a combined CA so that you can use aws cli against the self-signed kinesis
```sh
cat docker/kinesis/ssl/ca-crt.pem /etc/ssl/certs/ca-certificates.crt > combined-ca-bundle.pem
```

From host, create the kinesis stream `curl-test-stream`
```sh
AWS_CA_BUNDLE=combined-ca-bundle.pem aws --endpoint-url=https://localhost:4568 kinesis create-stream --stream-name curl-test-stream --shard-count 1 --region eu-west-1
```

From host, verify kinesis stream was created
```sh
AWS_CA_BUNDLE=combined-ca-bundle.pem aws --endpoint-url=https://localhost:4568 kinesis list-streams --region eu-west-1
```

Install dependencies in the php container (aws sdk)
```sh
docker compose exec php composer install
```

Find the right bridge based on start of the ip address like `172.27`
```sh
docker network inspect curl-kinesis-rst-issue
```

Use this to find the bridge (replace the ip address with what you will find in previous command)
```sh
ifconfig | grep -C2 172.27
```

Start monitoring the traffic on the bridge using tcpdump
```sh
sudo tcpdump -i br-55b8fa76cf01 'port 4567' -C 100 -W 1 -w ./kinesis_tcp_rst.pcap
```

Run the script to simulate the problem
```sh
docker compose exec php ./curl-kinesis-rst-issue.php
```

Stop the `tcpdump` monitoring
