local constructionutil = require "constructionutil"
local mathutil = require "mathutil"
local polygonutil = require "polygonutil"
local assetutil = require "assetutil"
local transf = require "transf"

local parcelSize = 8
local borderSize = 2

local townbuildingutil = { }

local scaffold = "scaffold"

local addScaffolds = function(data, result)
	local everyThird = function(face)
		local newFace = {}
		for i=1, #face, 3 do
			table.insert(newFace, face[i])
		end
		return newFace
	end

	if data.curves and data.curves[scaffold] then

		local minX = .0
		local minY = .0
		local maxX = .0
		local maxY = .0
		
		local crvs = data.curves[scaffold]
		
		result.scaffold = { buildingFace = {}, height = -1 }
		for i=1, #crvs do
			local face = crvs[i]
			table.insert(result.scaffold.buildingFace, everyThird(face))
		end
	end
end

function townbuildingutil.make_building2_ext(buildingFace, availability, townBuildingParams, modelData, scaffolding, groundTexture)
	return {
		type = "TOWN_BUILDING",
		description = { 
		
		},
		availability = availability,
		soundConfig = {
			soundSet = { name = "town_building" }
		},
		townBuildingParams = townBuildingParams,

		updateFn = function(params)
			if params.parcelFace == nil then error("No parcelFace") end
	
			math.randomseed(params.seed)
			local groupConfigNum = math.random(1000000)
		
			local result = { }
			
			--result.scaffold = scaffolding
			result.models = {}
			result.groundFaces = {}
			
			local allLayouts = {}
			for k,v in pairs(modelData) do
				if k == "base" then
					constructionutil.addModelsAndGroups(params, v, result, "base")
					addScaffolds(v, result)
				else
					allLayouts[#allLayouts + 1] = v
				end
			end
			
			if not result.scaffold then result.scaffold = scaffolding end
			
			if #allLayouts > 0 then
				local selectedLayout = allLayouts[math.random(#allLayouts)]
				constructionutil.addModelsAndGroups(params, selectedLayout, result)
			end

			local dx = 1
			local p1 = params.parcelFace[1]
			local p2 = params.parcelFace[#params.parcelFace / 2]
			dx = p2[1] - p1[1]
			
			for i=1, #result.models do
				local model = result.models[i]
				
				local alignmentPos = { model.transf[13], model.transf[14] }
				if model.transf.align then
					alignmentPos = model.transf.align
				end
				model.transf = transf.mul(transf.transl({ x = 0, y = 0, z = math.lerp(p1[3], p2[3], (alignmentPos[1] - p1[1]) / dx) }), model.transf)
			end
			

			
			if params.parcelFace == nil then
				return result
			end
			
			local transformedBuildingFace = polygonutil.transform({ 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1 }, buildingFace)
			
			local maxX = townBuildingParams.parcelSize[1]  * 0.5 * parcelSize + borderSize
			local minX = -maxX
			local minY = -borderSize
			local maxY = townBuildingParams.parcelSize[2] * parcelSize + borderSize
			
			local groundTextureFace = {
				{ minX, minY, 0 },
				{ maxX, minY, 0 },
				{ maxX, maxY, 0 },
				{ minX, maxY, 0 },
			}
		
			if false then
				if groundTexture then
					--print("using new ground texture: " .. groundTexture)
					result.groundFaces[#result.groundFaces + 1] = { 
						face = groundTextureFace, 
						modes = { 
							{ 
								type = "FILL", 
								key = groundTexture .. ".lua",
							},
						} ,
						loop = true,
						alignmentOffsetMode = "OBJECT",
						alignmentDirMode = "OBJECT",
						alignmentOffset = { -groundTextureFace[1][1], -groundTextureFace[1][2] },
					}
				else
					result.groundFaces[#result.groundFaces + 1] = { face = groundTextureFace, modes = { { type = "FILL", key = "town_concrete.lua" } } }
				end
			end
			
			if (params.buildingPreview) then
				constructionutil.makeFence(params.parcelFace, "asset/fence_wood.mdl", 3.3734, true, result.models)
				constructionutil.makeFence(groundTextureFace, "asset/hydrant_new.mdl", 3.3734, true, result.models)
			end
		
			result.terrainAlignmentLists = { {
				type = "EQUAL",
				faces =  { }
			} }
			
			result.personCapacity = {
				type = townBuildingParams.landUseType,
				capacity = params.capacity
			}
			
			local ruleCapacity = math.ceil(params.capacity / 4)
			if (ruleCapacity > 0 and params.cargoTypes and #params.cargoTypes > 0) then
				if params.cargoTypes then
					result.stocks = {  }
					
					local inputs = {}
				
					for i=1, #params.cargoTypes do
						local t = {}
						for j=1, #params.cargoTypes do
							t[j] = 0
						end
						t[i] = 1
						inputs[#inputs + 1] = t
						
						result.stocks[i] = {
							cargoType = params.cargoTypes[i],
							type = "RECEIVING",
							edges = { },
							moreCapacity = ruleCapacity * 100
						}
					end
					
					result.rule = {
						input = inputs,
						output = { },
						capacity = ruleCapacity,
						consumptionFactor = 1.2,
					}
				end
			end			
						
			result.cost = 1000
			result.bulldozeCost = 100

			return result
		end
	}
end

function townbuildingutil.make_building2(buildingFace, landUseType, era, level, parcelSize, modelData, groundTexture)
	local scaffolding = {
		buildingFace = { buildingFace },
		height = -1
	}
	
	local ab = 1920
	local bc = 1990
	
	local availability = {
		-- original
		-- yearFrom = era == "A" and 0 or (era == "B" and ab or bc),
		-- yearTo = era == "A" and ab or (era == "B" and bc or 0)
		yearFrom = era == "A" and 0 or (era == "B" and ab or bc),
		yearTo = 0,
	}
	
	local townBuildingParams = {
		landUseType = landUseType,
		parcelSize = parcelSize,
		level = level,
	}

	return townbuildingutil.make_building2_ext(buildingFace, availability, townBuildingParams, modelData, scaffolding, groundTexture)
end

function townbuildingutil.make_building_ext(constructionModelId, buildingModelId, buildingFace, transf,
		availability, townBuildingParams, assets, scaffolding)
	return {
		type = "TOWN_BUILDING",
		description = { 
		
		},
		availability = availability,
		soundConfig = {
			soundSet = { name = "town_building" }
		},
		townBuildingParams = townBuildingParams,
		
		updateFn = function(params)
			local result = { }
			
			result.scaffold = scaffolding

			result.models = {
				{
					id = buildingModelId,
					transf = transf
				}
			}
			if params.parcelFace == nil then
				return result
			end

			local p1 = params.parcelFace[1]
			local p2 = params.parcelFace[#params.parcelFace / 2]
		
			local dx = p2[1] - p1[1]
		
			if assets then
				for i = 1, #assets do
					local a = assets[i]

					local ids = a.ids
					if a.grp then
						if assetutil.assets[a.grp] then
							ids = assetutil.assets[a.grp]
						else
							error("grp '" .. a.grp .. "' not found...") 
						end
					end
					
					if a.grp == "random_small_tree" and #params.state.tree.small > 0 then
						ids = params.state.tree.small
					elseif a.grp == "random_medium_tree" and #params.state.tree.medium > 0 then
						ids = params.state.tree.medium
					elseif a.grp == "random_large_tree" and #params.state.tree.large > 0 then
						ids = params.state.tree.large
					end
					
					local align = a.align
					
					if align == nil then
						align = math.abs(a.transf[15]) < .01 and true or false
					end
					
					local transf = table.copy(a.transf)
					if align then
						transf[15] = transf[15] + math.lerp(p1[3], p2[3], (transf[13] - p1[1]) / dx)
					end	
					
					local id = ids[math.random(#ids)]
					if type(id) == "table" then
						if (a.matConfig) then 
							math.randomseed(a.matConfig + params.seed) 
						else
							math.randomseed(params.seed) 
						end
						local newId = id[math.random(#id)]
						result.models[#result.models + 1] = { id = newId, transf = transf }
					elseif id ~= "" then
						result.models[#result.models + 1] = { id = id, transf = transf }
					end
				end
			end

			if (townBuildingParams.landUseType == "RESIDENTIAL") then
				constructionutil.makeFence(params.parcelFace, "asset/fence_wood.mdl", 3.3734, true, result.models)
			end
			
			local transformedBuildingFace = polygonutil.transform(transf, buildingFace)
			
			result.groundFaces = { }
			
			if #transformedBuildingFace >= 3 then
				result.groundFaces[#result.groundFaces + 1] = { face = transformedBuildingFace, modes = { { type = "FILL", key = "building_paving_fill.lua" }, { type = "STROKE_OUTER", key = "building_paving.lua" } } }
			end
				
			if townBuildingParams.landUseType == "INDUSTRIAL" or townBuildingParams.landUseType == "COMMERCIAL" then
				result.groundFaces[#result.groundFaces + 1] = { face = params.parcelFace, modes = { { type = "FILL", key = "town_concrete.lua" }, { type = "STROKE_OUTER", key = "town_concrete_border.lua" } } }
			else
				if params.capacity >= 16 then
					result.groundFaces[#result.groundFaces + 1] = { face = params.parcelFace, modes = { { type = "FILL", key = "town_concrete.lua" }, { type = "STROKE_OUTER", key = "town_concrete_border.lua" } } }
				end
			end
		
			result.terrainAlignmentLists = { {
				type = "EQUAL",
				faces =  { }
			} }
			
			result.personCapacity = {
				type = townBuildingParams.landUseType,
				capacity = params.capacity
			}
			
			if (townBuildingParams.landUseType == "INDUSTRIAL" or townBuildingParams.landUseType == "COMMERCIAL") then
				local ruleCapacity = math.floor(params.capacity / 4 + 0.5)
				if (ruleCapacity > 0) then
					result.stocks = {  }
					
					local inputs = {}
					for i=1, #params.cargoTypes do
						local t = {}
						for j=1, #params.cargoTypes do
							t[j] = 0
						end
						t[i] = 1
						inputs[#inputs + 1] = t
						
						result.stocks[i] = {
							cargoType = params.cargoTypes[i],
							type = "RECEIVING",
							edges = { },
							moreCapacity = ruleCapacity * 100
						}
					end

					result.rule = {
						input = inputs,
						output = { },
						capacity = ruleCapacity,
						consumptionFactor = 1.2,
					}
				end			
			end
						
			result.cost = 1000
			result.bulldozeCost = 100

			return result
		end
	}
end

function townbuildingutil.make_building_new(constructionModelId, buildingModelId, buildingFace, transf, landUseType,
		era, level, parcelSize, assets, scaffolding)
	local availability = {
		-- original
		-- yearFrom = era == "A" and 0 or (era == "B" and 1900 or 1975),
		-- yearTo = era == "A" and 1900 or (era == "B" and 1975 or 0)
		yearFrom = era == "A" and 0 or (era == "B" and 1900 or 1975),
		yearTo = 0
	}
	
	local townBuildingParams = {
		landUseType = landUseType,
		level = level,
		parcelSize = parcelSize,
	}
	return townbuildingutil.make_building_ext(constructionModelId, buildingModelId, buildingFace, transf,
			availability, townBuildingParams, assets, scaffolding)
end

function townbuildingutil.make_building(constructionModelId, buildingModelId, buildingFace, transf, landUseType,
		era, size, parcelSize, assets)
	local scaffolding = {
		buildingFace = { buildingFace },
		height = -1
	}

	return townbuildingutil.make_building_new(constructionModelId, buildingModelId, buildingFace, transf, landUseType,
		era, size, parcelSize, assets, scaffolding)
end

function townbuildingutil.get_assets(category)
	return townbuildingutil.assets[category]
end

function townbuildingutil.make_material_lod_1_metallic(map_albedo_fn, map_metal_gloss_ao_fn)
	return {
		params = {
			two_sided = {
				flipNormal = false,
				twoSided = false,
				
			},
			fade_out_range = {
				fadeOutEndDist = 20000,
				fadeOutStartDist = 10000,
			},
			map_albedo = {
				compressionAllowed = true,
				fileName = map_albedo_fn,
				magFilter = "LINEAR",
				minFilter = "LINEAR_MIPMAP_LINEAR",
				mipmapAlphaScale = 0,
				type = "TWOD",
				wrapS = "CLAMP_TO_EDGE",
				wrapT = "CLAMP_TO_EDGE",
			},
			map_metal_gloss_ao = {
				compressionAllowed = true,
				fileName = map_metal_gloss_ao_fn,
				magFilter = "LINEAR",
				minFilter = "LINEAR_MIPMAP_LINEAR",
				mipmapAlphaScale = 0,
				type = "TWOD",
				wrapS = "CLAMP_TO_EDGE",
				wrapT = "CLAMP_TO_EDGE",
			},
			polygon_offset = {
				factor = 0,
				units = 0,			
			},
			map_op_1 = {
				fileName = "buildings/dirtmap.tga",
				magFilter = "LINEAR",
				minFilter = "LINEAR_MIPMAP_LINEAR",
			},
			map_op_2 = {
				fileName = "buildings/overlay.tga",
				magFilter = "LINEAR",
				minFilter = "LINEAR_MIPMAP_LINEAR",
			},
			operation_1 = {
				op = "LINEAR_BURN",
				mode = "NORMAL",
				scale = { 1.0 / 40.0, 1.0 / 40.0 },
				opacity = .5
			}, 
			operation_2 = {
				op = "OVERLAY",
				mode = "NORMAL",
				scale = { 1.0 / 217.0, 1.0 / 217.0 },
				opacity = 1.0
			}		
		},
		type = "PHYSICAL_OP",	
	}
end

return townbuildingutil
