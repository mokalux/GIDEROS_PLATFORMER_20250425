CBody = Core.class()

function CBody:init(xmass, xspeed, xupspeed, xextra)
	-- body physics properties
	self.mass = xmass or 1
	self.currmass = self.mass
	self.vx = 0
	self.vy = 0
	self.speed = xspeed
	self.currspeed = self.speed
	self.upspeed = xupspeed
	self.currupspeed = self.upspeed
	if xextra then
		self.inputbuffer = 1*8 -- 2*8, 30
		self.currinputbuffer = self.inputbuffer
		self.coyotetimer = 11 -- 10, 9, 1.1*8, 2*8
		self.currcoyotetimer = self.coyotetimer
		self.jumpcount = 1 -- 2
		self.currjumpcount = self.jumpcount
		self.dashtimer = 1*8 -- 1*8 -- 0.5*8
		self.currdashtimer = self.dashtimer
		self.dashmultiplier = 1.5 -- 1.5
		self.dashcooldown = 4*8 -- 4*8, cool down before performing another dash
		self.currdashcooldown = self.dashcooldown
	end
end
