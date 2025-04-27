SNmes = Core.class()

local random, atan2, cos, sin = math.random, math.atan2, math.cos, math.sin

function SNmes:init(xtiny, xbump, xplayer1) -- tiny function
	xtiny.processingSystem(self) -- called once on init and every update
	self.tiny = xtiny -- class ref so we can remove entities from tiny world
	self.bworld = xbump
	self.player1 = xplayer1
	-- sfx
	self.snd = Sound.new("audio/sfx/sfx_deathscream_human14.wav")
	self.channel = self.snd:play(0, false, true)
end

function SNmes:filter(ent) -- tiny function
	return ent.isnme
end

function SNmes:onAdd(ent) -- tiny function
--	print("SNmes:onAdd")
	ent.flip = random(100)
	if ent.flip > 50 then ent.flip = 1 else ent.flip = -1 end
	ent.currlives = ent.totallives
	ent.currhealth = ent.totalhealth
	ent.washurt = 0
	ent.wasbadlyhurt = 0
	ent.isdead = false
	ent.curractiontimer = ent.actiontimer
end

function SNmes:onRemove(ent) -- tiny function
--	print("SNmes:onRemove")
	local function fun()
		if ent.collectible then
			--ECollectibles:init(xid, xspritelayer, xpos, xspeed, xdx, xdy)
			local el = ECollectibles.new(
				ent.collectible, ent.spritelayer,
				ent.pos+vector(ent.collbox.w/4, 0*ent.collbox.h),
				0.8*8, 6*8, 8*8
			)
			self.tiny.tworld:addEntity(el)
			self.bworld:add(el, el.pos.x, el.pos.y, el.collbox.w, el.collbox.h)
		end
		Core.yield(1)
	end
	Core.asyncCall(fun)
	self.bworld:remove(ent) -- remove collision box from cbump world here!
end

local p1rangetoofarx = myappwidth*0.7 -- disable systems to save some CPU, magik XXX
local p1rangetoofary = myappheight*0.7 -- disable systems to save some CPU, magik XXX
local resetanim = true
function SNmes:process(ent, dt) -- tiny function
	-- OUTSIDE VISIBLE RANGE
	if (ent.pos.x > self.player1.pos.x + p1rangetoofarx or
		ent.pos.x < self.player1.pos.x - p1rangetoofarx) or
		(ent.pos.y > self.player1.pos.y + p1rangetoofary or
		ent.pos.y < self.player1.pos.y - p1rangetoofary) then
		ent.sprite:setVisible(false)
		ent.doanimate = false
		return
	else
		if not ent.sprite:isVisible() then
			ent.sprite:setVisible(true)
		end
		ent.doanimate = true
	end
	-- shoot
	if ent.isaction1 then
		ent.isaction1 = false
		local projectilespeed = 28*8
		local xangle = atan2(self.player1.pos.y-ent.pos.y, self.player1.pos.x-ent.pos.x)
		--ent.poffset = vector(ent.collbox.w*0.5+4*8*ent.flip, -1.8*8)
		local offset = vector(ent.collbox.w*0.5+4.7*8*ent.flip, -0.2*8)
		if ent.eid == 1000 then
			projectilespeed = 29*8
			offset = vector(ent.collbox.w*0.5+6*8*ent.flip, 2*8)
		end
		if ent.eid == 100 or ent.eid == 400 then -- shoot straight
			if ent.flip == 1 then xangle = ^<0 -- shoot right
			else xangle = ^<180 -- shoot left
			end
			projectilespeed = 26*8
		elseif ent.eid == 500 then -- turrets
			if ent.dir == "u" then xangle = ^<270
			elseif ent.dir == "d" then xangle = ^<90
			elseif ent.dir == "l" then xangle = ^<180
			else xangle = ^<0 -- right
			end
		end
		local vx, vy = projectilespeed*cos(xangle), projectilespeed*sin(xangle)
		--EProjectiles:init(xid, xmass, xangle, xspritelayer, xpos, xvx, xvy, dx, dy, xpersist)
		local p = EProjectiles.new(
--			1000, 0.1, xangle, ent.spritelayer, ent.pos + offset, vx, vy, 32*8, 32*8
			100, 0.1, xangle, ent.spritelayer, ent.pos+offset, vx, vy, 32*8, 32*8
		)
		p.body.vx = vx
		p.body.vy = vy
		self.tiny.tworld:addEntity(p)
		self.bworld:add(p, p.pos.x, p.pos.y, p.collbox.w, p.collbox.h)
	end
	-- shield
	if ent.isaction2 then
		ent.isaction2 = false
		if ent.shield then
			ent.shield.currtimer = ent.shield.timer
			ent.shield.sprite:setVisible(true)
		end
	end
	-- dash
	if ent.isaction3 then
		ent.isaction3 = false
		ent.body.currdashtimer = ent.body.dashtimer
		ent.body.currdashcooldown = ent.body.dashcooldown
	end
	--
	if ent.shield and not ent.isdead then
		local function collisionfilter2(item) -- only one param: "item", return true, false or nil
