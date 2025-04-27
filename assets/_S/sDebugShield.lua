SDebugShield = Core.class()

function SDebugShield:init(xtiny) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
end

function SDebugShield:filter(ent) -- tiny function
	return ent.shield
end

function SDebugShield:onAdd(ent) -- tiny function
	--ent.pos + vector(ent.collbox.w/2, 0) + ent.shield.offset*vector(ent.flip, 1)
	local pw, ph = ent.shield.sprite:getWidth(), ent.shield.sprite:getHeight()
	ent.debugattack1 = Pixel.new(0x5500ff, 0.2, pw, ph)
	ent.debugattack1:setAnchorPoint(0.5, 0.5)
	ent.spritelayer:addChild(ent.debugattack1)
	-- querry rect
	ent.debugattackqr = Pixel.new(0xaaff00, 0.3, pw, ph)
	ent.debugattackqr:setAnchorPoint(0, 0.1)
	ent.spritelayer:addChild(ent.debugattackqr)
end

function SDebugShield:onRemove(ent) -- tiny function
	ent.spritelayer:removeChild(ent.debugattack1)
	ent.spritelayer:removeChild(ent.debugattackqr)
end

function SDebugShield:process(ent, dt) -- tiny function
	local function fun()
		ent.debugattack1:setPosition(
--			ent.pos + vector(ent.collbox.w/2, 0) + ent.shield.offset*vector(ent.flip, 1)
			ent.pos +
			vector(ent.collbox.w/2, 0) +
			ent.shield.offset*vector(ent.shield.sprite.sx*ent.flip, ent.shield.sprite.sy)
		)
		local pw, ph = ent.shield.sprite:getWidth(), ent.shield.sprite:getHeight()
		ent.debugattackqr:setPosition(
--			ent.pos + ent.shield.offset*vector(ent.flip, 1) - vector(pw*0.5, ph*0.5) + vector(ent.collbox.w*0.5, 0)
			ent.pos +
			ent.shield.offset*vector(ent.shield.sprite.sx*ent.flip, ent.shield.sprite.sy) -
			vector(pw*0.5, ph*0.5) + vector(ent.collbox.w*0.5, 0)
		)
		Core.yield(1)
	end
	Core.asyncCall(fun)
end





