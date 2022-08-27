function data()
	return {
		en = {
			["ModName"] = "Town tuning",
			["ModDesc"] = [[Control town building requirements and capacities.
			This mod adds a "tuning" tab to the town menus, where you can alter some parameters in new and old games.
			If your game has grown and ground to a halt, you can reduce the industrial and commercial demand across all towns.
			If that does not do it, you can alter the industrial and commercial consumption factor (ie supply effectiveness) across all towns.
			If you want more, you can reduce people requirements in every building.
			You can also do the opposite and increase the parameters, if you have a NASA computer or a very small game.
			This affects all buildings, present and future.

			You can add more requirements to residential, commercial and industrial areas, town by town.
			This affects all buildings, present and future.

			As a bonus, you get switches to control the AI:
			- avoid new skyscrapers (new buildings only),
			- set the eras for town building styles (new buildings only),
			- build roads with non-square corners (new roads only),
			- develop towns more frequently,
			- limit the geometry settings to increase performance,
			- alter the chance that sims seek new destinations.

			NOTES: 
			- Whenever you alter a parameter that affects all towns, this mod will change the properties of future buildings and recalculate *all* buildings in your map. This will take a while: click one button only and don't touch anything until the game unfreezes.
			- The "Editor" tab that appears in sandbox mode may show the wrong values. This is why I deactivated it.
			
			PERFORMANCE TIPS:
			I have a test game with over 50K people and mods to 16-fold the industry output. The game was stuttering badly. This mod and these tricks sped up my machine to par:
			- Cut industry production to reasonable levels, no more 6400 units of coal
			- Cut the industrial and commercial demand with this mod
			- Raise the supply effectiveness with this mod
			- Mod the steel mill to require 1 coal and 1 ore instead of 2 (not included here)
			- In the game options, set geometry to low
			- In the game options, set texture quality to high or less
			- Use one screen instead of two
			- Limit the frame rate with the Nvidia control panel.

			KNOWN ISSUES:
			- If a town seems not to accept some goods, but it should, make any dummy change to its residential, commercial or industrial requirements and revert it, then wait a bit.
			]],
			["CAPACITY_FACTOR"] = "Industrial and commercial capacity factor (ie demand), affects all towns. Only click once and wait until the game unfreezes!",
			["CARGO_NEEDS"] = "Cargo needs. Your game may briefly freeze before all buildings update.",
			["CONSUMPTION_FACTOR"] = "Industrial and commercial consumption factor (ie supply effectiveness), affects all towns. Only click once and wait until the game unfreezes!",
			["DESTINATION_RECOMPUTATION_PROBABILITY"] = "Sims likely to seek new destinations",
			["ERA_B_START_YEAR"] = "Era B start year (new buildings only)",
			["ERA_C_START_YEAR"] = "Era C start year (new buildings only)",
			["FASTER_LOW_GEOMETRY"] = "Faster low geometry setting",
			["FASTER_TOWN_DEVELOP_INTERVAL"] = "Faster town develop interval",
			["INITIAL_COM_CAPACITY"] = "Initial commercial capacity",
			["INITIAL_IND_CAPACITY"] = "Initial industrial capacity",
			["INITIAL_RES_CAPACITY"] = "Initial residential capacity",
			["NO_SKYSCRAPERS"] = "Bar commercial and residential skyscrapers (new buildings only)",
			["NO_SQUARE_CROSSINGS"] = "AI streets cross at various corners",
			["OLD_BUILDINGS_IN_NEW_ERAS"] = "AI can make older buildings in newer eras (new buildings only)",
			["PERSON_CAPACITY_FACTOR"] = "Person capacity factor, affects all buildings in all towns. Only click once and wait until the game unfreezes!",
			["TUNING_TAB_LABEL"] = "Tuning",

			["NEVER"] = "Never",
			["RENDER_CLOSE_OBJECTS"] = "Yes + render very close objects"
		},

	}
end