--			if item.isplayer1 then return true end
			if item.isplayer1 or (item.isprojectile and item.eid == 1) then
				return true
			end
		end
		ent.shield.sprite:setScale(ent.shield.sprite.sx*ent.flip, ent.shield.sprite.sy)
		ent.shield.sprite:setPosition(
			ent.pos +
			vector(ent.collbox.w/2, 0) +
			ent.shield.offset*vector(ent.shield.sprite.sx*ent.flip, ent.shield.sprite.sy)
		)
		local pw, ph = ent.shield.sprite:getWidth(), ent.shield.sprite:getHeight()
		--local items, len = world:queryRect(l,t,w,h, filter)
		local items, len2 = self.bworld:queryRect(
			ent.pos.x+ent.shield.offset.x*ent.flip-pw*0.5+ent.collbox.w*0.5,
			ent.pos.y+ent.shield.offset.y-ph*0.5,
			pw, ph,
			collisionfilter2)
		for i = 1, len2 do
			local item = items[i]
			if ent.shield.sprite:isVisible() then
				item.damage = ent.shield.damage
				item.isdirty = true
			end
		end
	end
	if ent.shield and ent.shield.currtimer > 0 then
		-- shield
		ent.shield.currtimer -= 1
		if ent.shield.currtimer <= 0 then
			if not ent.isdead then
				ent.shield.sprite:setVisible(false)
			end
		end
	end
	-- hurt fx
	if ent.washurt and ent.washurt > 0 and
		not (ent.wasbadlyhurt and ent.wasbadlyhurt > 0) and
		not ent.isdead then
		ent.washurt -= 1
		ent.animation.curranim = g_ANIM_HURT_R
		if ent.washurt < ent.recovertimer*0.5 then ent.hitfx:setVisible(false) end
		if ent.washurt <= 0 then ent.sprite:setColorTransform(1, 1, 1, 1) end
	elseif ent.wasbadlyhurt and ent.wasbadlyhurt > 0 and not ent.isdead then
		ent.wasbadlyhurt -= 1
		ent.animation.curranim = g_ANIM_LOSE1_R
		if ent.wasbadlyhurt < ent.recoverbadtimer*0.5 then
			ent.hitfx:setVisible(false)
			if resetanim then
				resetanim = false
				ent.animation.frame = 0
			end
			ent.animation.curranim = g_ANIM_STANDUP_R
		end
		if ent.wasbadlyhurt <= 0 then
			ent.sprite:setColorTransform(1, 1, 1, 1)
			resetanim = true
		end
	end
	-- hit
	if ent.isdirty then
--		self.channel = self.snd:play()
--		if self.channel then self.channel:setVolume(g_sfxvolume*0.01) end
		ent.hitfx:setVisible(true)
		ent.hitfx:setPosition(ent.pos.x+ent.collbox.w/2, ent.pos.y)
		ent.spritelayer:addChild(ent.hitfx)
		ent.currhealth -= ent.damage
		ent.washurt = ent.recovertimer -- timer for a flash effect
--		ent.sprite:setColorTransform(0, 0, 2, 3) -- the flash effect (a bright red color)
		ent.isdirty = false
		if ent.currhealth <= 0 then
			ent.wasbadlyhurt = ent.recoverbadtimer -- timer for actor to stand back up
			ent.currlives -= 1
			if ent.currlives > 0 then ent.currhealth = ent.totalhealth end
		end
	end
	-- deaded
	if ent.currlives <= 0 or ent.restart then
		-- stop all movements
		ent.isleft = false
		ent.isright = false
		ent.isup = false
		ent.isdown = false -- true, false
		-- play dead sequence
		ent.isdirty = false
		ent.washurt = ent.recovertimer
		ent.wasbadlyhurt = ent.recoverbadtimer
		-- blood
		if not ent.isdead then
			ent.hitfx:setVisible(true)
			ent.hitfx:setColorTransform(3, 0, 0, random(1, 3)/10) -- blood stain
--			ent.hitfx:setPosition(ent.pos.x+ent.collbox.w/2, ent.pos.y)
			ent.hitfx:setPosition(ent.pos.x+ent.collbox.w/2, ent.pos.y+ent.h*0.5)
			ent.hitfx:setRotation(random(360))
			ent.hitfx:setScale(random(5, 8)/10)
			ent.bgfxlayer:addChild(ent.hitfx)
			ent.isdead = true
			if ent.eid ~= 1000 then
				ent.readytoremove = true
			end
		end
		ent.animation.curranim = g_ANIM_LOSE1_R
		resetanim = false -- ??? XXX
--		ent.sprite:setColorTransform((-ent.pos.y<>ent.pos.y)/255, (-ent.pos.y<>ent.pos.y)/255, 0, 1)
--		ent.pos -= vector(1*8*ent.flip, 3*8)
--		ent.sprite:setPosition(ent.pos)
--		ent.sprite:setScale(ent.sprite:getScale()+0.07)
--		if not ent.isdead then
--			ent.spritelayer:removeChild(ent.shield.sprite)
--		end
		ent.shield.sprite = nil
--		if ent.pos.y < -256 then
		if ent.readytoremove then
			self.tiny.tworld:removeEntity(ent) -- sprite is removed in SDrawable
		end
	end
end
