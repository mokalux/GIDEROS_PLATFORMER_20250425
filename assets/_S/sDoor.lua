SDoor = Core.class()

function SDoor:init(xtiny, xbworld, xplayer1)
	xtiny.processingSystem(self) -- called once on init and every frames
	self.tiny = xtiny
	self.bworld = xbworld -- cbump world
	self.player1 = xplayer1
end

function SDoor:filter(ent) -- tiny function
	return ent.isdoor
end

function SDoor:onAdd(ent) -- tiny function
--	print("SDoor:onAdd")
end

function SDoor:onRemove(ent) -- tiny function
--	print("SDoor:onRemove")
end

local p1rangetoofarx = myappwidth*0.6 -- disable systems to save some CPU, magik XXX
local p1rangetoofary = myappheight*0.6 -- disable systems to save some CPU, magik XXX
function SDoor:process(ent, dt) -- tiny function
	local function async()
		-- OUTSIDE VISIBLE RANGE
		if (ent.pos.x > self.player1.pos.x + p1rangetoofarx or
			ent.pos.x < self.player1.pos.x - p1rangetoofarx) or
			(ent.pos.y > self.player1.pos.y + p1rangetoofary or
			ent.pos.y < self.player1.pos.y - p1rangetoofary) then
			ent.doanimate = false
			return
		end
		ent.isactive = false
		ent.isup = false ent.isdown = false
		if ent.eid == self.player1.doorsensor then -- player1 inside door sensor
			if ent.eid:find("kdoorZ") or -- no key needed for doors with eid Z
				(self.tiny.player1inventory[ent.eid]) then -- player1 has door key in inventory
				if ent.pos.y > ent.distance.startpos.y - ent.h then -- open up
					ent.isup = true ent.isdown = false
					ent.isactive = true
				end
			end
		else -- player1 outside door sensor
			if ent.pos.y < ent.distance.startpos.y then -- shut down
				ent.isdown = true ent.isup = false
				ent.isactive = true
			end
			-- if player1 acquires door key, illuminate door (cutscenes, ...)
			if (ent.eid:find("kdoorZ") and not ent.highlight) or -- no key needed for doors with eid Z
				(self.tiny.player1inventory[ent.eid] and not ent.highlight) then -- player1 has door key
				ent.sprite:setAlpha(1.6) -- 2
				ent.highlight = true -- only highlight once
			end
		end
		-- action
		if ent.isactive then
			local function collisionfilter(item, other) -- "touch", "cross", "slide", "bounce"
				if other.isnme or other.isplayer1 then return "slide" end -- ok
				return "cross" -- ok
			end
			--  _____ ____  _    _ __  __ _____  
			-- / ____|  _ \| |  | |  \/  |  __ \ 
			--| |    | |_) | |  | | \  / | |__) |
			--| |    |  _ <| |  | | |\/| |  ___/ 
			--| |____| |_) | |__| | |  | | |     
			-- \_____|____/ \____/|_|  |_|_|     
			local goalx = ent.pos.x + ent.body.vx * dt
			local goaly = ent.pos.y + ent.body.vy * dt
			local nextx, nexty = self.bworld:move(ent, goalx, goaly, collisionfilter)
			--  _____  _    ___     _______ _____ _____  _____ 
			-- |  __ \| |  | \ \   / / ____|_   _/ ____|/ ____|
			-- | |__) | |__| |\ \_/ / (___   | || |    | (___  
			-- |  ___/|  __  | \   / \___ \  | || |     \___ \ 
			-- | |    | |  | |  | |  ____) |_| || |____ ____) |
			-- |_|    |_|  |_|  |_| |_____/|_____\_____|_____/ 
			if ent.isup and not ent.isdown then
				ent.body.vy = -ent.body.upspeed
			elseif ent.isdown and not ent.isup then
				ent.body.vy = ent.body.upspeed
			end
			-- move
			ent.pos = vector(nextx, nexty)
			ent.sprite:setPosition(ent.pos+vector(ent.collbox.w/2, -ent.h/2+ent.collbox.h))
		end
		Core.yield(1)
	end
	Core.asyncCall(async)
end
