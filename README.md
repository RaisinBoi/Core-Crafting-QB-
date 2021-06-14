--------------------------------------------------------
CORE RESOURCES
--------------------------------------------------------

Basic Installation:

* Put core_crafting in resources folder
* Start the resource in your cfg file

100 XP = 1 LEVEL

TRIGGERS:

SET USER EXPERIANCE
CLIENT SIDE: TriggerServerEvent('core_crafting:setExperiance', identifier, xp)
SERVER SIDE: TriggerEvent('core_crafting:setExperiance', identifier, xp)

GIVE USER EXPERIANCE
CLIENT SIDE: TriggerServerEvent('core_crafting:giveExperiance', identifier, xp)
SERVER SIDE: TriggerEvent('core_crafting:giveExperiance', identifier, xp)