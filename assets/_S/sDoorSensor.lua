SDoorSensor = Core.class()

function SDoorSensor:init(xtiny, xbworld)
	xtiny.processingSystem(self) -- called once on init and every frames
	self.bworld = xbworld -- cbump world
end

function SDoorSensor:filter(ent) -- tiny function
	return ent.isdoorsensor
end

function SDoorSensor:onAdd(ent) -- tiny function
--	print("SDoorSensor:onAdd")
end

function SDoorSensor:onRemove(ent) -- tiny function
--	print("SDoorSensor:onRemove")
end

function SDoorSensor:process(ent, dt) -- tiny function
	local function async()
		local function collisionfilter2(item) -- only one param: "item", return true, false or nil
			if item.isplayer1 then return true end
		end
		--local items, len = world:queryRect(l,t,w,h, filter)
		local items, len2 = self.bworld:queryRect(
			ent.pos.x, ent.pos.y, ent.w, ent.h, collisionfilter2
		)
		for i = 1, len2 do
			items[i].doorsensor = ent.eid -- add an extra var to player1
--			print(items[i].doorsensor, dt)
		end
		Core.yield(1)
	end
	Core.asyncCall(async)
end
