SPlayer1 = Core.class()

function SPlayer1:init(xtiny, xbump, xcamera) -- tiny function
	self.tiny = xtiny -- ref so we can remove entities from tiny system
	self.tiny.processingSystem(self) -- called once on init and every update
	self.bworld = xbump
	-- fx
	self.camera = xcamera -- camera shake
	self.camcurrzoom = self.camera:getZoom()
	-- sfx
	self.snd = Sound.new("audio/sfx/sfx_deathscream_human14.wav")
	self.channel = self.snd:play(0, false, true)
end

function SPlayer1:filter(ent) -- tiny function
	return ent.isplayer1
end

function SPlayer1:onAdd(ent) -- tiny function
end

function SPlayer1:onRemove(ent) -- tiny function
	self.bworld:remove(ent) -- remove collision box from cbump world here!
end

local resetanim = true
function SPlayer1:process(ent, dt) -- tiny function
	-- shoot
	if ent.isaction1 then
		ent.isaction1 = false
		local projectilespeed = 60*8 -- 54*8
		local xangle = ^<0
		if ent.flip == -1 then xangle = ^<180 end
		local vx, vy = projectilespeed * math.cos(xangle), projectilespeed * math.sin(xangle)
		--EProjectiles:init(xid, xmass, xangle, xspritelayer, xpos, xvx, xvy, dx, dy, xpersist)
		local p = EProjectiles.new(
			1, 0, xangle, ent.spritelayer, ent.pos+ent.poffset, vx, vy, 36*8, 40*8, false
		)
		p.body.vx = vx
		p.body.vy = vy
		self.tiny.tworld:addEntity(p)
		self.bworld:add(p, p.pos.x, p.pos.y, p.collbox.w, p.collbox.h)
	end
	-- shield
	if ent.isaction2 then
		ent.isaction2 = false
		ent.shield.currtimer = ent.shield.timer
		ent.shield.sprite:setVisible(true)
	end
	-- dash
	if ent.isaction3 then
		ent.isaction3 = false
		ent.body.currdashtimer = ent.body.dashtimer
		ent.body.currdashcooldown = ent.body.dashcooldown
	end
	--
	if ent.shield.currtimer > 0 then
		local function collisionfilter2(item) -- only one param: "item", return true, false or nil
			if item.isnme or (item.isprojectile and item.eid > 1) then
				return true
			end
		end
		ent.shield.sprite:setScale(ent.shield.sprite.sx*ent.flip, ent.shield.sprite.sy)
		ent.shield.sprite:setPosition(
			ent.pos + vector(ent.collbox.w/2, 0) + ent.shield.offset*vector(ent.shield.sprite.sx*ent.flip, ent.shield.sprite.sy)
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
--			if ent.shield.sprite:isVisible() then
			if ent.shield.currtimer > 0 then
				item.damage = ent.shield.damage
				item.isdirty = true
			end
		end
	end
	if ent.shield and ent.shield.currtimer > 0 then
		ent.shield.currtimer -= 1
		if ent.shield.currtimer <= 0 then
			ent.shield.sprite:setVisible(false)
		end
	end
	-- hurt fx
	if ent.washurt and ent.washurt > 0 and not (ent.wasbadlyhurt and ent.wasbadlyhurt > 0) then
		ent.washurt -= 1
		ent.animation.curranim = g_ANIM_HURT_R
		if ent.washurt < ent.recovertimer*0.5 then ent.hitfx:setVisible(false) end
		if ent.washurt <= 0 then
			ent.sprite:setColorTransform(1, 1, 1, 1)
			self.camera:setZoom(self.camcurrzoom) -- zoom
		end
	elseif ent.wasbadlyhurt and ent.wasbadlyhurt > 0 then
		ent.hitfx:setVisible(false)
		ent.wasbadlyhurt -= 1
		ent.animation.curranim = g_ANIM_LOSE1_R
		if ent.wasbadlyhurt < ent.recoverbadtimer/2 then
			if resetanim then
				resetanim = false
				ent.animation.frame = 0
			end
			ent.animation.curranim = g_ANIM_STANDUP_R
		end
		if ent.wasbadlyhurt <= 0 then
			ent.sprite:setColorTransform(1, 1, 1, 1)
			self.camera:setZoom(self.camcurrzoom) -- zoom
			resetanim = true
		end
	end
	if ent.body.currdashtimer > 0 then ent.isdirty = false end
	if ent.isdirty then -- hit
		local function map(v, minSrc, maxSrc, minDst, maxDst, clampValue)
			local newV = (v - minSrc) / (maxSrc - minSrc) * (maxDst - minDst) + minDst
			return not clampValue and newV or clamp(newV, minDst><maxDst, minDst<>maxDst)
		end
		self.channel = self.snd:play()
		if self.channel then self.channel:setVolume(g_sfxvolume*0.01) end
		ent.hitfx:setVisible(true)
		ent.hitfx:setPosition(ent.pos.x+ent.collbox.w/2, ent.pos.y)
		ent.spritelayer:addChild(ent.hitfx)
		ent.currhealth -= ent.damage
		local hudhealthwidth = map(ent.currhealth, 0, ent.totalhealth, 0, 100)
		self.tiny.hudhealth:setWidth(hudhealthwidth)
		if ent.currhealth < ent.totalhealth/3 then self.tiny.hudhealth:setColor(0xff0000)
		elseif ent.currhealth < ent.totalhealth/2 then self.tiny.hudhealth:setColor(0xff5500)
		else self.tiny.hudhealth:setColor(0x00ff00)
		end
		ent.washurt = ent.recovertimer -- timer for a flash effect
--		ent.sprite:setColorTransform(2, 0, 0, 2) -- the flash effect (a bright red color)
		ent.isdirty = false
--		self.camera:shake(0.6, 16) -- (duration, distance), you choose
--		self.camera:setZoom(self.camcurrzoom+0.2) -- zoom
		if ent.currhealth <= 0 then
			ent.wasbadlyhurt = ent.recoverbadtimer -- timer for player1 to stand back up
			self.camera:shake(0.8, 64) -- (duration, distance), you choose
			ent.currlives -= 1
			for i = 1, ent.totallives do self.tiny.hudlives[i]:setVisible(false) end -- dirty but easy XXX
			for i = 1, ent.currlives do self.tiny.hudlives[i]:setVisible(true) end -- dirty but easy XXX
			if ent.currlives > 0 then
				ent.currhealth = ent.totalhealth
				hudhealthwidth = map(ent.currhealth, 0, ent.totalhealth, 0, 100)
				self.tiny.hudhealth:setWidth(hudhealthwidth)
				self.tiny.hudhealth:setColor(0x00ff00)
				if ent.currlives == 1 then self.tiny.hudlives[1]:setColor(0xff0000) end
			end
		end
	end
	if ent.currlives <= 0 then -- deaded
		-- stop all movements
		ent.isleft = false
		ent.isright = false
		ent.isup = false
		ent.isdown = false
		-- play dead sequence
		ent.isdirty = false
		resetanim = false
		ent.washurt = ent.recovertimer
		ent.wasbadlyhurt = ent.recoverbadtimer
		ent.animation.curranim = g_ANIM_LOSE1_R
		ent.sprite:setColorTransform(255*0.5/255, 255*0.5/255, 255*0.5/255, 1)
		self.camera:setZoom(self.camcurrzoom) -- zoom
--[[
		self.tiny.tworld:removeEntity(ent) -- sprite is removed in SDrawable
		ent.animation.bmp:setY(ent.animation.bmp:getY()-1)
		if ent.animation.bmp:getY() < -200 then -- you choose
			ent.restart = true
		end
]]
		ent.body.currmass = -0.025
		ent.isup = true
--		if ent.pos.y < -200 then -- you choose
--			ent.restart = true
--		end
		local timer = Timer.new(2000, 1)
		timer:addEventListener(Event.TIMER_COMPLETE, function(e)
			ent.restart = true
		end)
		timer:start()
	end
end
