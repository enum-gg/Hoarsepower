local M = {}
local mName = "Hoarsepower"

local function onInitialVehicleDataReceived(vehicleId, power, weight, torque)
    -- log("I", mName, "onInitialVehicleDataReceived: vehicleId: " .. tostring(vehicleId) .. " power:" .. tostring(power) .. " - weight: " .. tostring(weight) .. " - TORQUE: " .. tostring(torque))
    local vehicle = be:getObjectByID(vehicleId)
    if vehicle then
        vehicle:queueLuaCommand(string.format([=[
            local fuelRemaining = energyStorage.getStorages().mainTank.remainingVolume
            local vehId = obj:getId()
            local power = %f
            local weight = %f
            local torque = %f

            obj:queueGameEngineLua("extensions.core_main.onSubsequentVehicleDataReceived(" .. vehId .. ", " .. power .. ", " .. weight .. ", " .. torque .. ", " .. fuelRemaining .. ")")
        ]=], power, weight, torque))
    else
        -- No vehicle yet...
        print("onInitialVehicleDataReceived: Vehicle not found for ID: " .. something)
    end
end

local function onSubsequentVehicleDataReceived(vehicleId, power, weight, torque, fuel)
    local json_data = jsonEncode({
        power = power,
        weight = weight,
        torque = torque,
        fuel = fuel,
    })
    TriggerServerEvent("CLIENT_VEHICLE_POWER", tostring(json_data))
    -- log("I", mName, " DATA: " .. tostring(json_data))
end

AddEventHandler("GIEB_CARPOWER", function(something)
    local vehicle = be:getPlayerVehicle(0)
    if vehicle then
        vehicle:queueLuaCommand(
        [=[
            local engine = powertrain.getDevicesByCategory("engine")[1]
            local power = math.ceil(engine.maxPower * 0.7355) -- PS -> kW
            local weight = obj:calcBeamStats().total_weight
            local torque = engine.torqueData.maxTorque -- NM

            local vehId = obj:getId()
            obj:queueGameEngineLua(string.format([[
                extensions.core_main.onInitialVehicleDataReceived(%d, %f, %f, %f)
            ]], vehId, power, weight, torque))
        ]=]
        )
    else
        -- No vehicle yet...
        print("Vehicle not found for ID: " .. something)
    end
end)

M.onInitialVehicleDataReceived = onInitialVehicleDataReceived
M.onSubsequentVehicleDataReceived = onSubsequentVehicleDataReceived

return M

--[=====[ 
local function onVehicleSpawned(vehicleId)
    local vehicle = be:getObjectByID(vehicleId)
    if vehicle then
        vehicle:queueLuaCommand(
        [=[
            local engine = powertrain.getDevicesByCategory("engine")[1]
            local torque = engine.torqueData.maxTorque -- NM
            local fuelRemaining = energyStorage.getStorages().mainTank.remainingVolume -- NM
            local power = math.ceil(engine.maxPower * 0.7355)
            local weight = obj:calcBeamStats().total_weight
            local vehId = obj:getId()

            obj:queueGameEngineLua(string.format([[
                extensions.core_main.onInitialVehicleDataReceived(%d, %f, %f, %f)
            ]], vehId, power, weight, torque))
        ]=]
        )
    else
        print("Vehicle not found for ID: " .. vehicleId)
    end
end
-- M.onVehicleSpawned = onVehicleSpawned
--]=====]
