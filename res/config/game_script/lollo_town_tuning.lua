local commonData = require('lollo_building_tuning.commonData')
local function _myErrorHandler(err)
    print('lollo town tuning caught error: ', err)
end

local _eventId = '__lolloTownTuningEvent__'
local _state = {
    townId4CapacityFactorNeedingUpdate = false,
    townId4ConsumptionFactorNeedingUpdate = false
}
local _utils = {
    guiAddTownStatButtons = function(windowId, townId, common)
        -- LOLLO TODO put this in a UI that is common to all towns
        print('town stats window opened, id, name, param, api.gui.util.getById ==')
        -- debugPrint(windowId)
        -- debugPrint(name)
        -- debugPrint(param)
        -- debugPrint(api.gui.util.getById(windowId))

        local windowContent = api.gui.util.getById(windowId):getContent()
        local editorTab = windowContent:getTab(3)
        local editorTabLayout = editorTab:getLayout()

        local consumptionFactorTextViewTitle = api.gui.comp.TextView.new('Consumption Factor')

        local consumptionFactorTextViewDown = api.gui.comp.TextView.new("-")
        local consumptionFactorButtonDown = api.gui.comp.Button.new(consumptionFactorTextViewDown, true)
        consumptionFactorButtonDown:setId('lolloConsumptionFactorButtonDown_' .. tostring(townId))
        -- buttonDown:setStyleClassList({ "negative" })

        local consumptionFactorTextViewValue = api.gui.comp.TextView.new(tostring(common.consumptionFactor))
        consumptionFactorTextViewValue:setId('lolloConsumptionFactorValue_' .. tostring(townId))

        local consumptionFactorTextViewUp = api.gui.comp.TextView.new("+")
        local consumptionFactorButtonUp = api.gui.comp.Button.new(consumptionFactorTextViewUp, true)
        consumptionFactorButtonUp:setId('lolloConsumptionFactorButtonUp_' .. tostring(townId))
        -- buttonUp:setStyleClassList({ "positive" })

        local capacityFactorTextViewTitle = api.gui.comp.TextView.new('Capacity Factor')

        local capacityFactorTextViewDown = api.gui.comp.TextView.new("-")
        local capacityFactorButtonDown = api.gui.comp.Button.new(capacityFactorTextViewDown, true)
        capacityFactorButtonDown:setId('lolloCapacityFactorButtonDown_' .. tostring(townId))
        -- buttonDown:setStyleClassList({ "negative" })

        local capacityFactorTextViewValue = api.gui.comp.TextView.new(tostring(common.capacityFactor))
        capacityFactorTextViewValue:setId('lolloCapacityFactorValue_' .. tostring(townId))

        local capacityFactorTextViewUp = api.gui.comp.TextView.new("+")
        local capacityFactorButtonUp = api.gui.comp.Button.new(capacityFactorTextViewUp, true)
        capacityFactorButtonUp:setId('lolloCapacityFactorButtonUp_' .. tostring(townId))
        -- buttonUp:setStyleClassList({ "positive" })

        editorTabLayout:addItem(capacityFactorTextViewTitle)
        local capacityTable = api.gui.comp.Table.new(1, 'NONE')
        capacityTable:setNumCols(3)
        capacityTable:addRow({capacityFactorButtonDown, capacityFactorTextViewValue, capacityFactorButtonUp})
        editorTabLayout:addItem(capacityTable)

        editorTabLayout:addItem(consumptionFactorTextViewTitle)
        local consumptionTable = api.gui.comp.Table.new(1, 'NONE')
        consumptionTable:setNumCols(3)
        consumptionTable:addRow({consumptionFactorButtonDown, consumptionFactorTextViewValue, consumptionFactorButtonUp})
        editorTabLayout:addItem(consumptionTable)
    end,
    guiUpdateCapacityFactorValue = function()
        if type(_state.townId4CapacityFactorNeedingUpdate) ~= 'number' then return end

        local capacityFactorValue = api.gui.util.getById('lolloCapacityFactorValue_' .. tostring(_state.townId4CapacityFactorNeedingUpdate))
        if capacityFactorValue then
            capacityFactorValue:setText(tostring(commonData.common.get().capacityFactor or 'NIL'))
        end
        _state.townId4CapacityFactorNeedingUpdate = false
    end,
    guiUpdateConsumptionFactorValue = function()
        if type(_state.townId4ConsumptionFactorNeedingUpdate) ~= 'number' then return end

        local consumptionFactorValue = api.gui.util.getById('lolloConsumptionFactorValue_' .. tostring(_state.townId4ConsumptionFactorNeedingUpdate))
        if consumptionFactorValue then
            consumptionFactorValue:setText(tostring(commonData.common.get().consumptionFactor or 'NIL'))
        end
        _state.townId4ConsumptionFactorNeedingUpdate = false
    end,
    initTowns = function()
        local townCapacities = api.engine.system.townBuildingSystem.getTown2personCapacitiesMap()
        local towns = commonData.towns.get()
        if not(townCapacities) or #towns > 0 then return end

        for id, personCapacities in pairs(townCapacities) do
            towns[id] = {
                personCapacities = personCapacities,
                townStatWindowId = 'temp.view.entity_' .. tostring(id)
            }
        end

        commonData.towns.set(towns)
        print('commonData.towns.get() =')
        debugPrint(commonData.towns.get())
    end,
    updateCapacityFactorValue = function(townId)
        _state.townId4CapacityFactorNeedingUpdate = townId
    end,
    updateConsumptionFactorValue = function(townId)
        _state.townId4ConsumptionFactorNeedingUpdate = townId
    end,
--[[     replaceBuildingWithSelf_dumps = function(oldBuildingId)
        print('oldBuildingId =', oldBuildingId or 'NIL')
        if type(oldBuildingId) ~= 'number' or oldBuildingId < 0 then return end

        local oldBuilding = api.engine.getComponent(oldBuildingId, api.type.ComponentType.TOWN_BUILDING)
        print('oldBuilding =')
        debugPrint(oldBuilding)
        -- if not(oldBuilding) or not(oldBuilding.personCapacity) or not(oldBuilding.stockList) then return end
        -- skip buildings that do not accept stuff
        if not(oldBuilding) or not(oldBuilding.personCapacity)
        or type(oldBuilding.stockList) ~= 'number' or oldBuilding.stockList < 0 then return end

        local oldConstructionId = oldBuilding.personCapacity -- whatever they were thinking
        print('oldConstructionId =', oldConstructionId or 'NIL')
        if true then return end
        local oldConstruction = api.engine.getComponent(oldConstructionId, api.type.ComponentType.CONSTRUCTION)
        print('oldConstruction =')
        debugPrint(oldConstruction)

        local sampleCommercialConstruction = {
            fileName = "building/era_b/com_1_2x3_01.con",
            params = {
                capacity = 3,
                cargoTypes = {
                    [1] = "TOOLS",
                },
                depth = 30,
                parcelFace = {
                    [1] = {
                    [1] = -8.6212158203125,
                    [2] = 0.100341796875,
                    [3] = 0.046108245849609,
                    },
                    [2] = {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    },
                    [3] = {
                    [1] = 8.5859375,
                    [2] = 0.100341796875,
                    [3] = -0.57262802124023,
                    },
                    [4] = {
                    [1] = 8.02685546875,
                    [2] = 24.093505859375,
                    [3] = -0.57262802124023,
                    },
                    [5] = {
                    [1] = -0.0013427734375,
                    [2] = 24.000244140625,
                    [3] = 0,
                    },
                    [6] = {
                    [1] = -8.0616455078125,
                    [2] = 24.093505859375,
                    [3] = 0.046108245849609,
                    },
                },
                seed = -26138,
                width = 20,
            },
            -- transf = {
            --   cols = <function>,
            -- },
            timeBuilt = 0,
            frozenNodes = {
            },
            frozenEdges = {
            },
            depots = {
            },
            stations = {
            },
            simBuildings = {
            },
            townBuildings = {
                [1] = 5756,
            },
            particleSystems = {
                [1] = 23559,
            },
        }

        local sampleResidentialConstruction = {
            fileName = "building/era_b/res_1_4x4_04.con",
            params = {
                capacity = 4,
                cargoTypes = {
                },
                depth = 40,
                parcelFace = {
                    [1] = {
                    [1] = -16.015747070313,
                    [2] = -0.000244140625,
                    [3] = -0.30424308776855,
                    },
                    [2] = {
                    [1] = -8.00634765625,
                    [2] = 0.000244140625,
                    [3] = -0.24058723449707,
                    },
                    [3] = {
                    [1] = 0,
                    [2] = 0,
                    [3] = 0,
                    },
                    [4] = {
                    [1] = 8.0028076171875,
                    [2] = -0.000244140625,
                    [3] = 0.38837242126465,
                    },
                    [5] = {
                    [1] = 16.001953125,
                    [2] = -0.000244140625,
                    [3] = 0.89117240905762,
                    },
                    [6] = {
                    [1] = 16.001708984375,
                    [2] = 31.999755859375,
                    [3] = 0.89117240905762,
                    },
                    [7] = {
                    [1] = 8.0029296875,
                    [2] = 31.999755859375,
                    [3] = 0.38837242126465,
                    },
                    [8] = {
                    [1] = 0,
                    [2] = 32,
                    [3] = 0,
                    },
                    [9] = {
                    [1] = -8.0062255859375,
                    [2] = 32.000244140625,
                    [3] = -0.24058723449707,
                    },
                    [10] = {
                    [1] = -16.015869140625,
                    [2] = 31.999755859375,
                    [3] = -0.30424308776855,
                    },
                },
                seed = -26822,
                width = 40,
            },
            -- transf = {
            --   cols = <function>,
            -- },
            timeBuilt = 0,
            frozenNodes = {
            },
            frozenEdges = {
            },
            depots = {
            },
            stations = {
            },
            simBuildings = {
            },
            townBuildings = {
                [1] = 21752,
            },
            particleSystems = {
                [1] = 21753,
                [2] = 21754,
            },
        }
        local newConstruction = api.type.SimpleProposal.ConstructionEntity.new()
        newConstruction.fileName = oldConstruction.fileName
        print('1, fileName =', newConstruction.fileName)

        -- newConstruction.timeBuilt = oldConstruction.timeBuilt -- dumps
        -- newConstruction.simBuildings = oldConstruction.simBuildings -- dumps
        -- newConstruction.townBuildings = oldConstruction.townBuildings
        -- newConstruction.particleSystems = oldConstruction.particleSystems
        print('2')
        print('newConstruction.params before =')
        debugPrint(newConstruction.params)
        print('3')
        -- newConstruction.params = oldConstruction.params -- dumps
        print('4')
        -- cannot clone this userdata dynamically, coz it won't take pairs and ipairs
        -- this table must be handled this way, they are all different...
        newConstruction.params = { -- dumps
            capacity = oldConstruction.params.capacity,
            cargoTypes = oldConstruction.params.cargoTypes,
            depth = oldConstruction.params.depth,
            parcelFace = oldConstruction.params.parcelFace,
            -- seed = oldConstruction.params.seed + 1,
            -- seed = 123e4,
            seed = oldConstruction.params.seed - 1,
            width = oldConstruction.params.width
        }
        print('newConstruction.params =')
        debugPrint(newConstruction.params)
        print('8')
        newConstruction.transf = oldConstruction.transf
        print('9')
        -- newConstruction.name = 'LOLLO snapping lorry bay'
        -- newConstruction.playerEntity = api.engine.util.getPlayer()

        local proposal = api.type.SimpleProposal.new()
        -- LOLLO NOTE there are asymmetries how different tables are handled.
        -- This one requires this system, UG says they will document it or amend it.
        proposal.constructionsToRemove = { oldConstructionId }
        print('10')
        proposal.constructionsToAdd[1] = newConstruction
        print('11')

        local context = api.type.Context:new()
        print('12')
        local cmd = api.cmd.make.buildProposal(proposal, context, true) -- the 3rd param is "ignore errors"
        print('13')
        api.cmd.sendCommand(
            cmd,
            function(res, success)
                -- print('LOLLO replaceBuildingWithSelf_dumps res = ')
                -- debugPrint(res)
                --for _, v in pairs(res.entities) do print(v) end
                -- print('LOLLO replaceBuildingWithSelf_dumps success = ')
                -- debugPrint(success)
                -- if success then
                    -- if I bulldoze here, the station will get the new name
                -- end
            end
        )
    end ]]
}
local _actions = {
    alterCapacityFactor = function(isCapacityFactorUp)
        print('alterCapacityFactor starting, isCapacityFactorUp =', isCapacityFactorUp)
        -- local buildings = api.engine.system.townBuildingSystem.getTown2BuildingMap()[townId]
        -- for _, buildingId in pairs(buildings) do
        --     _utils.replaceBuildingWithSelf_dumps(buildingId)
        -- end
print('commonData.common.get() before =')
debugPrint(commonData.common.get())

print('commonData.towns.get() before =')
debugPrint(commonData.towns.get())
        _utils.initTowns() -- I need this here
        commonData.common.setCapacityFactor(isCapacityFactorUp)
        print('commonData.towns.get() after =')
        debugPrint(commonData.towns.get())
        print('commonData.common.get() after =')
        debugPrint(commonData.common.get())
                
        for townId, _ in pairs(commonData.towns.get()) do
            print('type(townId) = ', type(townId))
            print('townId = ', townId)
            local townData = api.engine.getComponent(townId, api.type.ComponentType.TOWN)
            if not(townData) then return end

            local oldCargoNeeds = townData.cargoNeeds
            if not(oldCargoNeeds) then return end

            -- local cargoSupplyAndLimit = api.engine.system.townBuildingSystem.getCargoSupplyAndLimit(townId)
            -- local newCargoNeeds = oldCargoNeeds
            -- for cargoTypeId, cargoSupply in pairs(cargoSupplyAndLimit) do
            --     print(cargoTypeId, cargoSupply)
            -- end
            api.cmd.sendCommand(
                -- this triggers updateFn for all the town buildings
                -- res, com, ind. LOLLO TODO find out the res, com and ind needs of a town
                -- and replicate them here.
                api.cmd.make.instantlyUpdateTownCargoNeeds(townId, oldCargoNeeds)
            )
        end
    end,
    alterConsumptionFactor = function(isConsumptionFactorUp)
        print('alterConsumptionFactor starting, isConsumptionFactorUp =', isConsumptionFactorUp)
        -- local buildings = api.engine.system.townBuildingSystem.getTown2BuildingMap()[townId]
        -- for _, buildingId in pairs(buildings) do
        --     _utils.replaceBuildingWithSelf_dumps(buildingId)
        -- end
print('commonData.common.get() before =')
debugPrint(commonData.common.get())

print('commonData.towns.get() before =')
debugPrint(commonData.towns.get())
        _utils.initTowns() -- I need this here
        commonData.common.setConsumptionFactor(isConsumptionFactorUp)
        print('commonData.towns.get() after =')
        debugPrint(commonData.towns.get())
        print('commonData.common.get() after =')
        debugPrint(commonData.common.get())
                
        for townId, _ in pairs(commonData.towns.get()) do
            print('type(townId) = ', type(townId))
            print('townId = ', townId)
            local townData = api.engine.getComponent(townId, api.type.ComponentType.TOWN)
            if not(townData) then return end

            local oldCargoNeeds = townData.cargoNeeds
            if not(oldCargoNeeds) then return end

            -- local cargoSupplyAndLimit = api.engine.system.townBuildingSystem.getCargoSupplyAndLimit(townId)
            -- local newCargoNeeds = oldCargoNeeds
            -- for cargoTypeId, cargoSupply in pairs(cargoSupplyAndLimit) do
            --     print(cargoTypeId, cargoSupply)
            -- end
            api.cmd.sendCommand(
                -- this triggers updateFn for all the town buildings
                -- res, com, ind. LOLLO TODO find out the res, com and ind needs of a town
                -- and replicate them here.
                api.cmd.make.instantlyUpdateTownCargoNeeds(townId, oldCargoNeeds)
            )
        end
    end,
    alterTownRequirements = function(townId, consumptionFactorDelta)
        -- LOLLO TODO implement this and its UI
        print('alterTownRequirements starting, townId =', townId, 'consumptionFactorDelta =', consumptionFactorDelta)
        -- local buildings = api.engine.system.townBuildingSystem.getTown2BuildingMap()[townId]
        -- for _, buildingId in pairs(buildings) do
        --     _utils.replaceBuildingWithSelf_dumps(buildingId)
        -- end
        if type(townId) ~= 'number' or townId < 1 then return end

        local townData = api.engine.getComponent(townId, api.type.ComponentType.TOWN)
        if not(townData) then return end

        local oldCargoNeeds = townData.cargoNeeds
        if not(oldCargoNeeds) then return end

        -- local cargoSupplyAndLimit = api.engine.system.townBuildingSystem.getCargoSupplyAndLimit(townId)
        -- local newCargoNeeds = oldCargoNeeds
        -- for cargoTypeId, cargoSupply in pairs(cargoSupplyAndLimit) do
        --     print(cargoTypeId, cargoSupply)
        -- end
        api.cmd.sendCommand(
            -- this triggers updateFn for all the town buildings
            -- res, com, ind. LOLLO TODO find out the res, com and ind needs of a town
            -- and replicate them here.
            api.cmd.make.instantlyUpdateTownCargoNeeds(townId, oldCargoNeeds)
        )
    end,
}

