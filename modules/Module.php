<?php

namespace modules;

use Craft;
use craft\events\CancelableEvent;
use yii\base\Event;
use yii\base\Module as BaseModule;

/**
 * Site module
 *
 * @method static Module getInstance()
 */
class Module extends BaseModule
{
    // Public Methods
    // =========================================================================

    /**
     * @inheritdoc
     */
    public function init(): void
    {
        Craft::setAlias('@modules', __DIR__);

        // Set the controllerNamespace based on whether this is a console or web request
        if (Craft::$app->request->isConsoleRequest) {
            $this->controllerNamespace = 'modules\\console\\controllers';
        } else {
            $this->controllerNamespace = 'modules\\controllers';
        }

        parent::init();

        $this->_attachEventHandlers();
    }

    // Private Methods
    // =========================================================================

    /**
     * Registers the module's event handlers.
     */
    private function _attachEventHandlers(): void
    {
        // Logged-in renders can carry the viget-base Edit Entry button, so Blitz must never store
        // or serve them. Blitz isn't a starter dependency, so its class and event are named as strings.
        Event::on(
            'putyourlightson\blitz\services\CacheRequestService',
            'isCacheableRequest',
            function(CancelableEvent $event) {
                if (!Craft::$app->getUser()->getIsGuest() || Craft::$app->getConfig()->getGeneral()->devMode) {
                    $event->isValid = false;
                }
            }
        );
    }
}
