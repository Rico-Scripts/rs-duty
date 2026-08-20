local ESX = exports['es_extended']:getSharedObject()

local RESOURCE = GetCurrentResourceName()
local DutyPlayers = {}

local function debugLog(...)
    if not Config.Debug then return end
    print(('[%s] [DEBUG]'):format(RESOURCE), ...)
end

local function sendWebhook(title, description, color)
    if not Config.Webhook or Config.Webhook == '' then return end

    PerformHttpRequest(
        Config.Webhook,
        function(status)
            if status < 200 or status >= 300 then
                print(('[%s] [WARN] webhook status: %s'):format(RESOURCE, status))
            end
        end,
        'POST',
        json.encode({
            username = Config.WebhookName or 'RS Duty',
            embeds = {{
                title = title,
                description = description,
                color = color or 3447003,
                footer = { text = os.date('!%Y-%m-%d %H:%M:%S UTC') }
            }}
        }),
        { ['Content-Type'] = 'application/json' }
    )
end

local function getPlayer(src)
    return ESX.GetPlayerFromId(src)
end

local function allowedJob(jobName)
    if not jobName or jobName == '' then return false end
    if not Config.AllowedJobs or next(Config.AllowedJobs) == nil then
        return true
    end
    return Config.AllowedJobs[jobName] == true
end

local function setStateBag(src, onDuty, jobName)
    local player = Player(src)
    if not player then return end

    player.state:set('rsDuty', onDuty == true, true)
    player.state:set('rsDutyJob', onDuty == true and jobName or nil, true)
end

local function setDuty(src, value, reason)
    local xPlayer = getPlayer(src)
    if not xPlayer or not xPlayer.job then
        return false, 'Speler of job niet gevonden.'
    end

    local jobName = xPlayer.job.name

    if value == true and not allowedJob(jobName) then
        return false, 'Deze job ondersteunt geen dienststatus.'
    end

    DutyPlayers[src] = {
        onDuty = value == true,
        job = value == true and jobName or nil,
        since = value == true and os.time() or nil
    }

    setStateBag(src, value == true, jobName)

    TriggerClientEvent(
        'rs-duty:client:update',
        src,
        value == true,
        jobName
    )

    sendWebhook(
        value == true and 'In dienst' or 'Uit dienst',
        ('**Speler:** %s\n**Server ID:** %s\n**Job:** %s\n**Rang:** %s\n**Reden:** %s'):format(
            GetPlayerName(src) or 'Onbekend',
            src,
            jobName,
            tostring(xPlayer.job.grade_label or xPlayer.job.grade_name or xPlayer.job.grade or ''),
            tostring(reason or 'toggle')
        ),
        value == true and 5763719 or 15548997
    )

    debugLog(('Duty %s -> %s (%s)'):format(src, tostring(value == true), jobName))
    return true, value == true and 'Je bent nu in dienst.' or 'Je bent nu uit dienst.'
end

local function isOnDuty(src)
    local entry = DutyPlayers[src]
    if not entry or entry.onDuty ~= true then
        return false
    end

    local xPlayer = getPlayer(src)
    if not xPlayer or not xPlayer.job then
        return false
    end

    return entry.job == xPlayer.job.name
end

local function toggleDuty(src)
    return setDuty(src, not isOnDuty(src), 'toggle')
end

RegisterNetEvent('rs-duty:server:toggle', function()
    local src = source
    local ok, message = toggleDuty(src)
    TriggerClientEvent('rs-duty:client:notify', src, message, ok)
end)

RegisterNetEvent('rs-duty:server:set', function(value)
    local src = source
    if type(value) ~= 'boolean' then return end

    local ok, message = setDuty(src, value, 'event')
    TriggerClientEvent('rs-duty:client:notify', src, message, ok)
end)

AddEventHandler('esx:playerLoaded', function(playerId)
    local src = tonumber(playerId) or source
    if src <= 0 then return end

    local xPlayer = getPlayer(src)
    if not xPlayer or not xPlayer.job then return end

    if Config.DefaultOffDuty then
        setDuty(src, false, 'playerLoaded')
    else
        DutyPlayers[src] = {
            onDuty = true,
            job = xPlayer.job.name,
            since = os.time()
        }
        setStateBag(src, true, xPlayer.job.name)
    end
end)

RegisterNetEvent('esx:setJob', function(job)
    local src = source
    if not Config.ResetOnJobChange then return end

    local current = DutyPlayers[src]
    if current and current.onDuty and current.job ~= job.name then
        DutyPlayers[src] = {
            onDuty = false,
            job = nil,
            since = nil
        }
        setStateBag(src, false, nil)
        TriggerClientEvent('rs-duty:client:update', src, false, job.name)
    end
end)

AddEventHandler('playerDropped', function()
    DutyPlayers[source] = nil
end)

exports('IsOnDuty', function(src)
    return isOnDuty(tonumber(src))
end)

exports('SetDuty', function(src, value)
    return setDuty(tonumber(src), value == true, 'export')
end)

exports('ToggleDuty', function(src)
    return toggleDuty(tonumber(src))
end)

exports('GetDutyData', function(src)
    local entry = DutyPlayers[tonumber(src)]
    if not entry then
        return { onDuty = false, job = nil, since = nil }
    end

    return {
        onDuty = entry.onDuty == true,
        job = entry.job,
        since = entry.since
    }
end)

print(('[%s] [OK] RS Duty gestart.'):format(RESOURCE))
