<?php
/**
 * Blitz Configuration
 *
 * Commented out because Blitz (putyourlightson/craft-blitz) isn't installed; PHPStan
 * fails on its classes otherwise. Uncomment after installing Blitz.
 * Settings here override the Blitz settings in the control panel.
 *
 * @see \putyourlightson\blitz\models\SettingsModel
 */

/*
use craft\helpers\App;
use putyourlightson\blitz\drivers\generators\LocalGenerator;
use putyourlightson\blitz\models\SettingsModel;

return [
    '*' => [
        'cachingEnabled' => true,
        'includedUriPatterns' => [
            [
                'enabled' => true,
                'siteId' => '',
                'uriPattern' => '.*',
            ],
        ],
        'excludedUriPatterns' => [],
        // Generating runs in a queue job. Craft runs the queue from web requests by default; if
        // runQueueAutomatically is off and no worker runs, use REFRESH_MODE_CLEAR so pages regenerate on their next visit.
        'refreshMode' => SettingsModel::REFRESH_MODE_CLEAR_AND_GENERATE,
        // Query strings are dropped from the cache key, so tracking params don't create duplicate cached pages.
        // In this mode includedQueryStringParams is ignored. If a template reads query params (search, filters),
        // switch to QUERY_STRINGS_CACHE_URLS_AS_UNIQUE_PAGES and narrow includedQueryStringParams to those params.
        'queryStringCaching' => SettingsModel::QUERY_STRINGS_CACHE_URLS_AS_SAME_PAGE,
        'outputComments' => false,
    ],
    'dev' => [
        'cachingEnabled' => false,
        'cacheGeneratorType' => LocalGenerator::class,
    ],
    'staging' => [
        // If staging is behind basic auth, set BLITZ_BASIC_AUTH_USERNAME and BLITZ_BASIC_AUTH_PASSWORD so the HTTP generator can fetch pages
        'cacheGeneratorSettings' => [
            'useBasicAuth' => (bool) App::env('BLITZ_BASIC_AUTH_USERNAME'),
            'username' => '$BLITZ_BASIC_AUTH_USERNAME',
            'password' => '$BLITZ_BASIC_AUTH_PASSWORD',
        ],
        'outputComments' => true,
    ],
];
*/
