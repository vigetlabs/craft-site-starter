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
use putyourlightson\blitz\drivers\generators\LocalGenerator;
use putyourlightson\blitz\drivers\integrations\SeomaticIntegration;
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
        // Generating runs in a queue job, so this needs a running queue worker.
        // Without one, use REFRESH_MODE_CLEAR so pages regenerate on their next visit.
        'refreshMode' => SettingsModel::REFRESH_MODE_CLEAR_AND_GENERATE,
        // Query strings are dropped from the cache key, so tracking params don't create duplicate cached pages.
        // In this mode includedQueryStringParams is ignored. If a template reads query params (search, filters),
        // switch to QUERY_STRINGS_CACHE_URLS_AS_UNIQUE_PAGES and narrow includedQueryStringParams to those params.
        'queryStringCaching' => SettingsModel::QUERY_STRINGS_CACHE_URLS_AS_SAME_PAGE,
        // Setting this replaces Blitz's default list, so add any other integrations a project needs.
        'integrations' => [
            SeomaticIntegration::class,
        ],
        'outputComments' => false,
    ],
    'dev' => [
        'cachingEnabled' => false,
        'cacheGeneratorType' => LocalGenerator::class,
    ],
    'staging' => [
        // Staging sits behind basic auth, which the HTTP generator can't get past
        'cacheGeneratorType' => LocalGenerator::class,
        'outputComments' => true,
    ],
];
*/
