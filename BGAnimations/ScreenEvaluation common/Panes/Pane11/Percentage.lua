local player, controller, offsets = unpack(...)

local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
local highscore = pss:GetHighScore()
local possibleRadar = pss:GetRadarPossible()

local w1 = offsets[1]
local w2 = offsets[2]
local w3 = offsets[3]
local w4 = offsets[4]
-- local w5 = offsets[5] -- unused here
-- local Missed = offsets[6] -- unused here

local MinesAvoided = (pss:GetRadarActual():GetValue("RadarCategory_Mines"))/4
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

return Def.ActorFrame{
	Name="DDRPercentageContainer"..ToEnumShortString(player),
	OnCommand=function(self)
		self:y( _screen.cy-26 )
	end,

	-- dark background quad behind player percent score
	Def.Quad{
		InitCommand=function(self)
			self:diffuse(color("#101519")):zoomto(158.5, (styletype == "TwoPlayersSharedSides") and 88 or 60)
			self:horizalign(controller==PLAYER_1 and left or right)
			self:x(150 * (controller == PLAYER_1 and -1 or 1))
			if styletype == "TwoPlayersSharedSides" then
				self:y(14)
			end
			if ThemePrefs.Get("VisualStyle") == "Technique" then
				self:diffusealpha(0.5)
			elseif ThemePrefs.Get("VisualStyle") == "Transistor"  then
				self:diffusealpha(0.7)
			end
		end
	},

	LoadFont(ThemePrefs.Get("ThemeFont") .. " Bold")..{
		Name="DDRPercent",
		Text=TheDDRScore,
		InitCommand=function(self)
			self:horizalign(right):zoom(0.82)
			self:x( (controller == PLAYER_1 and 1.5 or 141))
		end
	}
}
