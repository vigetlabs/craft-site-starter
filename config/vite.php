<?php

use craft\helpers\App;

// This Vite config expects that PRIMARY_SITE_URL uses https
$host = App::env('PRIMARY_SITE_URL');

// Matches ddev web_extra_exposed_ports.https_port
$httpsPort = 3000;

return [
    // Strips custom ports from PRIMARY_SITE_URL if present
    'devServerPublic' => preg_replace('/:\d+$/', '', $host) . ':' . $httpsPort,
    'serverPublic' => '/dist/',
    'useDevServer' => App::env('CRAFT_ENVIRONMENT') === 'dev',
    'manifestPath' => '@webroot/dist/.vite/manifest.json',
    // Falls back to the built manifest when the Vite daemon is down
    'checkDevServer' => true,
    // Matches ddev web_extra_exposed_ports.container_port, reached from inside the web container
    'devServerInternal' => 'http://localhost:3000',
];
