#!/usr/bin/env php
<?php
require_once __DIR__ . '/vendor/autoload.php';

use Aws\Kinesis\KinesisClient;
use GuzzleHttp\Client;
use Aws\Handler\GuzzleV6\GuzzleHandler;

$guzzleClient = new Client([
    'debug' => true,
    'verify' => './combined-ca-bundle.pem'
]);
$guzzleHandler = new GuzzleHandler($guzzleClient);

$kinesisClient = new KinesisClient([
    'credentials' => [
        'key' => 'root',
        'secret' => 'root',
    ],
    'region' => 'us-east-1',
    'version' => '2013-12-02',
    'http' => [
        'curl' => [
            CURLOPT_TCP_KEEPALIVE => 1,
            CURLOPT_TCP_KEEPIDLE => 3,
            CURLOPT_TCP_KEEPINTVL => 3,
            CURLOPT_SSLVERSION => 7,
        ]
    ],
    'http_handler' => $guzzleHandler,
    'endpoint' => 'https://kinesalite:4567',
]);

$kinesisStreamName = 'curl-test-stream';

$kinesisClient->putRecord(
    [
        'StreamName' => $kinesisStreamName,
        'Data' => '{"message": "hello"}',
        'PartitionKey' => '123',
    ],
);

sleep(6);

$kinesisClient->putRecord(
    [
        'StreamName' => $kinesisStreamName,
        'Data' => '{"message": "hello"}',
        'PartitionKey' => '123',
    ],
);
