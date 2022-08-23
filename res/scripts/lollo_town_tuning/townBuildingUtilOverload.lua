local townBuildingUtil = require "townbuildingutil"

townBuildingUtil.make_building2 = function(buildingFace, landUseType, era, level, parcelSize, modelData, groundTexture)
	local scaffolding = {
		buildingFace = { buildingFace },
		height = -1
	}

	local ab = 1920
    -- local ab = 1990
	local bc = 1990

	-- local availability = {
	-- 	yearFrom = era == "A" and 0 or (era == "B" and ab or bc),
	-- 	yearTo = era == "A" and ab or (era == "B" and bc or 0)
	-- }
	local availability = {
        yearFrom = era == "A" and 0 or (era == "B" and ab or bc),
		yearTo = 0
	}
    -- print('LOLLO townBuildingUtil.make_building2 firing, era =') debugPrint(era)

	local townBuildingParams = {
		landUseType = landUseType,
		parcelSize = parcelSize,
		level = level,
	}

	return townBuildingUtil.make_building2_ext(buildingFace, availability, townBuildingParams, modelData, scaffolding, groundTexture)
end

townBuildingUtil.make_building_new = function(constructionModelId, buildingModelId, buildingFace, transf, landUseType,
    era, level, parcelSize, assets, scaffolding)
    	local ab = 1900
        -- local ab = 1975
        local bc = 1975
    -- local availability = {
    --     yearFrom = era == "A" and 0 or (era == "B" and 1900 or 1975),
    --     yearTo = era == "A" and 1900 or (era == "B" and 1975 or 0)
    -- }
    local availability = {
        yearFrom = era == "A" and 0 or (era == "B" and ab or bc),
        yearTo = 0
    }
    -- print('LOLLO townBuildingUtil.make_building_new firing, era =') debugPrint(era)

    local townBuildingParams = {
        landUseType = landUseType,
        level = level,
        parcelSize = parcelSize,
    }
    return townBuildingUtil.make_building_ext(constructionModelId, buildingModelId, buildingFace, transf,
            availability, townBuildingParams, assets, scaffolding)
end
