SCollision = Core.class()

function SCollision:init(xtiny, xbworld, xplayer1) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
	self.tiny = xtiny
	self.bworld = xbworld
	self.player1 = xplayer1
end

function SCollision:filter(ent) -- tiny function
	return ent.collbox and ent.body and
		not (ent.isprojectile or ent.ismvpf or ent.isdoor)
end

function SCollision:onAdd(ent) -- tiny function
end

function SCollision:onRemove(ent) -- tiny function
end

local p1rangetoofarx = myappwidth*1 -- 0.6, disable systems to save some CPU, magik XXX
local p1rangetoofary = myappheight*1 -- 0.6, disable systems to save some CPU, magik XXX
function SCollision:process(ent, dt) -- tiny function
	-- OUTSIDE VISIBLE RANGE
	if ent.isnme then
		if (ent.pos.x > self.player1.pos.x + p1rangetoofarx or
			ent.pos.x < self.player1.pos.x - p1rangetoofarx) or
			(ent.pos.y > self.player1.pos.y + p1rangetoofary or
			ent.pos.y < self.player1.pos.y - p1rangetoofary) then
			ent.doanimate = false
			return
		end
	end
--	if ent.isplayer1 and ent.currlives <= 0 then return end
	-- some functions
	local function lerp(a,b,t) return a + (b-a) * t end
	-- physics flags
	ent.isstepcontacts = false
	ent.isfloorcontacts = false
	ent.isladdercontacts = false
	ent.isptpfcontacts = false
	ent.ismvpfcontacts = false
	ent.isspringcontacts = false
	--  _____ ____  _      _      _____  _____ _____ ____  _   _ 
	-- / ____/ __ \| |    | |    |_   _|/ ____|_   _/ __ \| \ | |
	--| |   | |  | | |    | |      | | | (___   | || |  | |  \| |
	--| |   | |  | | |    | |      | |  \___ \  | || |  | | . ` |
	--| |___| |__| | |____| |____ _| |_ ____) |_| || |__| | |\  |
	-- \_____\____/|______|______|_____|_____/|_____\____/|_| \_|
	-- ______ _____ _   _______ ______ _____  
	--|  ____|_   _| | |__   __|  ____|  __ \ 
	--| |__    | | | |    | |  | |__  | |__) |
	--|  __|   | | | |    | |  |  __| |  _  / 
	--| |     _| |_| |____| |  | |____| | \ \ 
	--|_|    |_____|______|_|  |______|_|  \_\
	local function collisionfilter(item, other) -- "touch", "cross", "slide", "bounce"
		if other.isnpc then return "cross"
		elseif other.isdoor then return "slide" -- ok
		elseif other.iswall then return "touch" -- "touch" feels better than "slide"
		elseif other.isfloor then return "slide"
		elseif other.isptpf then
			if item.isdown and item.isup then -- prevents ptpf while holding both up and down keys
				item.wasdown = true
				item.wasup = true
			end
			if item.isdown and not item.wasdown then
				return "cross"
			end
			if item.body.vy > 0 then -- actor going down
				local itembottom = item.pos.y + item.collbox.h
				local otherbottom = other.pos.y -- don't add margin here!
				if itembottom <= otherbottom then return "slide" end
			end
			if item.iswalkingnme and item.breed == "C" then
				return "slide"
			end
--		elseif other.isptmvpf then
		elseif other.ismvpf then
			if item.isdown and item.isup then -- prevents pt mvpf while holding both up and down keys
				item.wasdown = true
				item.wasup = true
			end
			if item.isdown and not item.wasdown then
				if other.isptmvpf then return "cross" end -- passthrough
			end
			if item.body.vy > 0 then -- actor going down
				local itembottom = item.pos.y + item.collbox.h
				local otherbottom = other.pos.y + 2 -- 4, 2, margin prevents player from falling when the pf is going up, magik XXX
				if itembottom <= otherbottom then return "slide" end
			end
		elseif other.isspring then return "slide"
		elseif other.isspike then return "slide"
		else return "cross"
		end
	end
	--  _____ ____  _    _ __  __ _____  
	-- / ____|  _ \| |  | |  \/  |  __ \ 
	--| |    | |_) | |  | | \  / | |__) |
	--| |    |  _ <| |  | | |\/| |  ___/ 
	--| |____| |_) | |__| | |  | | |     
	-- \_____|____/ \____/|_|  |_|_|     
	local goalx = ent.pos.x + ent.body.vx * dt
	local goaly = ent.pos.y + ent.body.vy * dt
	local nextx, nexty, collisions, len = self.bworld:move(ent, goalx, goaly, collisionfilter)
	--  _____ ____  _      _      _____  _____ _____ ____  _   _  _____ 
	-- / ____/ __ \| |    | |    |_   _|/ ____|_   _/ __ \| \ | |/ ____|
	--| |   | |  | | |    | |      | | | (___   | || |  | |  \| | (___  
	--| |   | |  | | |    | |      | |  \___ \  | || |  | | . ` |\___ \ 
	--| |___| |__| | |____| |____ _| |_ ____) |_| || |__| | |\  |____) |
	-- \_____\____/|______|______|_____|_____/|_____\____/|_| \_|_____/ 
	-- COLLISION FROM ANY SIDES
	for i = 1, len do
		local item = collisions[i].item
		local other = collisions[i].other
		local normal = collisions[i].normal
		--
		if other.isvoid then
			item.restart = true
		end
		if item.isplayer1 and other.isnpc then
			g_currlevel += 1
			item.restart = true
		elseif item.isplayer1 and other.isexit then
			g_currlevel += 1
			item.restart = true
		end
		if other.iswall then
			item.body.currcoyotetimer = item.body.coyotetimer
		end
		if other.isladder then
			item.body.currcoyotetimer = item.body.coyotetimer
			item.isladdercontacts = true
		end
		if other.isptpf then
			item.isptpfcontacts = true
		end
		if other.isstep then -- CBump stairs effect ;-)
			item.isstepcontacts = true
		end
		if other.ismvpf then
