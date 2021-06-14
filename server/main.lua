QBCore = nil

TriggerEvent(
    "QBCore:GetObject",
    function(obj)
        QBCore = obj
    end
)

function setCraftingLevel(identifier, level)
    QBCore.Functions.ExecuteSql(false,
        "UPDATE `players` SET `crafting_level`= @xp",
        {["@xp"] = level},
        function()
        end
    )
end

function getCraftingLevel(identifier)
    return tonumber(
        QBCore.Functions.ExecuteSql(true,
            "SELECT `crafting_level` FROM players"
        )
    )
end

function giveCraftingLevel(level)
    QBCore.Functions.ExecuteSql(true,
        "UPDATE `players` SET `crafting_level` = `crafting_level` + @xp",
        {["@xp"] = level},
        function()
        end
    )
end

RegisterServerEvent("core_crafting:setExperiance")
AddEventHandler(
    "core_crafting:setExperiance",
    function(xp)
        setCraftingLevel(xp)
    end
)

RegisterServerEvent("core_crafting:giveExperiance")
AddEventHandler(
    "core_crafting:giveExperiance",
    function(xp)
        giveCraftingLevel(xp)
    end
)

function craft(src, item, retrying)
    local xPlayer = QBCore.Functions.GetPlayer(src)
    local cancraft = true

    local count = Config.Recipes[item].Amount

    if not retrying then
        for k, v in pairs(Config.Recipes[item].Ingredients) do
           -- if xPlayer.Functions.GetItemByName(k).count < v then --This seems to be missing some code somewhere else, a funtion maybe? unsure. Try and craft an item and you will se what i mean. --
            --    cancraft = false
          --  end
		print(k) --debug for the error above
		print(v) --debug for the error above
        end
    end

    if Config.Recipes[item].isGun then
        if cancraft then
            for k, v in pairs(Config.Recipes[item].Ingredients) do
                if not Config.PermanentItems[k] then
                    xPlayer.Functions.RemoveItem(k, v)
                end
            end

            TriggerClientEvent("core_crafting:craftStart", src, item, count)
        else
            TriggerClientEvent("core_crafting:sendMessage", src, Config.Text["not_enough_ingredients"])
        end
    else
        if Config.UseLimitSystem then
            local xItem = xPlayer.Functions.GetItemByName(item)

            if xItem.count + count <= xItem.limit then
                if cancraft then
                    for k, v in pairs(Config.Recipes[item].Ingredients) do
                        xPlayer.Functions.RemoveItem(k, v)
                    end

                    TriggerClientEvent("core_crafting:craftStart", src, item, count)
                else
                    TriggerClientEvent("core_crafting:sendMessage", src, Config.Text["not_enough_ingredients"])
                end
            else
                TriggerClientEvent("core_crafting:sendMessage", src, Config.Text["you_cant_hold_item"])
            end
        else
            if xPlayer.Functions.AddItem(item, count) then
                if cancraft then
                    for k, v in pairs(Config.Recipes[item].Ingredients) do
                        xPlayer.Functions.RemoveItem(k, v)
                    end

                    TriggerClientEvent("core_crafting:craftStart", src, item, count)
                else
                    TriggerClientEvent("core_crafting:sendMessage", src, Config.Text["not_enough_ingredients"])
                end
            else
                TriggerClientEvent("core_crafting:sendMessage", src, Config.Text["you_cant_hold_item"])
            end
        end
    end
end

RegisterServerEvent("core_crafting:itemCrafted")
AddEventHandler(
    "core_crafting:itemCrafted",
    function(item, count)
        local src = source
        local xPlayer = QBCore.Functions.GetPlayer(src)

        if Config.Recipes[item].SuccessRate > math.random(0, Config.Recipes[item].SuccessRate) then
            if Config.UseLimitSystem then
                local xItem = xPlayer.Functions.GetItemByName(item)

                if xItem.count + count <= xItem.limit then
                    if Config.Recipes[item].isGun then
                        xPlayer.Functions.AddItem(item, 0)
                    else
                        xPlayer.Functions.AddItem(item, count)
                    end
                    TriggerClientEvent("core_crafting:sendMessage", src, Config.Text["item_crafted"])
                    giveCraftingLevel(xPlayer.identifier, Config.ExperiancePerCraft)
                else
                    TriggerEvent("core_crafting:craft", item)
                    TriggerClientEvent("core_crafting:sendMessage", src, Config.Text["inv_limit_exceed"])
                end
            else
                if xPlayer.Functions.AddItem(item, count) then
                    if Config.Recipes[item].isGun then
                        xPlayer.Functions.AddItem(item, 0)
                    else
                        xPlayer.Functions.AddItem(item, count)
                    end
                    TriggerClientEvent("core_crafting:sendMessage", src, Config.Text["item_crafted"])
                    giveCraftingLevel(xPlayer.identifier, Config.ExperiancePerCraft)
                else
                    TriggerClientEvent("core_crafting:sendMessage", src, Config.Text["inv_limit_exceed"])
                end
            end
        else
            TriggerClientEvent("core_crafting:sendMessage", src, Config.Text["crafting_failed"])
        end
    end
)

RegisterServerEvent("core_crafting:craft")
AddEventHandler(
    "core_crafting:craft",
    function(item, retrying)
        local src = source
        craft(src, item, retrying)
    end
)

QBCore.Functions.CreateCallback(
    "core_crafting:getXP",
    function(source, cb)
        local xPlayer = QBCore.Functions.GetPlayer(source)

        cb(getCraftingLevel(xPlayer.identifier))
    end
)

QBCore.Functions.CreateCallback(
	"core_crafting:getItemNames",
	function(source, cb)
		local names = {}
		for key, value in pairs(QBCore.Shared.Items) do
			names[key] = QBCore.Shared.Items[key]["label"]
		end
		cb(names)
	end
)

RegisterCommand(
    "givecraftingxp",
    function(source, args, rawCommand)
        if source ~= 0 then
            local xPlayer = QBCore.Functions.GetPlayer(source)

            if xPlayer.Functions.GetPermission() == "admin" or xPlayer.Functions.GetPermission() == "superadmin" then
                if args[1] ~= nil then
                    local xTarget = QBCore.Functions.GetPlayer(tonumber(args[1]))
                    if xTarget ~= nil then
                        if args[2] ~= nil then
                            giveCraftingLevel(xTarget.identifier, tonumber(args[2]))
                        else
                            TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
                        end
                    else
                        TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
                    end
                else
                    TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
                end
            else
                TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
            end
        end
    end,
    false
)

RegisterCommand(
    "setcraftingxp",
    function(source, args, rawCommand)
        if source ~= 0 then
            local xPlayer = QBCore.Functions.GetPlayer(source)

            if xPlayer.Functions.GetPermission() == "admin" or xPlayer.Functions.GetPermission() == "superadmin" then
                if args[1] ~= nil then
                    local xTarget = QBCore.Functions.GetPlayer(tonumber(args[1]))
                    if xTarget ~= nil then
                        if args[2] ~= nil then
                            setCraftingLevel(xTarget.identifier, tonumber(args[2]))
                        else
                            TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
                        end
                    else
                        TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
                    end
                else
                    TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
                end
            else
                TriggerClientEvent("core_multijob:sendMessage", source, Config.Text["wrong_usage"])
            end
        end
    end,
    false
)
