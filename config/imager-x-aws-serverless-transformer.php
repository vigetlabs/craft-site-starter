<?php

use craft\helpers\App;

return [
    'distributionUrl' => App::env('IMAGERX_SERVERLESS_DISTRIBUTION_URL'),
    'signatureKey' => App::env('IMAGERX_SERVERLESS_DISTRIBUTION_SIGNATURE'),
];
