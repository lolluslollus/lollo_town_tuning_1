local function _myErrorHandler(err)
    print('lollo town tuning caught error: ', err)
end

local _defaultConsumptionFactor = 1.2
local _defaultConsumptionFactorDelta = 0.4
local _eventId = '__lolloTownTuningEvent__'
local _state = {
    towns = {},
}
local _utils = {
    guiAddTownStatButtons = function(windowId, townId, townData)
        print('town stats window opened, id, name, param, api.gui.util.getById ==')
        -- debugPrint(windowId)
        -- debugPrint(name)
        -- debugPrint(param)
        -- debugPrint(api.gui.util.getById(windowId))

        local windowContent = api.gui.util.getById(windowId):getContent()
        local editorTab = windowContent:getTab(3)
        local editorTabLayout = editorTab:getLayout()

        local textViewDown = api.gui.comp.TextView.new("-")
        local buttonDown = api.gui.comp.Button.new(textViewDown, true)
        buttonDown:setId('lolloButtonDown_' .. tostring(townId))
        -- buttonDown:setStyleClassList({ "negative" })

        local textViewConsumptionFactor = api.gui.comp.TextView.new(tostring(townData.consumptionFactor))

        local textViewUp = api.gui.comp.TextView.new("+")
        local buttonUp = api.gui.comp.Button.new(textViewUp, true)
        buttonUp:setId('lolloButtonUp_' .. tostring(townId))
        -- buttonUp:setStyleClassList({ "positive" })

        local table = api.gui.comp.Table.new(1, 'NONE')
        table:setNumCols(3)
        table:addRow({buttonDown, textViewConsumptionFactor, buttonUp})
        editorTabLayout:addItem(table)
    end
}
local _actions = {
    alterConsumptionFactor = function(townId, consumptionFactorDelta)
        print('alterConsumptionFactor starting, townId =', townId, 'consumptionFactorDelta =', consumptionFactorDelta)
        local buildings = api.engine.system.townBuildingSystem.getTown2BuildingMap()[townId]

    end,
}

function data()
    return {
        guiInit = function()
            -- create and initialize ui elements
            local townCapacities = api.engine.system.townBuildingSystem.getTown2personCapacitiesMap()
            if not(townCapacities) or #_state.towns > 0 then return end

            for id, _ in pairs(townCapacities) do
                _state.towns[id] = {
                    consumptionFactor = _defaultConsumptionFactor,
                    townStatWindowId = 'temp.view.entity_' .. tostring(id)
                }
            end

            print('_state.towns =')
            debugPrint(_state.towns)
        end,
        handleEvent = function(src, id, name, param)
            if (id ~= _eventId or type(param) ~= 'table') then return end

            if name == 'lolloButtonDown' then
                _actions.alterConsumptionFactor(param.townId, -_defaultConsumptionFactorDelta)
            elseif name == 'lolloButtonUp' then
                _actions.alterConsumptionFactor(param.townId, _defaultConsumptionFactorDelta)
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
                            for townId, townData in pairs(_state.towns) do
                                if townData.townStatWindowId == id then
                                    _utils.guiAddTownStatButtons(id, townId, townData)
                                    break
                                end
                            end
                        elseif name == 'button.click' and id:find('lolloButtonDown_') then
                            print('LOLLO button down clicked; name, param =')
                            debugPrint(name)
                            debugPrint(param)
                            game.interface.sendScriptEvent(
                                _eventId, -- id
                                'lolloButtonDown', -- name
                                { -- param
                                    townId = tonumber(id:sub(id:find('_') + 1))
                                }
                            )
                        elseif name == 'button.click' and id:find('lolloButtonUp_') then
                            print('LOLLO button up clicked; name, param =')
                            debugPrint(name)
                            debugPrint(param)
                            game.interface.sendScriptEvent(
                                _eventId, -- id
                                'lolloButtonUp', -- name
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
        -- guiUpdate = function()
        -- end,
    }
end

