-- Pane11 displays the player's score out of a possible 1000000 (DDR A scoring)
-- aggregate judgment counts (overall W1, overall W2, overall miss, etc.)
-- and judgment counts on holds, mines, hands, rolls
-- rolls = holds
-- mines = 1/4 o.k.
local player, controller, ComputedData = unpack(...)

local pn = ToEnumShortString(player)
local sequential_offsets = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].sequential_offsets
local offsets = { [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0 }

-- Marvelous, Perfect, Great, Good, Boo (Not used in DDR Ace and above)
local TheTimingWindows = { 0.016667, 0.033333, 0.083333, 0.123333, 0.163333 }
local math_abs = math.abs

for z in ivalues(sequential_offsets) do
	-- 1st value in 'z' is not what we want
	local val = z[2]
	local TheJudgment = 6
	
	if val ~= "Miss" then
		local abs_val = math_abs(val)
		for i = 1, 5 do
			if abs_val <= TheTimingWindows[i] then
				TheJudgment = i
				break
			end
		end
	end
	
	offsets[TheJudgment] = offsets[TheJudgment] + 1
end


return Def.ActorFrame{

	-- score displayed as a percentage
	LoadActor("./Percentage.lua", {player, controller, offsets}),

	-- labels like "MARVELOUS", "MISS", "holds", "rolls", etc.
	LoadActor("./JudgmentLabels.lua", {player, controller}),

	-- numbers (How many Marvelous? How many Misses? etc.)
	LoadActor("./JudgmentNumbers.lua", {player, controller, ComputedData, offsets}),
}