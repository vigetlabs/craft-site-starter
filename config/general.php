<?php
/**
 * General Configuration
 *
 * All of your system's general configuration settings go in here. You can see a
 * list of the available settings in vendor/craftcms/cms/src/config/GeneralConfig.php.
 *
 * @see \craft\config\GeneralConfig
 */

use craft\config\GeneralConfig;
use craft\helpers\App;
use craft\helpers\StringHelper;

$environment = App::env("CRAFT_ENVIRONMENT");
$isDev = $environment === "dev";
$isProduction = $environment === "production";

return GeneralConfig::create()
    ->allowAdminChanges($isDev)
    ->allowUpdates($isDev)
    ->backupOnUpdate(false)
    ->convertFilenamesToAscii(true)
    ->defaultWeekStartDay(1) // Monday
    ->devMode($isDev)
    ->disallowRobots(!$isProduction)
    ->enableGql(false)
    ->enableTemplateCaching(!$isDev)
    ->limitAutoSlugsToAscii(true)
    ->omitScriptNameInUrls()
    ->preloadSingles()
    ->preventUserEnumeration()
    ->timezone('America/New_York')
    ->useEmailAsUsername()
    ->verificationCodeDuration("P1W")
    ->aliases([
        '@webroot' => dirname(__DIR__) . '/web',
        '@web' => App::env('PRIMARY_SITE_URL'),
        '@primarySiteUrl' => StringHelper::removeRight(App::env('PRIMARY_SITE_URL'), '/'),
    ]);
