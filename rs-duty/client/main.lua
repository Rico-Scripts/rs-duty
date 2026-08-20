local ESX = exports['es_extended']:getSharedObject()

local onDuty = false
local dutyJob = nil

local function notify(message, success)
    if lib and lib.notify then
        lib.notify({
            title = 'Dienst',
            description = tostring(message or ''),
            type = success == false and 'error' or 'success'
        })
        return
    end

    ESX.ShowNotification(tostring(message or ''))
end

RegisterNetEvent('rs-duty:client:notify', function(message, success)
    notify(message, success)
end)

RegisterNetEvent('rs-duty:client:update', function(value, jobName)
    onDuty = value == true
    dutyJob = onDuty and jobName or nil

    TriggerEvent('rs-duty:client:changed', onDuty, dutyJob)
end)

CreateThread(function()
    Wait(1000)

    onDuty = LocalPlayer.state.rsDuty == true
    dutyJob = LocalPlayer.state.rsDutyJob
end)

exports('IsOnDuty', function()
    return LocalPlayer.state.rsDuty == true
end)

exports('GetDutyJob', function()
    return LocalPlayer.state.rsDutyJob
end)
