<?php

use craft\helpers\App;

return [
    // Match to https port in .ddev/config.yaml -> web_extra_exposed_ports
    // Only works when using HTTPS on DDEV.
    'devServerPublic' => App::env('PRIMARY_SITE_URL') . ':3001',
    'serverPublic' => '/dist/',
    'useDevServer' => App::env('CRAFT_ENVIRONMENT') === 'dev',
    'manifestPath' => '@webroot/dist/.vite/manifest.json',
];
