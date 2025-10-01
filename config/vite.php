<?php

use craft\helpers\App;
use craft\helpers\StringHelper;

// This Vite config expects that PRIMARY_SITE_URL uses https
$host = App::env('PRIMARY_SITE_URL');

// Matches ddev web_extra_exposed_ports.https_port
$httpsPort = 3000;

return [
    // Strips custom ports from PRIMARY_SITE_URL if present
    'devServerPublic' => StringHelper::trimRight(preg_replace('/:\d+$/', '', $host), '/') . ':' . $httpsPort,
    'serverPublic' => '/dist/',
    'useDevServer' => App::env('CRAFT_ENVIRONMENT') === 'dev',
    'manifestPath' => '@webroot/dist/.vite/manifest.json',
];
