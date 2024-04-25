<?php

require_once 'ScriptHelpers.php';

$cwd = getcwd();

$file_path = "$cwd/.ddev/config.yaml";

$projectName = ScriptHelpers::kebabCase((string) readline('What is the name of your project (kebab-case)?'));

// Read the content of the file into a string
$file_content = file_get_contents($file_path);

// Perform the replacement
$file_content = ScriptHelpers::replaceText(
    subject: $file_content,
    pattern: '/name:\s+craft-starter/',
    replacement: "name: $projectName",
);

file_put_contents($file_path, $file_content);

ScriptHelpers::success("Your DDEV project is now named $projectName!");