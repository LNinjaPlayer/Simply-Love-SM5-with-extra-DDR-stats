-- Pane10 displays the player's score out of a possible 1000000 (DDR A scoring)
-- aggregate judgment counts (overall W1, overall W2, overall miss, etc.)
-- and judgment counts on holds, mines, hands, rolls
-- rolls = holds
-- mines = 1/4 o.k.

return Def.ActorFrame{

	-- score displayed as a percentage
	LoadActor("./Percentage.lua", ...),

	-- labels like "MARVELOUS", "MISS", "holds", "rolls", etc.
	LoadActor("./JudgmentLabels.lua", ...),

	-- numbers (How many Marvelous? How many Misses? etc.)
	LoadActor("./JudgmentNumbers.lua", ...),
}