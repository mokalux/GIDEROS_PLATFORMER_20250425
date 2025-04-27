SAI = Core.class()

local random = math.random

function SAI:init(xtiny, xplayer1) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
	self.player1 = xplayer1
end

function SAI:filter(ent) -- tiny function
	return ent.ai
end

function SAI:onAdd(ent) -- tiny function
	-- abilities
	ent.abilities = {}
	if ent.body.mass > 0 then ent.abilities[#ent.abilities+1] = 1 end -- jump/climb up
	if g_currlevel == 2 then
		if ent.eid == 1000 then -- nme boss1
			ent.abilities[#ent.abilities+1] = 10 -- action1, shoot
			ent.abilities[#ent.abilities+1] = 20 -- action2, shield
			ent.abilities[#ent.abilities+1] = 30 -- action3, dash
		end
	else
		if ent.eid == 100 then -- basic nme
			ent.abilities[#ent.abilities+1] = 10 -- action1, shoot
		elseif ent.eid == 200 then -- basic nme
			-- no other abilities
		else
			ent.abilities[#ent.abilities+1] = 10 -- action1, shoot
--			ent.abilities[#ent.abilities+1] = 20 -- action2, shield
			ent.abilities[#ent.abilities+1] = 30 -- action3, dash
		end
	end
--	for k, v in pairs(ent.abilities) do print(k, v) end
end

function SAI:onRemove(ent) -- tiny function
end

local p1outofrangex = myappwidth*0.5 -- 0.3, 0.5, magik XXX
local p1outofrangey = myappheight*0.5 -- 0.3, 0.5, magik XXX
local p1actionrange = myappwidth*0.2 -- 3*8, 1*8, myappwidth*0.1, magik XXX
function SAI:process(ent, dt) -- tiny function
	if ent.isdead then
--		ent.isup, ent.isdown = false, true
--		ent.body.currupspeed = -ent.body.upspeed*1
--		print("deaded")
		return
	end
	local function fun()
		-- some flags
		ent.doanimate = true -- to save some cpu
		-- OUTSIDE ACTION RANGE
		if (ent.pos.x > self.player1.pos.x+p1outofrangex or
			ent.pos.x < self.player1.pos.x-p1outofrangex) or
			(ent.pos.y > self.player1.pos.y+p1outofrangey or
			ent.pos.y < self.player1.pos.y-p1outofrangey) then
			-- idle
			ent.isleft, ent.isright = false, false
			ent.isup, ent.isdown = false, false
			ent.body.currspeed = ent.body.speed
			ent.body.currupspeed = ent.body.upspeed
--			ent.hashitinvisbleblock = false
			ent.readyforaction = false
		else -- INSIDE ACTION RANGE
			-- x
			local rnd = random(100)
			if rnd > 1 then -- 80, magik XXX
				if ent.pos.x > random(self.player1.pos.x+p1actionrange, self.player1.pos.x+p1outofrangex) then
					if not ent.hashitinvisbleblock then
						ent.isleft, ent.isright = true, false
						ent.body.currspeed = ent.body.speed*random(8, 12)*0.1 -- magik XXX
					end
				elseif ent.pos.x < random(self.player1.pos.x-p1outofrangex, self.player1.pos.x-p1actionrange) then
					if not ent.hashitinvisbleblock then
						ent.isleft, ent.isright = false, true
						ent.body.currspeed = ent.body.speed*random(8, 12)*0.1 -- magik XXX
					end
				else
--					ent.hashitinvisbleblock = false
				end
			else -- stop moving
				ent.isleft, ent.isright = false, false
				ent.body.currspeed = ent.body.speed
			end
			-- no going left or right on stairs/ladders
			if ent.isladdercontacts and not (ent.isfloorcontacts or ent.isptpfcontacts) then
				ent.isright, ent.isleft = false, false
			end
			-- no turning when bumping on a wall unless
			ent.isleftofplayer = false
			if ent.pos.x < self.player1.pos.x then
				ent.isleftofplayer = true
			end
			-- y
			-- impulse on top of stairs/ladders and actor is going up
			if ent.isladdercontacts and ent.isptpfcontacts and ent.body.vy < 0 then
				ent.wasup = false
				ent.body.currinputbuffer = ent.body.inputbuffer
				ent.isup, ent.isdown = true, false
				ent.body.currupspeed = ent.body.upspeed*random(8, 12)*0.1 -- magik XXX
			end
			ent.readyforaction = true
		end
		-- ACTION
		if ent.readyforaction then
			ent.curractiontimer -= 1
			-- don't let the entity get stuck in place when in range
			if ent.body.vx == 0 then
				if ent.pos.x > self.player1.pos.x then ent.isleft, ent.isright = true, false
				else ent.isleft, ent.isright = false, true
				end
				ent.isleftofplayer = false
				ent.body.currspeed = ent.body.speed*random(8, 12)*0.1 -- magik XXX
			end
			if ent.curractiontimer < 0 then
				-- actor above player1, go down
				if ent.pos.y < self.player1.pos.y and not (ent.eid == 100 or ent.eid == 300) then
					if ent.isptpfcontacts then
						local rnd = random(100)
						if rnd > 30 then -- 80, magik XXX
							ent.wasdown = false
							ent.isup, ent.isdown = false, true
							ent.body.currupspeed = ent.body.upspeed*random(8, 12)*0.1 -- magik XXX
						end
					else -- ladders/stairs
						ent.wasdown = false
						ent.isup, ent.isdown = false, true
						ent.body.currupspeed = ent.body.upspeed*random(8, 12)*0.1 -- magik XXX
					end
				end
				-- actor below player1, jump
				if ent.pos.y > self.player1.pos.y + 10 and ent.eid ~= 21 then
					local rnd = random(100)
					if rnd > 40 then -- 80, magik XXX
						ent.wasup = false
						ent.body.currinputbuffer = ent.body.inputbuffer
						ent.isup, ent.isdown = true, false
						if ent.eid ~= 10 then
							ent.body.currupspeed = ent.body.upspeed*random(8, 12)*0.1 -- magik XXX
						end
					end
				end
				-- pick a random available action
				local rndaction = ent.abilities[random(#ent.abilities)]
				-- movements
				if rndaction == 1 then -- jump
					local rnd = random(100)
					if rnd > 80 then -- jump
						ent.wasup = false
						ent.body.currinputbuffer = ent.body.inputbuffer
						ent.isup, ent.isdown = true, false
--						if not ent.eid == 10 then
						if ent.eid ~= 10 then
							ent.body.currupspeed = ent.body.upspeed*random(8, 12)*0.1 -- magik XXX
						end
					end
				end
				-- actions
				if rndaction == 10 then -- shoot
					ent.isaction1 = true
				elseif rndaction == 20 then -- shield
					ent.isaction2 = true
				elseif rndaction == 30 then -- dash
					ent.body.currspeed = ent.body.speed*0.5 -- magik XXX
					ent.isaction3 = true
				end
				ent.curractiontimer = ent.actiontimer
			end
			-- extra attack on jumping peak
			if ent.body.vy > 0 and ent.body.vy < 30 and not ent.eid == 10 then -- magik XXX
				local rnd = random(100)
				if rnd > 40 then
--					ent.isaction1 = true -- shoot
					ent.isaction2 = true -- shield
				else -- dash/shield
					local rnd2 = random(100)
					if rnd2 > 50 then -- shield
						ent.isaction3 = true -- dash
					else
						if not ent.hashitinvisbleblock then
							ent.body.currspeed = ent.body.speed*0.5 -- magik XXX
							ent.isaction2 = true -- shield
--							ent.isaction3 = true -- dash
						end
					end
				end
			end
		end
		Core.yield(1)
	end
	Core.asyncCall(fun) -- profiler seems to be faster without asyncCall (because of pairs traversing?)
end
