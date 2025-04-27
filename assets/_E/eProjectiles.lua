EProjectiles = Core.class()

function EProjectiles:init(xid, xmass, xangle, xspritelayer, xpos, xvx, xvy, dx, dy, xpersist)
	-- ids
	self.isprojectile = true
	self.eid = xid
	self.doanimate = false -- if not animated set to false to save some cpu
	self.ispersistant = xpersist
	-- sprite layer
	self.spritelayer = xspritelayer
	-- params
	self.pos = xpos
--	self.angle = ^>xangle
	self.sx = 0.8
	self.sy = 1 -- self.sx
	self.flip = 1
	self.totallives = 1
	self.currlives = self.totallives
	-- COMPONENTS
	-- ANIMATION
	local anims = {} -- table to hold actor animations
	local animsimgs = {} -- table to hold actor animations images
	-- CAnimation:init(xanimspeed)
	local framerate = 1/10
	self.animation = CAnimation.new(framerate)
	-- CAnimation:cutSpritesheet(xspritesheetpath, xcols, xrows, xanimsimgs, xoffx, xoffy, sx, sy)
	local texpath
	texpath = "gfx/ammos/bullet1_0001.png"
	if self.eid == 100 then texpath = "gfx/ammos/bullet1_0010.png" end
	self.animation:cutSpritesheet(texpath, 1, 1, animsimgs, 0, 0, self.sx, self.sy)
	-- 1st set of animations: CAnimation:createAnim(xanims, xanimname, xanimsimgs, xstart, xfinish)
	self.animation:createAnim(anims, g_ANIM_DEFAULT, animsimgs, 1, 6)
	self.animation:createAnim(anims, g_ANIM_IDLE_R, animsimgs, 1, 6)
	-- end animations
	self.animation.anims = anims
	self.sprite = self.animation.sprite
	self.animation.sprite = nil -- free some memory
	self.sprite:setScale(self.sx*self.flip, self.sy)
	self.sprite:setRotation(^>xangle) -- ^>rad, convert 'rad' into degrees
	self.w, self.h = self.sprite:getWidth(), self.sprite:getHeight()
	-- BODY: CBody:init(xmass, xspeed, xupspeed)
	self.body = CBody.new(xmass or 0, xvx, xvy) -- xmass, xspeed, xupspeed
	-- COLLISION BOX: CCollisionBox:init(xcollwidth, xcollheight)
	local collw, collh = (self.w*0.5)//1, (self.h*0.5)//1
	self.collbox = CCollisionBox.new(collw, collh)
	-- AI: CDistance:init(xstartpos, dx, dy)
	self.dist = CDistance.new(self.pos, dx, dy)
end
