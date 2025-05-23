<?php

use craft\helpers\App;

return [
    'transformer' => 'awsserverless',
    'removeMetadata' => true,
    'cacheRemoteFiles' => true,
    'allowUpscale' => false,
    'preserveColorProfiles' => true,
    'transformAnimatedGifs' => false,
    'transformSvgs' => false,
    'fillTransforms' => true,
    'imagerUrl' => App::env('S3_BASE_URL') . '/' . App::env('S3_SUBFOLDER') . '/transforms/',
    'storages' => ['aws'],
    'storageConfig' => [
        'aws' => [
            'accessKey' => App::env('S3_ACCESS_KEY_ID'),
            'secretAccessKey' => App::env('S3_SECRET_ACCESS_KEY'),
            'region' => App::env('S3_BUCKET_REGION'),
            'bucket' => App::env('S3_BUCKET'),
            'folder' => App::env('S3_SUBFOLDER') . '/transforms',
            'requestHeaders' => [],
            'storageType' => 'standard',
            'public' => false,
            'cloudfrontInvalidateEnabled' => true,
            'cloudfrontDistributionId' => App::env('S3_CLOUDFRONT_DISTRIBUTION_ID'),
        ],
    ],
];