--			print("other.ismvpf", dt)
			if item.body.vy > 0 then -- actor going down
--				print("other.ismvpf, item.body.vy > 0", dt)
				local itembottom = item.pos.y + item.collbox.h
				local otherbottom = other.pos.y + 2 -- 2, 3, some margin prevents player from sliding/falling when the pf is going l/r, magik XXX
				if itembottom < otherbottom then
					item.ismvpfcontacts = true
					item.body.currcoyotetimer = item.body.coyotetimer
--					item.body.vy = 0 -- don't reset velocity y here because prevents ptpf!
				end
			end
			if item.isleft and not item.isright and other.body.vx < 0 then
				item.body.vx = -item.body.currspeed*0.9
			elseif item.isright and not item.isleft and other.body.vx < 0 then
				item.body.vx = item.body.currspeed*0.9
			elseif (item.isleft and item.isright) and other.body.vx < 0 then
				item.body.vx = other.body.vx
			elseif not(item.isleft and item.isright) and other.body.vx < 0 then
				item.body.vx = other.body.vx
			elseif item.isleft and not item.isright and other.body.vx > 0 then
				item.body.vx = -item.body.currspeed*0.9
			elseif item.isright and not item.isleft and other.body.vx > 0 then
				item.body.vx = item.body.currspeed*0.9
			elseif (item.isleft and item.isright) and other.body.vx > 0 then
				item.body.vx = other.body.vx
			elseif not (item.isleft and item.isright) and other.body.vx > 0 then
				item.body.vx = other.body.vx
			elseif item.isleft and not item.isright and other.body.vx == 0 then
				item.body.vx = -item.body.currspeed*0.9
			elseif item.isright and not item.isleft and other.body.vx == 0 then
				item.body.vx = item.body.currspeed*0.9
			elseif (item.isleft and item.isright) and other.body.vx == 0 then
				item.body.vx = 0
			elseif not (item.isleft and item.isright) and other.body.vx == 0 then
				item.body.vx = 0
			end
		end
		-- COLLISION FROM TOP
		if normal.y == -1 then
			if other.isfloor then
				item.body.vy = 0 -- reset velocity y (don't accumulate gravity)
				item.isfloorcontacts = true
				item.body.currjumpcount = item.body.jumpcount
				item.body.currcoyotetimer = item.body.coyotetimer
				if item.isdead then
					item.readytoremove = true
				end
			elseif other.isptpf then
				item.body.vy = 0 -- reset velocity y (don't accumulate gravity)
				item.isptpfcontacts = true
				item.body.currjumpcount = item.body.jumpcount
				item.body.currcoyotetimer = item.body.coyotetimer
			elseif other.isspring then
				item.isspringcontacts = true
			elseif other.isspike and item.isplayer1 then
				item.body.vx = -item.flip*item.body.currspeed*3 -- magik XXX
				item.body.vy = -item.body.currupspeed*0.5 -- magik XXX
				item.isdirty = true
				item.damage = 1
				item.wasup = false
			elseif other.isnme and item.isplayer1 then -- player1 on top of nme
				other.isdirty = true
				other.damage = 1
--				item.wasup = false
--				item.body.currinputbuffer = item.body.inputbuffer
				item.body.currjumpcount = item.body.jumpcount
--				item.body.currcoyotetimer = item.body.coyotetimer
				if item.isup then
--					print("x", dt)
					item.body.vy = -ent.body.currupspeed
				else
					item.body.vy = -item.body.currupspeed*0.7 -- 0.5, 0.8, magik XXX, linked to 'stomp'
				end
			elseif other.isplayer1 and item.isnme then -- nme on top of player1
--				item.body.vy = -item.body.currupspeed*0.7
				other.isdirty = true
				other.damage = 1
				item.wasup = false
--				item.body.currinputbuffer = item.body.inputbuffer
				item.body.currjumpcount = item.body.jumpcount
--				item.body.currcoyotetimer = item.body.coyotetimer
			end
		-- COLLISION FROM BOTTOM
		elseif normal.y == 1 then
			if other.isfloor then -- cancel body gravity when hitting from below (can adjust)
				item.body.vy *= 0.5 -- = 0
			end
		end
		-- COLLISION FROM SIDES, -1 collision from item right, 1 collision from item left
		if normal.x == -1 or normal.x == 1 then
			if item.isplayer1 and other.isfloor then
				item.body.vx = -item.flip
			elseif item.isnme and other.isdoor then
				item.hashitinvisbleblock = false
				item.isleft, item.isright = not item.isleft, not item.isright
			elseif item.isnme and other.isinvisbleblock then
				item.hashitinvisbleblock = true
				item.isleft, item.isright = not item.isleft, not item.isright
			elseif item.isnme and other.isfloor then
				item.hashitinvisbleblock = false
				if normal.x == -1 and not item.isleftofplayer then
					item.isleft, item.isright = true, false
				elseif normal.x == 1 and item.isleftofplayer then
					item.isleft, item.isright = false, true
				end
				local rnd = math.random(100)
				if rnd > 99 then -- random jump too!
					item.wasup = false
					item.body.currinputbuffer = item.body.inputbuffer
					item.isup, item.isdown = true, false
					item.body.currupspeed = item.body.upspeed
				end
			elseif other.iswall then
				if item.isnme then item.hashitinvisbleblock = false end
				item.body.vx = -item.flip
				item.body.vy = 0
				item.wasonwall = true
			end
		end
		-- PLAYER1
		if item.isplayer1 and other.iscollectible then
			other.isdirty = true
			if other.eid:find("kdoor") then
				self.tiny.player1inventory[other.eid] = true
--				print(other.eid, dt)
			end
		end
	end
	--  _____ _____       __      _______ _________     __
	-- / ____|  __ \     /\ \    / /_   _|__   __\ \   / /
	--| |  __| |__) |   /  \ \  / /  | |    | |   \ \_/ / 
	--| | |_ |  _  /   / /\ \ \/ /   | |    | |    \   /  
	--| |__| | | \ \  / ____ \  /   _| |_   | |     | |   
	-- \_____|_|  \_\/_/    \_\/   |_____|  |_|     |_|   
	-- gravity after collisions because ptpfs may modify actor body vy
	if ent.body.vy < 0 then -- going up
		ent.body.vy += 3*8 * ent.body.currmass -- gravity, magik XXX
	else -- going down
		ent.body.vy += 5*8 * ent.body.currmass -- 5*8, gravity, magik XXX
		if ent.body.vy > 600 then -- 500, cap falling speed
			ent.body.vy = 600
		end
		if ent.wasonmvpf then -- prevent fast fall when going off pf
			ent.body.vy = ent.body.currupspeed*0.5 -- *0.4, *0.25, magik XXX
			ent.wasonmvpf = false
		end
	end
	--  _____  _    ___     _______ _____ _____  _____ 
	-- |  __ \| |  | \ \   / / ____|_   _/ ____|/ ____|
	-- | |__) | |__| |\ \_/ / (___   | || |    | (___  
	-- |  ___/|  __  | \   / \___ \  | || |     \___ \ 
	-- | |    | |  | |  | |  ____) |_| || |____ ____) |
	-- |_|    |_|  |_|  |_| |_____/|_____\_____|_____/ 
	if ent.isdead then
		ent.isup, ent.isdown = false, true
		ent.body.currupspeed = -ent.body.upspeed*1
