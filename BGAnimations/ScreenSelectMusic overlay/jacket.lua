local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()

local t = Def.ActorFrame{
	OnCommand=function(self)
		self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
		self:horizalign(center)
	end
}

t[#t+1] = Def.ActorFrame{
	Name="Jacket";
	Def.Sprite{
		InitCommand=function(self) self:x(-356.66):y(-144) end,
		CurrentSongChangedMessageCommand=function(self) self:playcommand("Set") end,
		CurrentCourseChangedMessageCommand=function(self) self:playcommand("Set") end,
		SetCommand=function(self)
			local song = GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
			if not song then return end
			if song:HasJacket() then
				self:visible(true)
				local JacketPath = (song and song:GetJacketPath())
				JacketPath = JacketPath:sub(2) -- get rid of the starting ' / ' cuz self:Load not workie \(>.<)/
				self:Load(JacketPath)
			else 
				self:visible(false)
			end
			self:setsize(125.33,125.33)
		end
	};
}

return t