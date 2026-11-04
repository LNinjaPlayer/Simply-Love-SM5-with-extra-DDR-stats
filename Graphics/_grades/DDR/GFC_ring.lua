local function Spin(self)
	r = 2
	z = self:GetZ()
	l = r/(36/3)

	if z >= 36 then
		z = z-36
		self:z(z)
		self:rotationz(z*10)
	end

	z = z + r
	self:linear(l)
	self:rotationz(z*10)
	self:z(z)
	self:queuecommand("Spin")
end

return LoadActor("./assets/GFC_ring.png")..{ 	OnCommand=function(self) self:zoom(0.85):queuecommand("Spin") end,
	SpinCommand=function(self) Spin(self) end }