--		print("deaded")
	end
	if ent.body.currinputbuffer > 0 then -- floor input buffer
		ent.body.currinputbuffer -= 1
	end
	if ent.body.currcoyotetimer > 0 then -- coyote time
		ent.body.currcoyotetimer -= 1
	end
	if ent.body.currdashtimer > 0 then -- dash
		ent.body.currdashtimer -= 1
	end
	if ent.body.currdashcooldown > 0 then -- dash cooldown
		ent.body.currdashcooldown -= 1
	end
	if ent.washurt and ent.washurt > 0 then -- hurt fx, work only on player1? XXX
		ent.washurt -= 1
		if ent.washurt <= 0 then ent.sprite:setColorTransform(1, 1, 1, 1) end
	end
	-- IS ON STEP
	if ent.isstepcontacts then
--		if ent.isplayer1 then print("isonstep", dt) end
		if ent.isleft and not ent.isright then -- LEFT
			ent.animation.curranim = g_ANIM_RUN_R
			ent.flip = -1
			ent.body.vx = -ent.body.currspeed
			ent.body.vy = -ent.body.currupspeed*0.4 -- 0.5, 0.25, 0.3, step climb speed here XXX
		elseif ent.isright and not ent.isleft then -- RIGHT
			ent.animation.curranim = g_ANIM_RUN_R
			ent.flip = 1
			ent.body.vx = ent.body.currspeed
			ent.body.vy = -ent.body.currupspeed*0.4 -- 0.5, 0.25, 0.3, step climb speed here XXX
		else
			if ent.flip == -1 then ent.animation.curranim = g_ANIM_IDLE_R
			else ent.animation.curranim = g_ANIM_IDLE_R
			end
			ent.body.vx *= 0.75 -- 0.75, 0.8, 0.9, = 0
			if -ent.body.vx<>ent.body.vx < 0.001 then ent.body.vx = 0 end
		end
	-- IS ON FLOOR
