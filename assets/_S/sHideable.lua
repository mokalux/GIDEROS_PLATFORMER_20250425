SHideable = Core.class()

function SHideable:init(xtiny, xplayer1)
	xtiny.processingSystem(self) -- called once on init and every frames
	self.player1 = xplayer1
end

function SHideable:filter(ent) -- tiny function
	return ent.ishideable
end

function SHideable:onAdd(ent) -- tiny function
--	print("SHideable:onAdd")
end

function SHideable:onRemove(ent) -- tiny function
--	print("SHideable:onRemove")
end

local p1rangetoofarx = myappwidth*1 -- disable systems to save some CPU, magik XXX
local p1rangetoofary = myappheight*1 -- disable systems to save some CPU, magik XXX
function SHideable:process(ent, dt) -- tiny function
	local function fun()
		ent.sprite:setVisible(true)
		-- OUTSIDE VISIBLE RANGE
		if (ent.pos.x > self.player1.pos.x + p1rangetoofarx or
			ent.pos.x < self.player1.pos.x - p1rangetoofarx) or
			(ent.pos.y > self.player1.pos.y + p1rangetoofary or
			ent.pos.y < self.player1.pos.y - p1rangetoofary) then
			ent.sprite:setVisible(false)
--		else
--			if not ent.sprite:isVisible() then ent.sprite:setVisible(true) end
		end
		Core.yield(1)
	end
	Core.asyncCall(fun)
end
