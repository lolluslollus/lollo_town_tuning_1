local logger = require('lollo_town_tuning.logger')
local townBuildingUtil = require 'townbuildingutil'

local _getAvailability = function(ab, bc, isOldBuildingsInNewEras, era)
    -- handle "never" and avoid holes
    local availability = {
        yearFrom = 0,
        yearTo = 0,
    }
    if era == 'A' then
        if ab < 0 and bc < 0 then
            -- do nothing
        elseif ab < 0 then
            if not(isOldBuildingsInNewEras) then
                availability.yearTo = bc
            end
        else
            if not(isOldBuildingsInNewEras) then
                availability.yearTo = ab
            end
        end
    elseif era == 'B' then
        if ab < 0 then
            availability.yearFrom = 65535 -- -1 does not pull here
            availability.yearTo = 65535 -- -1 does not pull here
        else
            availability.yearFrom = ab
            if bc >= 0 and not(isOldBuildingsInNewEras) then
                availability.yearTo = bc
            end
        end
    elseif era == 'C' then
        if bc < 0 then
            availability.yearFrom = 65535 -- -1 does not pull here
            availability.yearTo = 65535 -- -1 does not pull here
        else
            availability.yearFrom = bc
        end
    end

    return availability
end

return function(ab, bc, isOldBuildingsInNewEras)
    townBuildingUtil.make_building2 = function(buildingFace, landUseType, era, level, parcelSize, modelData, groundTexture)
        local scaffolding = {
            buildingFace = { buildingFace },
            height = -1
        }

        local availability = _getAvailability(ab, bc, isOldBuildingsInNewEras, era)
        logger.print('LOLLO townBuildingUtil.make_building2 firing, era =') logger.debugPrint(era)
        logger.print('availability =') logger.debugPrint(availability)

        local townBuildingParams = {
            landUseType = landUseType,
            parcelSize = parcelSize,
            level = level,
        }

        return townBuildingUtil.make_building2_ext(buildingFace, availability, townBuildingParams, modelData, scaffolding, groundTexture)
    end

    townBuildingUtil.make_building_new = function(constructionModelId, buildingModelId, buildingFace, transf, landUseType,
        era, level, parcelSize, assets, scaffolding)
        local availability = _getAvailability(ab, bc, isOldBuildingsInNewEras, era)
        logger.print('LOLLO townBuildingUtil.make_building_new firing, era =') logger.debugPrint(era)
        logger.print('availability =') logger.debugPrint(availability)

        local townBuildingParams = {
            landUseType = landUseType,
            level = level,
            parcelSize = parcelSize,
        }
        return townBuildingUtil.make_building_ext(constructionModelId, buildingModelId, buildingFace, transf,
                availability, townBuildingParams, assets, scaffolding)
    end
end
