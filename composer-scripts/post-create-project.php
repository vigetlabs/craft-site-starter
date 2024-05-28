<?php

use craft\helpers\Console;

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

$suggestedProjectSlug = ScriptHelpers::kebabCase($projectName);

$projectSlugPrompt = Console::prompt("Customize the project slug? This controls the DDEV URL, etc.", [
    'default' => $suggestedProjectSlug,
]);

$projectSlug = !empty(trim($projectSlugPrompt)) ? ScriptHelpers::kebabCase($projectSlugPrompt) : $suggestedProjectSlug;

ScriptHelpers::success("Great! We'll use $projectSlug");

/**
 * Update DDEV config
 */

ScriptHelpers::replaceFileText(
    filePath: "$cwd/.ddev/config.yaml",
    pattern: "/name:\s+viget-craft-starter/",
    replacement: "name: $projectSlug",
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

ScriptHelpers::replaceFileText(
    filePath: "$cwd/config/project/project.yaml",
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

ScriptHelpers::replaceFileText(
    filePath: "$cwd/config/project/siteGroups/805d8826-faed-4186-9b88-f509eb9b07e6.yaml",
    pattern: "/Viget Craft Starter/",
    replacement: "$projectName",
);

ScriptHelpers::replaceFileText(
    filePath: "$cwd/config/project/sites/default--35b563a0-4662-40b9-b885-a8450a2868d9.yaml",
    pattern: "/Viget Craft Starter/",
    replacement: "$projectName",
);

/**
 * .gitignore
 */

ScriptHelpers::replaceFileText(
    filePath: "$cwd/.gitignore",
    pattern: "/# BEGIN-STARTER-ONLY\X*# END-STARTER-ONLY/m",
    replacement: '',
);
