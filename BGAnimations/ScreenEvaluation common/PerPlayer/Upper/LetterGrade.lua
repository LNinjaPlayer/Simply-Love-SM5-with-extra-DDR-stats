local player = ...

local styletype = ToEnumShortString(GAMESTATE:GetCurrentStyle():GetStyleType())

local playerStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local routineStatus = SL.Global.RoutineStatus
if (styletype == "TwoPlayersSharedSides") then
	playerStats = STATSMAN:GetCurStageStats():GetRoutineStageStats()
end
local grade = playerStats:GetGrade()

local pn = ToEnumShortString(player)

local highscore = playerStats:GetHighScore()
local possibleRadar = playerStats:GetRadarPossible()

-- TODO: need to make it work with routineStatus
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

local w1 = offsets[1]
local w2 = offsets[2]
local w3 = offsets[3]
local w4 = offsets[4]
local w5 = offsets[5]
local Missed = offsets[6]

local MinesAvoided = (playerStats:GetRadarActual():GetValue("RadarCategory_Mines"))/4
local MinesTotal = (possibleRadar:GetValue("RadarCategory_Mines"))/4
-- We divide by 4 cuz mines = DDR-shock-arrows and
-- shock arrows always come in quads and counts as a single N.G. or O.K.

local Held = highscore:GetHoldNoteScore("HoldNoteScore_Held") -- counts Holds and Rolls
local Holds = possibleRadar:GetValue("RadarCategory_Holds")
local Rolls = possibleRadar:GetValue("RadarCategory_Rolls")
local Steps = possibleRadar:GetValue("RadarCategory_TapsAndHolds")
-- Steps is number of notes, Held release is not counted in this
-- Only the hold/roll press the counted

local MaxStepScore = (Steps + Holds + Rolls + MinesTotal) * 5
local StepScore = (w1 + w2 + Held + MinesAvoided) * 5 + w3 * 3 + w4
local shits = w2 + w3 + w4
local TheDDRScore = ((math.floor(StepScore / MaxStepScore * 100000)) -shits) * 10

-- "I passd with a q though."
local title = GAMESTATE:GetCurrentSong():GetDisplayFullTitle()
if title == "D" then grade = "Grade_Tier99" end

-- QUINT
local ex = CalculateExScore(player)
if ex == 100 then grade = "Grade_Tier00" end

local t = Def.ActorFrame{}

t[#t+1] = LoadActor(THEME:GetPathG("", "_grades/"..grade..".lua"), playerStats)..{
	InitCommand=function(self)
		self:x(115 * (player==PLAYER_1 and -1 or 1))
		self:y(_screen.cy-134)
	end,
	OnCommand=function(self) self:zoom(0.4) end
}

local DDR_GradeThresholds = { -- looks pretty
    {score = 1000000, tier = "Grade_Tier01"}, --AAA PFC
    {score = 990000,  tier = "Grade_Tier02"}, --AAA
    {score = 950000,  tier = "Grade_Tier03"}, --AA+
    {score = 900000,  tier = "Grade_Tier04"}, --AA
    {score = 890000,  tier = "Grade_Tier05"}, --AA-
    {score = 850000,  tier = "Grade_Tier06"}, --A+
    {score = 800000,  tier = "Grade_Tier07"}, --A
    {score = 790000,  tier = "Grade_Tier08"}, --A-
    {score = 750000,  tier = "Grade_Tier09"}, --B+
    {score = 700000,  tier = "Grade_Tier10"}, --B
    {score = 690000,  tier = "Grade_Tier11"}, --B-
    {score = 650000,  tier = "Grade_Tier12"}, --C+
    {score = 600000,  tier = "Grade_Tier13"}, --C
    {score = 590000,  tier = "Grade_Tier14"}, --C-
    {score = 550000,  tier = "Grade_Tier15"}, --D+
    {score = 1,       tier = "Grade_Tier16"}, --D
}

local DDRgrade = "Grade_Tier17" --E (Default fallback)

for i = 1, #DDR_GradeThresholds do
    local data = DDR_GradeThresholds[i]
    if TheDDRScore >= data.score then
        DDRgrade = data.tier
        break
    end
end

t[#t+1] = LoadActor(THEME:GetPathG("", "_grades/DDR/"..DDRgrade..".lua"), playerStats)..{
	InitCommand=function(self)
		self:x(45 * (player==PLAYER_1 and -1 or 1))
		self:y(_screen.cy-134)
	end,
	OnCommand=function(self) self:zoom(0.45) end
}


local FCRing

if Missed == 0 and w5 == 0 and Held == Holds + Rolls then
    if w2 == 0 and w3 == 0 and w4 == 0 then FCRing = "MFC_ring"
    elseif w3 == 0 and w4 == 0 then FCRing = "PFC_ring"
    elseif w4 == 0 then FCRing = "GFC_ring"
    else FCRing = "FC_ring"
    end
	t[#t+1] = LoadActor(THEME:GetPathG("", "_grades/DDR/"..FCRing..".lua"), playerStats)..{
		InitCommand=function(self)
			self:x(30 * (player==PLAYER_1 and -1 or 1))
			self:y(_screen.cy-110)
		end,
		OnCommand=function(self) self:zoom(0.25) end
	}
end

return t
