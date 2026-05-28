local player = ...

local playerStats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local grade = playerStats:GetGrade()

local pn = ToEnumShortString(player)
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local highscore = pss:GetHighScore()
local possibleRadar = pss:GetRadarPossible()

local sequential_offsets = SL[pn].Stages.Stats[SL.Global.Stages.PlayedThisGame + 1].sequential_offsets

local offsets = {}
local TheJudgment = 0

local TheTimingW1 = 0.016667
local TheTimingW2 = 0.033333
local TheTimingW3 = 0.083333
local TheTimingW4 = 0.123333
local TheTimingW5 = 0.163333

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
		TheJudgment = 5
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

local w1 = offsets[1]
local w2 = offsets[2]
local w3 = offsets[3]
local w4 = offsets[4]
local w5 = offsets[5]

-- local w1 = highscore:GetTapNoteScore('TapNoteScore_W1')
-- local w2 = highscore:GetTapNoteScore('TapNoteScore_W2')
-- local w3 = highscore:GetTapNoteScore('TapNoteScore_W3')
-- local w4 = highscore:GetTapNoteScore('TapNoteScore_W4')
-- local w5 = highscore:GetTapNoteScore('TapNoteScore_W5')


local MinesAvoided = (pss:GetRadarActual():GetValue("RadarCategory_Mines"))/4
local MinesTotal = (possibleRadar:GetValue("RadarCategory_Mines"))/4
-- We divide by 4 cuz mines = DDR-shock-arrows and
-- shock arrows always come in quads and counts as a single N.G. or O.K.

local Held = highscore:GetHoldNoteScore("HoldNoteScore_Held") -- counts Holds and Rolls
local Missed = highscore:GetTapNoteScore("TapNoteScore_Miss")
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

local DDRgrade

--AAA PFC
if TheDDRScore == 1000000 then DDRgrade = "Grade_Tier01"
--AAA
elseif TheDDRScore >= 990000 then DDRgrade = "Grade_Tier02"
--AA+
elseif TheDDRScore >= 950000 then DDRgrade = "Grade_Tier03"
--AA
elseif TheDDRScore >= 900000 then DDRgrade = "Grade_Tier04"
--AA-
elseif TheDDRScore >= 890000 then DDRgrade = "Grade_Tier05"
--A+
elseif TheDDRScore >= 850000 then DDRgrade = "Grade_Tier06"
--A
elseif TheDDRScore >= 800000 then DDRgrade = "Grade_Tier07"
--A-
elseif TheDDRScore >= 790000 then DDRgrade = "Grade_Tier08"
--B+
elseif TheDDRScore >= 750000 then DDRgrade = "Grade_Tier09"
--B
elseif TheDDRScore >= 700000 then DDRgrade = "Grade_Tier10"
--B-
elseif TheDDRScore >= 690000 then DDRgrade = "Grade_Tier11"
--C+
elseif TheDDRScore >= 650000 then DDRgrade = "Grade_Tier12"
--C
elseif TheDDRScore >= 600000 then DDRgrade = "Grade_Tier13"
--C-
elseif TheDDRScore >= 590000 then DDRgrade = "Grade_Tier14"
--D+
elseif TheDDRScore >= 550000 then DDRgrade = "Grade_Tier15"
--D
elseif TheDDRScore >= 000001 then DDRgrade = "Grade_Tier16"
--E
else DDRgrade = "Grade_Tier17"
end

t[#t+1] = LoadActor(THEME:GetPathG("", "_grades/DDR/"..DDRgrade..".lua"), playerStats)..{
	InitCommand=function(self)
		self:x(45 * (player==PLAYER_1 and -1 or 1))
		self:y(_screen.cy-134)
	end,
	OnCommand=function(self) self:zoom(0.45) end
}


local FCRing

if Missed == 0 and Held == Holds + Rolls and w5 == 0 then
	if w1 == Steps then FCRing = "MFC_ring"
	elseif w1 + w2 == Steps then FCRing = "PFC_ring"
	elseif w1 + w2 + w3 == Steps then FCRing = "GFC_ring"
	elseif w1 + w2 + w3 + w4 == Steps then FCRing = "FC_ring"
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