--	elseif ent.isfloorcontacts and
--			not ent.isladdercontacts and
--			not ent.isptpfcontacts and
--			not ent.ismvpfcontacts
--			then
	elseif ent.isfloorcontacts or
			(ent.isfloorcontacts and ent.isladdercontacts) and
			not ent.isptpfcontacts and
			not ent.ismvpfcontacts
			then
--		if ent.isplayer1 then print("isonfloor", dt) end
		if ent.isleft and not ent.isright then -- LEFT
			ent.animation.curranim = g_ANIM_RUN_R
			ent.flip = -1
			if ent.body.currdashtimer > 0 then 
				ent.body.vx -= ent.body.currspeed*ent.body.dashmultiplier
--				ent.body.vy = -ent.body.currupspeed*0.1 -- 0.25, = 0
			else
				ent.body.vx = -ent.body.currspeed
			end
		elseif ent.isright and not ent.isleft then -- RIGHT
			ent.animation.curranim = g_ANIM_RUN_R
			ent.flip = 1
			if ent.body.currdashtimer > 0 then 
				ent.body.vx += ent.body.currspeed*ent.body.dashmultiplier
--				ent.body.vy = -ent.body.currupspeed*0.1 -- 0.25, = 0
			else
				ent.body.vx = ent.body.currspeed
			end
		else
			ent.animation.curranim = g_ANIM_IDLE_R
			ent.body.vx *= 0.75 -- 0.75, 0.8, 0.9, = 0
			if (-ent.body.vx<>ent.body.vx) < 0.001 then ent.body.vx = 0 end
		end
		if ent.body.currinputbuffer > 0 and not ent.isdown and not ent.wasup then -- UP
