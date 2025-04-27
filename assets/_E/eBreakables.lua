EDestructibleObject = Core.class()

function EDestructibleObject:init(xspritelayer, xpos)
	-- ids
	self.isdestructibleobject = true
	self.doanimate = true
	-- sprite layer
	self.spritelayer = xspritelayer
	-- params
	self.pos = xpos
	self.sx = 1
	self.sy = self.sx
	self.flip = math.random(100)
	if self.flip > 50 then self.flip = 1
	else self.flip = -1
	end
	self.totallives = 1
	self.totalhealth = 2
	if g_difficulty == 0 then -- easy
		self.totalhealth *= 0.5
	end
	self.currlives = self.totallives
	self.currhealth = self.totalhealth
	-- recovery
	self.washurt = 0
	self.wasbadlyhurt = 0
	self.recovertimer = 10
	self.hitfx = Bitmap.new(Texture.new("gfx/fxs/1.png"))
	self.hitfx:setAnchorPoint(0.5, 0.5)
	-- COMPONENTS
	-- ANIMATION: CAnimation:init(xspritesheetpath, xcols, xrows, xanimspeed, xoffx, xoffy, sx, sy)
	local texpath = "gfx/fxs/Husky_0001.png"
	local framerate = 1/10
	self.animation = CAnimation.new(texpath, 2, 2, framerate, 0, 0, self.sx, self.sy)
	self.sprite = self.animation.sprite
	self.sprite:setScale(self.sx*self.flip, self.sy) -- for the flip
	self.animation.sprite = nil -- free some memory
	self.w, self.h = self.sprite:getWidth(), self.sprite:getHeight()
	-- create animations: CAnimation:createAnim(xanimname, xstart, xfinish)
	self.animation:createAnim(g_ANIM_DEFAULT, 1, 4)
	self.animation:createAnim(g_ANIM_IDLE_R, 1, 4)
	-- clean up
	self.animation.myanimsimgs = nil
	-- BODY: CBody:init(xmass, xspeed, xupspeed)
	self.body = CBody.new(1, 0, 0) -- xspeed, xupspeed
	self.body.defaultmass = 1
	self.body.currmass = self.body.defaultmass
	-- COLLISION BOX: CCollisionBox:init(xcollwidth, xcollheight)
--	local collw, collh = self.w*1, 8*self.sy
	local collw, collh = self.w*1, self.h*1
	self.collbox = CCollisionBox.new(collw, collh)
end
