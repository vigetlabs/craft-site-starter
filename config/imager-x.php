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
];
