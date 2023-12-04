local RSGCore = exports['rsg-core']:GetCoreObject()

RSGCore.Functions.CreateUseableItem('advent_calendar', function(source, item)
    local Player = RSGCore.Functions.GetPlayer(source)
    if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("hdrp-advent-calendar:client:open", source)
    end
end)

local function AddItem(name, count, source)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.AddItem(name, count, nil, nil)
    TriggerClientEvent("inventory:client:ItemBox", src, RSGCore.Shared.Items[name], "add", count)
end

local function AddMoney(type, count, source)
    local src = source 
    local Player = RSGCore.Functions.GetPlayer(src)
    Player.Functions.AddMoney(type, count)
end

RegisterNetEvent('hdrp-advent-calendar:server:giveitems')
AddEventHandler('hdrp-advent-calendar:server:giveitems', function(prizeName)
    local src = source

    local Player = RSGCore.Functions.GetPlayer(src)
    local citizenid = Player.PlayerData.citizenid
    local currentDate = os.date("*t")

    local isMatchingDate = currentDate.year == targetDate.year and currentDate.month >= targetDate.month and currentDate.day >= targetDate.day
    if not isMatchingDate then
        return 
        lib.notify(src, { 
            title = 'Advent Calendar', 
            description = "This isn't the correct day to open.",
            icon = "fa-solid fa-calendar-day",
            type = 'inform',
            duration = 7500
        })
    end

    local hasReceivedPrize = MySQL.Sync.fetchScalar(
        "SELECT COUNT(*) FROM player_prizes WHERE citizenid = @citizenid AND prize_name = @prizeName", {
            ['@citizenid'] = citizenid,
            ['@prizeName'] = prizeName
        }
    )
    if hasReceivedPrize == 0 then
        local dateData = Config.Days[prizeName]
        lib.callback.await('hdrp-advent-calendar:server:progress', src, text)
        if dateData.cash then
            if dateData.cash.money then
                AddMoney('money', dateData.cash.money, src)
                lib.notify(src, {
                    title = 'Advent Calendar',
                    description = "You successfully received money with an amount of: " .. dateData.cash.money .. "",
                    type = 'success'
                })
            end
            if dateData.cash.bank then
                AddMoney('bank', dateData.cash.bank, src)
                lib.notify(src, {
                    title = 'Calendar',
                    description = "$" .. dateData.cash.bank .. " was deposited in your bank account",
                    icon = "fa-solid fa-calendar-day",
                    duration = 7500,
                    type = 'success'
                })
            end
        end
        if dateData and type(dateData.items) == "table" then
            for _, item in ipairs(dateData.items) do
                local itemstogive = item.name
                AddItem(itemstogive, item.quantity, src)
            end
        else
            print("No items to give or invalid item data for prizeName: " .. prizeName)
        end
        MySQL.Async.execute(
            "INSERT INTO player_prizes (citizenid, prize_name) VALUES (@citizenid, @prizeName)", {
                ['@citizenid'] = citizenid,
                ['@prizeName'] = prizeName
            }
        )
    else
        lib.notify(src, { 
            title = 'Advent Calendar',
            description = 'You have already opened the Advent Calendar for this day',
            icon = "fa-solid fa-calendar-day",
            type = 'error',
            duration = 7500 
        })
    end
end)

lib.callback.register('wn_adventcalendar:getDate', function()
    local currentDate = os.date("*t")  -- Get the current date and time
    return ({day = currentDate.day, month = currentDate.month, year = currentDate.year})
end)