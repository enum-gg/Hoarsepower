local PlayerVehicles = {}
local fuel_density = 0.75 -- kg/L

local function power_to_weight_ratio(kW, kg)
    kW = tonumber(kW)  -- Convert to number
    kg = tonumber(kg)  -- Convert to number

    if not kW or not kg then
        return nil, "Invalid input: kW and kg must be numbers"
    end

    if kg == 0 then
        return nil, "Weight cannot be zero"
    end

    return kW / kg
end

function onPlayerConnecting(playerID)
    if MP.IsPlayerConnected(playerID) then
        PlayerVehicles[playerID] = { power = 0, weight = 0, torque = 0, powerRatio = 0 }
    end
end

function onPlayerDisconnect(playerID)
    PlayerVehicles[playerID] = nil
end

function onVehicleSpawn(playerID, vehicleID, vehicleData)
    MP.TriggerClientEvent(playerID, "GIEB_CARPOWER", "")
end

function onVehicleEdited(playerID, vehicleID, vehicleData)
    MP.TriggerClientEvent(playerID, "GIEB_CARPOWER", "")
end

function onVehicleDeleted(playerID, vehicleID)
    PlayerVehicles[playerID] = nil
end

-- data: power (kw), weight (kg), torque (nm), fuel (L) - JSON encoded
function handleClientData(pid, data)
    PlayerVehicles[pid] = Util.JsonDecode(tostring(data))
    print(tostring(data))
end

MP.RegisterEvent("onPlayerConnecting", "onPlayerConnecting")
MP.RegisterEvent("onPlayerDisconnect", "onPlayerDisconnect")
MP.RegisterEvent("onVehicleEdited", "onVehicleEdited")
MP.RegisterEvent("onVehicleSpawn", "onVehicleSpawn")
MP.RegisterEvent("CLIENT_VEHICLE_POWER", "handleClientData")

function ChatHandler(player_id, player_name, msg)
    if string.match(msg, "/gieb") then
        MP.SendChatMessage(-1, "Power-to-weight ratios are calculated on 20L of fuel")
        for id, data in pairs(PlayerVehicles) do
            local playerName = MP.GetPlayerName(id)
            local current_fuel_weight = data.fuel * fuel_density
            local dry_weight = data.weight - current_fuel_weight

            -- Calculate power-to-weight ratio based on vehicle weight with 20L of fuel.
            local powerRatio, err = power_to_weight_ratio(data.power, dry_weight + (20 * fuel_density))
            if powerRatio then
                local message = playerName .. ": " .. math.floor(data.power) .. "kW @ " .. math.floor(data.torque) .. "nm | " .. math.floor(dry_weight) .. "kg(dry) | " .. math.floor(powerRatio * 100) / 100 .. "kW/kg"
                MP.SendChatMessage(-1, message)
            end
        end        
        return 1
    else
        return 0
    end
end

MP.RegisterEvent("onChatMessage", "ChatHandler")
