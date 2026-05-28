local player, controller = unpack(...)

local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local PercentDP = stats:GetPercentDancePoints()
local percent = FormatPercentScore(PercentDP)
-- Format the Percentage string, removing the % symbol
percent = percent:gsub("%%", "")

local pn = ToEnumShortString(player)
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local highscore = pss:GetHighScore()
local possibleRadar = pss:GetRadarPossible()

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
		TheJudgment = 5 -- Way-off / Boo are the same as Miss
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

return Def.ActorFrame{
	Name="PercentageContainer"..ToEnumShortString(player),
	OnCommand=function(self)
		self:y( _screen.cy-26 )
	end,

	-- dark background quad behind player percent score
	Def.Quad{
		InitCommand=function(self)
			self:diffuse(color("#101519")):zoomto(158.5, 60)
			self:horizalign(controller==PLAYER_1 and left or right)
			self:x(150 * (controller == PLAYER_1 and -1 or 1))

			if ThemePrefs.Get("VisualStyle") == "Technique" then
				self:diffusealpha(0.5)
			end
		end
	},

	LoadFont("DDR A/_ScreenEvaluation numbers")..{
		Name="Percent",
		Text=TheDDRScore,
		InitCommand=function(self)
			self:horizalign(right):zoom(0.67)
			self:x( (controller == PLAYER_1 and 1.5 or 141))
		end
	}
}
