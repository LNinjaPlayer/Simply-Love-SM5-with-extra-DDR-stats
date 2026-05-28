local player, controller, ComputedData = unpack(...)

local pn = ToEnumShortString(player)
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local highscore = pss:GetHighScore()

local sequential_offsets = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].sequential_offsets

local offsets = {}
local TheJudgment = 0

local TheTimingW1 = 0.016667 -- Marvelous
local TheTimingW2 = 0.033333 -- Perfect
local TheTimingW3 = 0.083333 -- Great
local TheTimingW4 = 0.123333 -- Good
local TheTimingW5 = 0.163333 -- Boo (Not used in DDR Ace and above)

for z in ivalues(sequential_offsets) do
	-- 1st & 2nd value in 'z' is not what we want
	local val = z[2]
	
	if val == "Miss" then
		TheJudgment = 6
	elseif val <= TheTimingW1 and -TheTimingW1 <= val then
		TheJudgment = 1
	elseif val <= TheTimingW2 and -TheTimingW2 <= val then
		TheJudgment = 2
	elseif val <= TheTimingW3 and -TheTimingW3 <= val then
		TheJudgment = 3
	elseif val <= TheTimingW4 and -TheTimingW4 <= val then
		TheJudgment = 4
	elseif val <= TheTimingW5 and -TheTimingW5 <= val then
		TheJudgment = 6 -- Way-off / Boo are the same as Miss
	else
		TheJudgment = 6
	end
	
	if not offsets[TheJudgment] then
		offsets[TheJudgment] = 1
	else
		offsets[TheJudgment] = offsets[TheJudgment] + 1
	end
end

for za = 0,5 do
	if not offsets[za] then
		offsets[za] = 0
	end
end

local Held = highscore:GetHoldNoteScore("HoldNoteScore_Held")
local MinesAvoided = math.floor((pss:GetRadarActual():GetValue("RadarCategory_Mines"))/4)
-- We divide by 4 cuz mines = DDR-shock-arrows and
-- shock arrows always come in quads and counts as a single N.G. or O.K.
-- I use math.floor cuz we are not displaying floats, only ints
-- can't be bothered to do something better, I just want a close enough DDR scoring
-- mines are hit individualy anyway and doesn't trigger like shocks ¯\_(ツ)_/¯

-- I use what is supposed to be the the Boo value as the O.K. value in the code under
local TheOKs = Held + MinesAvoided
if TheOKs and TheOKs ~= 0 then
	offsets[5] = TheOKs
end


local TapNoteScores = {
	Types = { 'W1', 'W2', 'W3', 'W4', 'W5', 'Miss' },
	-- x values for P1 and P2
	x = { P1=64, P2=94 }
}

local RadarCategories = {
	Types = { 'Hands', 'Holds', 'Mines', 'Rolls' },
	-- x values for P1 and P2
	x = { P1=-180, P2=218 }
}


local t = Def.ActorFrame{
	InitCommand=function(self)self:zoom(0.8):xy(90,_screen.cy-24) end,
	OnCommand=function(self)
		-- shift the x position of this ActorFrame to -90 for PLAYER_2
		if controller == PLAYER_2 then
			self:x( self:GetX() * -1 )
		end
	end
}

-- do "regular" TapNotes first
for i=1,#TapNoteScores.Types do
	local window = TapNoteScores.Types[i]
	local number = offsets[i]
	-- pss:GetTapNoteScores( "TapNoteScore_"..window )

	-- actual numbers
	t[#t+1] = Def.RollingNumbers{
		Font="DDR A/_DDR A Eval 26px",
		InitCommand=function(self)
			self:zoom(1):horizalign(right)
			self:diffuse(color("#ffffff"))
			self:Load("RollingNumbersEvaluationA")

		end,
		BeginCommand=function(self)
			self:x( TapNoteScores.x[ToEnumShortString(controller)] )
			self:y((i-1)*35 -20)
			self:targetnumber(number)
		end
	}

end

-- then handle hands/ex, holds, mines, rolls
for index, RCType in ipairs(RadarCategories.Types) do
	local performance = pss:GetRadarActual():GetValue( "RadarCategory_"..RCType )
	local possible = pss:GetRadarPossible():GetValue( "RadarCategory_"..RCType )
	possible = clamp(possible, 0, 9999)

	-- player performance value
	-- use a RollingNumber to animate the count tallying up for visual effect
	t[#t+1] = Def.RollingNumbers{
		Font="DDR A/_ScreenEvaluation numbers",
		InitCommand=function(self) self:zoom(0.4):horizalign(right):Load("RollingNumbersEvaluationB") end,
		BeginCommand=function(self)
			self:x( RadarCategories.x[ToEnumShortString(controller)] )
			self:y((index-1)*25 + 53)
			self:targetnumber(performance)
		end
	}

	-- slash and possible value
	t[#t+1] = LoadFont("DDR A/_ScreenEvaluation numbers")..{
		InitCommand=function(self) self:zoom(0.4):horizalign(right) end,
		BeginCommand=function(self)
			self:x( ((controller == PLAYER_1) and -114) or 286 )
			self:y((index-1)*25 + 53)
			self:settext(("/%03d"):format(possible))
			local leadingZeroAttr = { Length=4-tonumber(tostring(possible):len()), Diffuse=color("#5A6166") }
			self:AddAttribute(0, leadingZeroAttr )
		end
	}
end

return t