print("^0================================^7")
print("^0[^0Delivery Job^0] ^7By^0 ^5TinoKi^7")
print("^0[^2Download^0] ^7:^0 ^5Tebex^7")
print("^0================================^7")

ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('tinoki-deliveryjob:payoutPlayer')
AddEventHandler('tinoki-deliveryjob:payoutPlayer', function(mission)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    local amount = Config.Payouts[mission]
    TriggerClientEvent("pNotify:SendNotification", source, {text = "You've been paid", timeout = 4000}) 
    xPlayer.addMoney(amount)
end)