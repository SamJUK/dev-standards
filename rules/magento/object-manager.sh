#!/bin/sh
exec "$(dirname "$0")/../lib/added-lines.sh" magento-object-manager 'ObjectManager::getInstance\(' \
    'Inject dependencies instead of using the ObjectManager:' "$@"
