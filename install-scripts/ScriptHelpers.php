<?php

class ScriptHelpers
{
    /**
     * Escape character
     */
    const ESC = "\033";

    /**
     * ANSI colours
     */
    const ANSI_BLACK = self::ESC . "[30m";
    const ANSI_RED = self::ESC . "[31m";
    const ANSI_GREEN = self::ESC . "[32m";
    const ANSI_YELLOW = self::ESC . "[33m";
    const ANSI_BLUE = self::ESC . "[34m";
    const ANSI_MAGENTA = self::ESC . "[35m";
    const ANSI_CYAN = self::ESC . "[36m";
    const ANSI_WHITE = self::ESC . "[37m";

    /**
     * ANSI background colours
     */
    const ANSI_BACKGROUND_BLACK = self::ESC . "[40m";
    const ANSI_BACKGROUND_RED = self::ESC . "[41m";
    const ANSI_BACKGROUND_GREEN = self::ESC . "[42m";
    const ANSI_BACKGROUND_YELLOW = self::ESC . "[43m";
    const ANSI_BACKGROUND_BLUE = self::ESC . "[44m";
    const ANSI_BACKGROUND_MAGENTA = self::ESC . "[45m";
    const ANSI_BACKGROUND_CYAN = self::ESC . "[46m";
    const ANSI_BACKGROUND_WHITE = self::ESC . "[47m";

    /**
     * ANSI styles
     */
    const ANSI_BOLD = self::ESC . "[1m";
    const ANSI_ITALIC = self::ESC . "[3m"; // limited support. ymmv.
    const ANSI_UNDERLINE = self::ESC . "[4m";
    const ANSI_STRIKETHROUGH = self::ESC . "[9m";

    /**
     * Clear all ANSI styling
     */
    const ANSI_CLOSE = self::ESC . "[0m";

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

    public static function replaceText(string $subject, string $pattern, string $replacement): string
    {
        return preg_replace($pattern, $replacement, $subject);
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