--			ent.animation.frame = 0 -- one shot animation
			ent.body.vy = -ent.body.currupspeed
			ent.wasup = true
--			ent.body.currjumpcount = ent.body.jumpcount
			ent.body.currinputbuffer = 0 -- prevents double jump when releasing up key
		elseif ent.isdown and not ent.isup then -- DOWN
		end
	-- IS ON LADDER
	elseif not ent.isfloorcontacts and
			ent.isladdercontacts and
			not ent.isptpfcontacts and
			not ent.ismvpfcontacts
			then
		if not ent.isflyingnme then
--			print("isonladder", dt)
			if ent.isleft and not ent.isright then -- LEFT
				ent.animation.curranim = g_ANIM_RUN_R
				ent.flip = -1
				ent.body.vx = -ent.body.currspeed*0.5
			elseif ent.isright and not ent.isleft then -- RIGHT
				ent.animation.curranim = g_ANIM_RUN_R
				ent.flip = 1
				ent.body.vx = ent.body.currspeed*0.5
			else
				ent.animation.curranim = g_ANIM_IDLE_R
--				if ent.flip == 1 then
--					ent.animation.curranim = g_ANIM_LADDER_IDLE_R
--				end
				ent.body.vx *= 0.75 -- 0.75, 0.8, 0.9, = 0
				if -ent.body.vx<>ent.body.vx < 0.001 then ent.body.vx = 0 end
			end
			if ent.isup and not ent.isdown then -- UP
--				print("isonladder u", dt)
				ent.animation.curranim = g_ANIM_RUN_R
--				if ent.flip == 1 then
--					ent.animation.curranim = g_ANIM_RUN_R
--				end
				ent.body.vy = -ent.body.currupspeed*0.2 -- magik XXX
				ent.wasup = false -- allows jumping up off ladder
			elseif ent.isdown and not ent.isup then -- DOWN
--				print("isonladder d", dt)
				ent.animation.curranim = g_ANIM_RUN_R
--				if ent.flip == 1 then
--					ent.animation.curranim = g_ANIM_RUN_R
--				end
				ent.body.vy = ent.body.currupspeed*0.2 -- magik XXX
			else
				ent.body.vy = 0
			end
		end
	-- IS ON PTPF
	elseif not ent.isfloorcontacts and
			not ent.isladdercontacts and
			ent.isptpfcontacts and
			not ent.ismvpfcontacts
			then
