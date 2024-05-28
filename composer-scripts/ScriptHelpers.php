<?php

class ScriptHelpers
{
    public static function replaceFileText(string $filePath, string $pattern, string $replacement): void
    {
        $fileContent = file_get_contents($filePath);
        $fileContent = preg_replace($pattern, $replacement, $fileContent);
        file_put_contents($filePath, $fileContent);
    }
}
