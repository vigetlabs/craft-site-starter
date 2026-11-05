<?php

namespace craft\contentmigrations;

use craft\db\Migration;
use craft\helpers\App;

/**
 * Testing aid, not for merging: a content migration that only sleeps, to hold
 * `craft up` open long enough to see what visitors get while a deploy runs
 * migrations.
 *
 * The sleep defaults to 10 minutes. Set SLEEP_MIGRATION_SECONDS to change it:
 *
 *   ddev exec SLEEP_MIGRATION_SECONDS=120 php craft up
 *
 * It reverts cleanly, so it can be run again:
 *
 *   ddev craft migrate/redo --track=content --interactive=0
 */
class m261105_120000_long_running_sleep extends Migration
{
    private const DEFAULT_SECONDS = 600;
    private const TICK_SECONDS = 10;

    /**
     * @inheritdoc
     */
    public function safeUp(): bool
    {
        $seconds = (int)(App::env('SLEEP_MIGRATION_SECONDS') ?? self::DEFAULT_SECONDS);
        $started = time();

        echo "    > sleeping for {$seconds}s\n";

        while (($elapsed = time() - $started) < $seconds) {
            sleep(min(self::TICK_SECONDS, $seconds - $elapsed));
            $elapsed = time() - $started;
            echo "    > {$elapsed}s of {$seconds}s\n";
        }

        return true;
    }

    /**
     * @inheritdoc
     */
    public function safeDown(): bool
    {
        return true;
    }
}
