EHideable = Core.class()

function EHideable:init(xbitmap, xpos)
	-- ids
	self.ishideable = true
	-- params
	self.pos = xpos
	self.sprite = xbitmap
end
