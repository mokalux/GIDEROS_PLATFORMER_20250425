EDoorSensor = Core.class()

function EDoorSensor:init(xid, xpos, w, h)
	-- ids
	self.isdoorsensor = true
	self.eid = xid -- sensor will assign its id to a player id (doorid, keyid, ...)
	-- params
	self.pos = xpos
	self.sx = 1
	self.sy = self.sx
	self.flip = 1
	self.w, self.h = w*self.sx, h*self.sy
	-- COMPONENTS
	-- COLLISION BOX: CCollisionBox:init(xcollwidth, xcollheight)
	local collw, collh = self.w, self.h -- full size collision box
	self.collbox = CCollisionBox.new(collw, collh)
end
