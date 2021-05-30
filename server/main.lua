ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_tattooshop:requestPlayerTattoos', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer then
		MySQL.Async.fetchAll('SELECT tattoos FROM users WHERE identifier = @identifier', {
			['@identifier'] = xPlayer.identifier
		}, function(result)
			if result[1].tattoos then
				cb(json.decode(result[1].tattoos))
			else
				cb()
			end
		end)
	else
		cb()
	end
end)

ESX.RegisterServerCallback('esx_tattooshop:purchaseTattoo', function(source, cb, tattooList, price, tattoo)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= price then
		xPlayer.removeMoney(price)
		table.insert(tattooList, tattoo)

		MySQL.Async.execute('UPDATE users SET tattoos = @tattoos WHERE identifier = @identifier', {
			['@tattoos'] = json.encode(tattooList),
			['@identifier'] = xPlayer.identifier
		})
		TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = "تتو خریداری شد!", type = "success", timeout = 3000, layout = "bottomCenter"})
		cb(true)
	else
		TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = "شما پول کافی ندارید!", type = "error", timeout = 3000, layout = "bottomCenter"})
		cb(false)
	end
end)

ESX.RegisterServerCallback('esx_tattooshop:del', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getMoney() >= 200 then
		xPlayer.removeMoney(200)
		MySQL.Async.execute('UPDATE users SET tattoos = @tattoos WHERE identifier = @identifier', {
			['@tattoos'] = '[]',
			['@identifier'] = xPlayer.identifier
		})
		TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = "تتو حذف شد!", type = "success", timeout = 3000, layout = "bottomCenter"})
		
        cb(true)
	else
		TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = "شما پول کافی ندارید!", type = "error", timeout = 3000, layout = "bottomCenter"})
		cb(false)
	end
end)