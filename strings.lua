function data()
return {
	en = {
		NAME = "Town tuning",
		DESC = [[Control town building requirements and capacities.
		This mod adds a "tuning" tab to the town menus, where you can alter some parameters in new and old games.
		If your game has grown and ground to a halt, you can reduce the industrial and commercial consumption across all towns.
		If that does not do it, you can reduce the industrial and commercial requirements across all towns.
		If you want more, you can reduce people requirements in every building.
		You can also do the opposite and increase the parameters, if you have a NASA computer or a very small game.

		As a bonus, you get switches to:
		- avoid new skyscrapers, 
		- build new roads with non-square corners,
		- limit the geometry settings to increase performance.
		
		As an added bonus, you can add more requirements to residential, commercial and industrial areas, town by town.

		NOTE: Be patient when you alter a parameter that affects all towns, it might take a while before the job is done.]],
		CAPACITY_FACTOR = "Industrial and commercial capacity factor, affects all towns",
		CONSUMPTION_FACTOR = "Industrial and commercial consumption factor, affects all towns",
		FASTER_LOW_GEOMETRY = "Faster low geometry setting",
		FASTER_TOWN_DEVELOP_INTERVAL = "Faster town develop interval",
		NO_SKYSCRAPERS = "Bar commercial and residential skyscrapers (only applies to new buildings)",
		NO_SQUARE_CROSSINGS = "AI streets cross at various corners",
		PERSON_CAPACITY_FACTOR = "Person capacity factor, affects all buildings in all towns",
		TUNING_TAB_LABEL = "Tuning"
	},

}
end
