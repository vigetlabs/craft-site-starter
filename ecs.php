<?php

declare(strict_types=1);

use craft\ecs\SetList;
use Symplify\EasyCodingStandard\Config\ECSConfig;

return static function(ECSConfig $ecsConfig): void {
    $ecsConfig->parallel();
    $ecsConfig->paths([
        __DIR__ . '/modules',
        __DIR__ . '/install-scripts',
        __DIR__ . '/bootstrap.php',
        __DIR__ . '/web/index.php',
        __FILE__,
    ]);

    // TODO waiting on this PR or similar https://github.com/craftcms/ecs/pull/4
    $ecsConfig->sets([SetList::CRAFT_CMS_4]); // for Craft 4 projects
};
