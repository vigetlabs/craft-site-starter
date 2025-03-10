<?php

class ScriptHelpers
{
    /**
     * Replace text in a singlefile.
     *
     * @param string $filePath
     * @param string $pattern
     * @param string $replacement
     */
    public static function replaceFileText(string $filePath, string $pattern, string $replacement): void
    {
        $fileContent = file_get_contents($filePath);
        $fileContent = preg_replace($pattern, $replacement, $fileContent);
        file_put_contents($filePath, $fileContent);
    }

    /**
     * Replace text in all files in a directory.
     * Recursively searches subdirectories.
     *
     * @param string $directoryPath
     * @param string $pattern
     * @param string $replacement
     */
    public static function replaceFileTextInDirectory(string $directoryPath, string $pattern, string $replacement): void
    {
        $files = glob($directoryPath . '/*');
        foreach ($files as $file) {
            if (is_file($file)) {
                self::replaceFileText($file, $pattern, $replacement);
            } elseif (is_dir($file)) {
                self::replaceFileTextInDirectory($file, $pattern, $replacement);
            }
        }
    }
}
