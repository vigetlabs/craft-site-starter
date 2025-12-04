<?php

use craft\helpers\Console;
use craft\helpers\StringHelper;

require_once 'ScriptHelpers.php';
require_once 'vendor/autoload.php';

$cwd = getcwd();

/**
 * Prompt the user for input
 */
$projectName = Console::prompt('What is the name of your project (Example: My Client Name)? ', [
    'required' => true,
]);

Console::output("Great! We'll use the name: $projectName");

$suggestedProjectSlug = StringHelper::toKebabCase($projectName);

$projectSlugPrompt = Console::prompt("Customize the project slug? This controls the DDEV URL, etc.", [
    'default' => $suggestedProjectSlug,
]);

$projectSlug = !empty(trim($projectSlugPrompt)) ? StringHelper::toKebabCase($projectSlugPrompt) : $suggestedProjectSlug;

Console::output("Great! We'll use $projectSlug");

/**
 * Update DDEV config
 */

ScriptHelpers::replaceFileText(
    filePath: "$cwd/.ddev/config.yaml",
    pattern: "/name:\s+viget-craft-starter/",
    replacement: "name: $projectSlug",
);

/**
 * Update PRIMARY_SITE_URL in .ddev/.env.web
 */

$primarySiteUrl = "https://$projectSlug.ddev.site";

ScriptHelpers::replaceFileText(
    filePath: "$cwd/.ddev/.env.web",
    pattern: '/PRIMARY_SITE_URL="https?:\/\/[^"]+"/',
    replacement: "PRIMARY_SITE_URL=\"$primarySiteUrl\"",
);

/**
 * Update package.json
 */

ScriptHelpers::replaceFileText(
    filePath: "$cwd/package.json",
    pattern: "/\"name\": \"viget-craft-starter\"/",
    replacement: "\"name\": \"$projectSlug\"",
);

ScriptHelpers::replaceFileText(
    filePath: "$cwd/package-lock.json",
    pattern: "/\"name\": \"viget-craft-starter\"/",
    replacement: "\"name\": \"$projectSlug\"",
);

/**
 * Update project config
 */

// Replace "Viget Craft Starter" site name in every file in the project config directory.
 ScriptHelpers::replaceFileTextInDirectory(
    directoryPath: "$cwd/config/project/",
    pattern: "/Viget Craft Starter/",
    replacement: "$projectName",
);

// Replace plugin license keys.
// These are regenerated when viewing the Control Panel
ScriptHelpers::replaceFileText(
    filePath: "$cwd/config/project/project.yaml",
    pattern: "/    licenseKey: REPLACE[\r\n|\r|\n]/", // Make sure to remove new line too
    replacement: "",
);

/**
 * .gitignore
 */

ScriptHelpers::replaceFileText(
    filePath: "$cwd/.gitignore",
    pattern: "/# BEGIN-STARTER-ONLY\X*# END-STARTER-ONLY/m",
    replacement: '',
);
