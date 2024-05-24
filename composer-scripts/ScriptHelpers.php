<?php

class ScriptHelpers
{
    /**
     * Escape character
     */
    public const ESC = "\033";

    /**
     * ANSI colours
     */
    public const ANSI_BLACK = self::ESC . "[30m";
    public const ANSI_RED = self::ESC . "[31m";
    public const ANSI_GREEN = self::ESC . "[32m";
    public const ANSI_YELLOW = self::ESC . "[33m";
    public const ANSI_BLUE = self::ESC . "[34m";
    public const ANSI_MAGENTA = self::ESC . "[35m";
    public const ANSI_CYAN = self::ESC . "[36m";
    public const ANSI_WHITE = self::ESC . "[37m";

    /**
     * ANSI background colours
     */
    public const ANSI_BACKGROUND_BLACK = self::ESC . "[40m";
    public const ANSI_BACKGROUND_RED = self::ESC . "[41m";
    public const ANSI_BACKGROUND_GREEN = self::ESC . "[42m";
    public const ANSI_BACKGROUND_YELLOW = self::ESC . "[43m";
    public const ANSI_BACKGROUND_BLUE = self::ESC . "[44m";
    public const ANSI_BACKGROUND_MAGENTA = self::ESC . "[45m";
    public const ANSI_BACKGROUND_CYAN = self::ESC . "[46m";
    public const ANSI_BACKGROUND_WHITE = self::ESC . "[47m";

    /**
     * ANSI styles
     */
    public const ANSI_BOLD = self::ESC . "[1m";
    public const ANSI_ITALIC = self::ESC . "[3m"; // limited support. ymmv.
    public const ANSI_UNDERLINE = self::ESC . "[4m";
    public const ANSI_STRIKETHROUGH = self::ESC . "[9m";

    /**
     * Clear all ANSI styling
     */
    public const ANSI_CLOSE = self::ESC . "[0m";

    public static function output(string $message): int|false
    {
        return fwrite(STDOUT, $message . PHP_EOL);
    }

    public static function success(string $message): int|false
    {
        return fwrite(STDOUT, self::ANSI_GREEN . $message . self::ANSI_CLOSE . PHP_EOL);
    }

    public static function error(string $message): int|false
    {
        return fwrite(STDERR, self::ANSI_RED . $message . self::ANSI_CLOSE . PHP_EOL);
    }

    public static function replaceFileText(string $filePath, string $pattern, string $replacement): void
    {
        $fileContent = file_get_contents($filePath);
        $fileContent = preg_replace($pattern, $replacement, $fileContent);
        file_put_contents($filePath, $fileContent);
    }

    public static function kebabCase(string $string)
    {
        // Remove special characters and replace them with spaces
        $string = preg_replace('/[^a-zA-Z0-9\s]/', ' ', $string);

        // Trim whitespace
        $string = trim($string);

        // Split the string into words
        $words = preg_split('/\s+/', $string);

        // Lowercase each word and join them with dashes
        return strtolower(implode('-', $words));
    }
}
