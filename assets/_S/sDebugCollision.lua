SDebugCollision = Core.class()

function SDebugCollision:init(xtiny) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
end

function SDebugCollision:filter(ent) -- tiny function
	return ent.collbox
end

function SDebugCollision:onAdd(ent) -- tiny function
	local debugcolor = 0x9b009b
	if ent.isplayer1 then debugcolor = 0xff00ff end
	ent.debugcol = Pixel.new(debugcolor, 0.5, ent.collbox.w, ent.collbox.h)
	ent.spritelayer:addChild(ent.debugcol)
end

function SDebugCollision:onRemove(ent) -- tiny function
	ent.spritelayer:removeChild(ent.debugcol)
end

function SDebugCollision:process(ent, dt) -- tiny function
	local function fun()
		ent.debugcol:setPosition(ent.pos)
		Core.yield(1)
	end
	Core.asyncCall(fun)
end