--		print("isonptpf", dt)
		if ent.isleft and not ent.isright then -- LEFT
			ent.animation.curranim = g_ANIM_RUN_R
			ent.flip = -1
			if ent.body.currdashtimer > 0 then 
--				ent.body.vx = -ent.body.currspeed*3
				ent.body.vx -= ent.body.currspeed*ent.body.dashmultiplier
--				ent.body.vy = -ent.body.currupspeed*0.1 -- 0.25, = 0
			else
				ent.body.vx = -ent.body.currspeed
			end
		elseif ent.isright and not ent.isleft then -- RIGHT
			ent.animation.curranim = g_ANIM_RUN_R
			ent.flip = 1
			if ent.body.currdashtimer > 0 then 
--				ent.body.vx = ent.body.currspeed*3
				ent.body.vx += ent.body.currspeed*ent.body.dashmultiplier
--				ent.body.vy = -ent.body.currupspeed*0.1 -- 0.25, = 0
			else
				ent.body.vx = ent.body.currspeed
			end
		else
			if ent.flip == -1 then ent.animation.curranim = g_ANIM_IDLE_R
			else ent.animation.curranim = g_ANIM_IDLE_R
			end
			ent.body.vx *= 0.75 -- 0.75, 0.8, 0.9, = 0
			if -ent.body.vx<>ent.body.vx < 0.001 then ent.body.vx = 0 end
		end
		if ent.body.currinputbuffer > 0 and not ent.isdown and not ent.wasup then -- UP
			ent.animation.frame = 0 -- one shot animation
			ent.body.vy = -ent.body.currupspeed
			ent.wasup = true
			ent.body.currinputbuffer = 0
		elseif ent.isdown and not ent.isup and not ent.wasdown then -- DOWN
			ent.body.vy = ent.body.currupspeed*0.1
			ent.wasdown = true
		end
	-- IS ON MVPF
	elseif not ent.isfloorcontacts and
			not ent.isladdercontacts and
			not ent.isptpfcontacts and
			ent.ismvpfcontacts
			then
--		print("isonmvpf", dt)
		if ent.isleft and not ent.isright then -- LEFT
			ent.animation.curranim = g_ANIM_RUN_R
			ent.flip = -1
			if ent.body.currdashtimer > 0 then 
				ent.body.vx -= ent.body.currspeed*ent.body.dashmultiplier
--				ent.body.vy = -ent.body.currupspeed*0.1 -- 0.25, = 0
--			else
--				ent.body.vx = -ent.body.currspeed
			end
		elseif ent.isright and not ent.isleft then -- RIGHT
			ent.animation.curranim = g_ANIM_RUN_R
			ent.flip = 1
			if ent.body.currdashtimer > 0 then 
				ent.body.vx += ent.body.currspeed*ent.body.dashmultiplier
--				ent.body.vy = -ent.body.currupspeed*0.1 -- 0.25, = 0
--			else
--				ent.body.vx = ent.body.currspeed
			end
		else
			if ent.flip == -1 then ent.animation.curranim = g_ANIM_IDLE_R
			else ent.animation.curranim = g_ANIM_IDLE_R
			end
		end
		if ent.body.currinputbuffer > 0 and not ent.isdown and not ent.wasup then -- UP
--			ent.animation.frame = 0 -- one shot animation
			ent.body.vy = -ent.body.currupspeed
--			ent.wasup = true -- if set to true cannot jump!
			ent.body.currinputbuffer = 0
		elseif ent.isdown and not ent.isup and not ent.wasdown then -- DOWN
			ent.body.vy = ent.body.currupspeed*0.1 -- 0.1, vy has a little impact on pt behavior
			ent.wasdown = true
		end
		ent.wasonmvpf = true
	-- IS ON SPRING
	elseif ent.isspringcontacts then -- controllable heights :-)
--		print("isonspring", dt)
		if ent.isup and not ent.isdown then
