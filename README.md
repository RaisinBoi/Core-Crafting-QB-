So as of right now, this is "semi working" It is currently not reading/updating your crafting level from the SQL correctly, and if you comment in what i have commented out on line 60 of server main.lua you will notice you cant craft, and it gives an error. The error is the following: 

[      script:qb-core] SCRIPT ERROR: @qb-core/server/functions.lua:8: attempt to call a table value (upvalue 'cb')
[      script:qb-core] > ref (@qb-core/server/functions.lua:8)
[      script:qb-core] > <unknown> (@ghmattimysql/ghmattimysql-server.js:1)
  
 One of the SQL errors is as follows:
  
[ script:ghmattimysql] [MySQL] [ERROR] [qb-core] An error happens for query "UPDATE `players` SET `crafting_level`= `crafting_level` + @xp : []": ER_BAD_NULL_ERROR: Column 'crafting_level' cannot be null


  If you figure it out let me know!
  Thanks to @NikkerTV#0001, Nope#6666 and eMINENCE!#8180 for the help. I will continue to try and fix this script, i am putting it out like this in hopes someone else can fix it faster then me. :)









(ORIGINAL README)
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