function data()
    return {
        guiInit = function()
            -- create and initialize ui elements
            _utils.initTowns()
        end,
        handleEvent = function(src, id, name, param)
            if (id ~= _eventId or type(param) ~= 'table') then return end

            if name == 'lolloCapacityFactorButtonDown' then
                _actions.alterCapacityFactor(false)
                _utils.updateCapacityFactorValue(param.townId)
            elseif name == 'lolloCapacityFactorButtonUp' then
                _actions.alterCapacityFactor(true)
                _utils.updateCapacityFactorValue(param.townId)
            elseif name == 'lolloConsumptionFactorButtonDown' then
                _actions.alterConsumptionFactor(false)
                _utils.updateConsumptionFactorValue(param.townId)
            elseif name == 'lolloConsumptionFactorButtonUp' then
                _actions.alterConsumptionFactor(true)
                _utils.updateConsumptionFactorValue(param.townId)
            end
        end,
        guiHandleEvent = function(id, name, param)
            -- if you click on a town label, its stats will open.
            -- The game will raise select with a numeric id (eg 21550)
            -- and create a new window with the stats of a town.
            -- temp.view.entity_21550 will be the id of the temp town stats window.
            -- If you open the town stats menu, select won't fire.
            -- In both cases, idAdded will fire instead.
            if type(id) == 'string' then
                xpcall(
                    function()
                        if name == 'idAdded' and id:find('temp.view.entity_') then
                            for townId, townData in pairs(commonData.towns.get()) do
                                if townData.townStatWindowId == id then
                                    _utils.guiAddTownStatButtons(id, townId, commonData.common.get())
                                    break
                                end
                            end
                        elseif name == 'button.click' and id:find('lolloCapacityFactorButtonDown_') then
                            print('LOLLO button down clicked; name, param =')
                            debugPrint(name)
                            debugPrint(param)
                            game.interface.sendScriptEvent(
                                _eventId, -- id
                                'lolloCapacityFactorButtonDown', -- name
                                { -- param
                                    townId = tonumber(id:sub(id:find('_') + 1))
                                }
                            )
                        elseif name == 'button.click' and id:find('lolloCapacityFactorButtonUp_') then
                            print('LOLLO button up clicked; name, param =')
                            debugPrint(name)
                            debugPrint(param)
                            game.interface.sendScriptEvent(
                                _eventId, -- id
                                'lolloCapacityFactorButtonUp', -- name
                                { -- param
                                    townId = tonumber(id:sub(id:find('_') + 1))
                                }
                            )
                        elseif name == 'button.click' and id:find('lolloConsumptionFactorButtonDown_') then
                            print('LOLLO button down clicked; name, param =')
                            debugPrint(name)
                            debugPrint(param)
                            game.interface.sendScriptEvent(
                                _eventId, -- id
                                'lolloConsumptionFactorButtonDown', -- name
                                { -- param
                                    townId = tonumber(id:sub(id:find('_') + 1))
                                }
                            )
                        elseif name == 'button.click' and id:find('lolloConsumptionFactorButtonUp_') then
                            print('LOLLO button up clicked; name, param =')
                            debugPrint(name)
                            debugPrint(param)
                            game.interface.sendScriptEvent(
                                _eventId, -- id
                                'lolloConsumptionFactorButtonUp', -- name
                                { -- param
                                    townId = tonumber(id:sub(id:find('_') + 1))
                                }
                            )
                        end
                    end,
                    _myErrorHandler
            )
            end
        end,
        -- update = function()
        -- end,
        guiUpdate = function()
            _utils.guiUpdateCapacityFactorValue()
            _utils.guiUpdateConsumptionFactorValue()
        end,
        load = function(data)
            if not(data) then return end

            _state.townId4CapacityFactorNeedingUpdate = data.townId4CapacityFactorNeedingUpdate or false
            _state.townId4ConsumptionFactorNeedingUpdate = data.townId4ConsumptionFactorNeedingUpdate or false
        end,
        save = function()
            if not _state then _state = {} end
            return _state
        end,
    }
end

