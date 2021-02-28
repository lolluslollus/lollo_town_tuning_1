function data()
return {
	en = {
		NAME = "Town tuning",
		DESC = [[Control town building requirements and capacities.
		This mod adds a "tuning" tab to the town menus, where you can alter some parameters in new and old games.
		If your game has grown and ground to a halt, you can reduce the industrial and commercial demand across all towns.
		If that does not do it, you can alter the industrial and commercial consumption factor (ie supply effectiveness) across all towns.
		If you want more, you can reduce people requirements in every building.
		You can also do the opposite and increase the parameters, if you have a NASA computer or a very small game.

		As a bonus, you get switches to:
		- avoid new skyscrapers, 
		- build new roads with non-square corners,
		- limit the geometry settings to increase performance.
		
		As an added bonus, you can add more requirements to residential, commercial and industrial areas, town by town.

		NOTE: Be patient when you alter a parameter that affects all towns, it might take a while before the job is done because it affects *all* buildings, existing end future. The game will freeze for a while.
        
        PERFORMANCE TIPS:
        I have a test game with over 50K people and mods to 16-fold the industry output. The game was stuttering badly. This mod and these tricks sped up my machine to par:
        - Cut industry production to reasonable levels, no more 6400 units of coal
        - Cut the industrial and commercial consumption with this mod
        - Raise the supply effectiveness with this mod
        - Mod the steel mill to require 1 coal and 1 ore instead of 2 (not included here)
        - In the game options, set geometry to low
        - In the game options, set texture quality to high or less
        - Use one screen instead of two
    	- Limit the frame rate with the Nvidia control panel.

		KNOWN ISSUES:
		- When you alter something across all towns, the process can take a while. Click once and wait until the game unfreezes. I have no way of reporting back when the operation is complete.
		- Sometimes, the sliders to alter the initial capacity have no effect. Just slide them again a notch.
		- The "Editor" tab that appears in sandbox mode may show the wrong values. This is why I deactivated it.
        ]],
		CAPACITY_FACTOR = "Industrial and commercial capacity factor (ie demand), affects all towns. Only click once and wait until the game unfreezes!",
		CONSUMPTION_FACTOR = "Industrial and commercial consumption factor (ie supply effectiveness), affects all towns. Only click once and wait until the game unfreezes!",
		FASTER_LOW_GEOMETRY = "Faster low geometry setting",
		FASTER_TOWN_DEVELOP_INTERVAL = "Faster town develop interval",
		INITIAL_COM_CAPACITY = "Initial commercial capacity",
		INITIAL_IND_CAPACITY = "Initial industrial capacity",
		INITIAL_RES_CAPACITY = "Initial residential capacity",
		NO_SKYSCRAPERS = "Bar commercial and residential skyscrapers (only applies to new buildings)",
		NO_SQUARE_CROSSINGS = "AI streets cross at various corners",
		PERSON_CAPACITY_FACTOR = "Person capacity factor, affects all buildings in all towns. Only click once and wait until the game unfreezes!",
		TUNING_TAB_LABEL = "Tuning"
	},

}
end