--			ent.animation.frame = 0 -- one shot animation
			ent.body.vy *= -1.3 -- increase vy
		elseif ent.isdown and not ent.isup then
--			ent.animation.frame = 0 -- one shot animation
			ent.body.vy *= -0.7 -- decrease vy
		else
--			ent.animation.frame = 0 -- one shot animation
			ent.body.vy = -ent.body.vy -- normal vy
--			ent.body.vy = -ent.body.currupspeed -- normal vy
		end
		-- cap
--		print(ent.body.vy, dt) -- -50 -- cap
--		if ent.body.vy > -12 then ent.body.vy = -12
--		elseif ent.body.vy < -40 then ent.body.vy = -40
--		end
	-- IS IN THE AIR
	else
--		if ent.isplayer1 then print("isintheair", dt) end
		-- anims
		if ent.body.vy < 0 then -- going UP
			if ent.flip == -1 then ent.animation.curranim = g_ANIM_JUMPUP_R
			else ent.animation.curranim = g_ANIM_JUMPUP_R
			end
		else -- going DOWN
			if ent.flip == -1 then ent.animation.curranim = g_ANIM_JUMPDOWN_R
			else ent.animation.curranim = g_ANIM_JUMPDOWN_R
			end
		end
		-- movements
		if ent.isleft and not ent.isright then -- LEFT
			ent.flip = -1
			if ent.body.currdashtimer > 0 then 
				ent.body.vx -= ent.body.currspeed*ent.body.dashmultiplier
--				ent.body.vy = -ent.body.currupspeed*0.1 -- 0.25, = 0
			else
				ent.body.vx = -ent.body.currspeed
			end
			if ent.wasonwall then -- vx acceleration
				ent.body.vx = -ent.body.currspeed*4 -- magik XXX
				ent.wasonwall = false
			end
		elseif ent.isright and not ent.isleft then -- RIGHT
			ent.flip = 1
			if ent.body.currdashtimer > 0 then 
				ent.body.vx += ent.body.currspeed*ent.body.dashmultiplier
--				ent.body.vy = -ent.body.currupspeed*0.1 -- 0.25, = 0
			else
				ent.body.vx = ent.body.currspeed
			end
			if ent.wasonwall then -- vx acceleration
				ent.body.vx = ent.body.currspeed*4 -- magik XXX
				ent.wasonwall = false
			end
		else
			ent.body.vx *= 0.75 -- 0.75, 0.8, 0.9, = 0
			if -ent.body.vx<>ent.body.vx < 0.001 then ent.body.vx = 0 end
		end
		-- double jump (and more?)
		if ent.isup and ent.body.currjumpcount > 1 then -- UP
			ent.isup = false
			ent.wasup = false
--			ent.body.vy = 0
			ent.body.currjumpcount -= 1
			ent.body.vy = -ent.body.currupspeed
--			ent.body.currinputbuffer = 0 -- prevents double jump when releasing up key
		-- input buffer
		elseif ent.body.currinputbuffer > 0 and not ent.isdown and not ent.wasup then -- UP
			if ent.body.currcoyotetimer > 0 then
--				print("isintheair body.currcoyotetimer isup", ent.body.currcoyotetimer, dt)
				ent.body.currcoyotetimer = 0
				ent.body.vy = -ent.body.currupspeed
			end
		elseif ent.isdown and not ent.isup and not ent.wasdown then -- DOWN
			ent.wasdown = true
		end
	end
--	print(ent.body.currcoyotetimer, dt)
--	if ent.isplayer1 then print("g2", ent.body.vy, dt) end
	-- move & flip
	ent.pos = vector(nextx, nexty)
	ent.sprite:setPosition(ent.pos + vector(ent.collbox.w/2, -ent.h/2+ent.collbox.h))
--	if ent.animation then
		ent.animation.bmp:setScale(ent.sx*ent.flip, ent.sy)
--	end
end
