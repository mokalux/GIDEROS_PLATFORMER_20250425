ENpc1 = Core.class()

function ENpc1:init(xid:number, xspritelayer, xpos, dx:number, dy:number, xbgfxlayer, xcollectible)
	-- ids
	self.isnpc = true
	-- eid: 10 = basic nme: jump
	self.eid = xid
	-- sprite layers
	self.spritelayer = xspritelayer
	self.bgfxlayer = xbgfxlayer
	-- params
	self.pos = xpos
	self.sx = 1 -- 0.96
	self.sy = self.sx
	self.flip = 1
	self.totallives = 2
	self.totalhealth = 3
	-- 100: no move, no jump, shoot straight
	-- 200: move, jump, no shoot
	-- 300: no move, no jump, shoot all angles, shield
	-- 400: move, jump, shoot straight, shield
	if self.eid == 100 then
		self.totallives = 100
		self.totalhealth = 500
	elseif self.eid == 200 then
		self.totallives = 1
		self.totalhealth = 3
	end
	-- recovery
	self.recovertimer = 8
	self.recoverbadtimer = 30
	self.actiontimer = 60 -- math.random(32, 96), low value=hard, high value=easy
	if g_difficulty == 0 then -- easy
		self.totallives = 1
		self.totalhealth = 3
		self.recovertimer *= 0.5
		self.recoverbadtimer *= 0.5
		self.actiontimer *= 2
	elseif g_difficulty == 2 then -- hard
		self.recovertimer *= 2
		self.recoverbadtimer *= 2
		self.actiontimer *= 0.5
	end
	self.hitfx = Bitmap.new(Texture.new("gfx/fxs/1.png"))
	self.hitfx:setAnchorPoint(0.5, 0.5)
	-- COMPONENTS
	-- ANIMATION
	local anims = {} -- table to hold actor animations
	local animsimgs = {} -- table to hold actor animations images
	-- CAnimation:init(xanimspeed)
	local framerate = 1/10 -- 1/12
	self.animation = CAnimation.new(framerate)
	-- CAnimation:cutSpritesheet(xspritesheetpath, xcols, xrows, xanimsimgs, xoffx, xoffy, sx, sy)
	local texpath
	local cols, rows
	if self.eid == 100 then
		texpath = "gfx/npcs/Amy_0001.png"
		cols, rows = 7, 4
		self.animation:cutSpritesheet(texpath, cols, rows, animsimgs, 1, 1, self.sx, self.sy)
	elseif self.eid == 200 then
		texpath = "gfx/nmes/Exo_Gray01_0050.png"
		cols, rows = 4, 3
		self.animation:cutSpritesheet(texpath, cols, rows, animsimgs, 0, 1, self.sx, self.sy)
	end
	-- 1st set of animations: CAnimation:createAnim(xanims, xanimname, xanimsimgs, xstart, xfinish)
	if self.eid == 100 then
		self.animation:createAnim(anims, g_ANIM_DEFAULT, animsimgs, 1, 20) -- fluid is best
		self.animation:createAnim(anims, g_ANIM_IDLE_R, animsimgs, 1, 20) -- fluid is best
		self.animation:createAnim(anims, g_ANIM_RUN_R, animsimgs, 21, 28) -- fluid is best
		self.animation:createAnim(anims, g_ANIM_JUMPUP_R, animsimgs, 25, 25) -- fluid is best
		self.animation:createAnim(anims, g_ANIM_JUMPDOWN_R, animsimgs, 27, 27) -- fluid is best
	end
	-- end animations
	self.animation.anims = anims
	self.sprite = self.animation.sprite
	self.animation.sprite = nil -- free some memory
	self.w, self.h = self.sprite:getWidth()//1, self.sprite:getHeight()//1 -- with applied scale
	-- BODY: CBody:init(xmass, xspeed, xupspeed, xextra)
	if self.eid == 100 then
		self.body = CBody.new(1, 10*8, 32*8, true)
	elseif self.eid == 200 then
		self.body = CBody.new(1, 12*8, 64*8, true) -- 16*8, 64*8
	end
	-- COLLISION BOX: CCollisionBox:init(xcollwidth, xcollheight)
	local collw, collh = (self.w*0.5)//1, (self.h*0.8)//1
--	if self.eid == 1000 then
--		collh = (self.h*0.4)//1
--	end
	self.collbox = CCollisionBox.new(collw, collh)
	-- AI: CDistance:init(xstartpos, dx, dy)
--	self.ai = CDistance.new(self.pos, dx, dy)
--	self.ai = true
	-- shield
	self.shield = {}
--	self.shield.sprite = Bitmap.new(Texture.new("gfx/fxs/Husky_0001.png"))
	if self.eid == 1000 then
		self.shield.sprite = Pixel.new(0x5555ff, 0.75, 8, collh*0.5)
	else
		self.shield.sprite = Pixel.new(0x5555ff, 0.75, 8, collh)
	end
	self.shield.sprite.sx = 1
	self.shield.sprite.sy = self.shield.sprite.sx
	self.shield.sprite:setScale(self.shield.sprite.sx, self.shield.sprite.sy)
--	self.shield.sprite:setAlpha(0.8)
	self.shield.sprite:setAnchorPoint(0.5, 0.5)
	self.spritelayer:addChild(self.shield.sprite)
	self.shield.offset = vector(3*8, 3.7*8) -- (5*8, -1*8)
	if self.eid == 1000 then
		self.shield.offset = vector(5*8, 6*8) -- (5*8, -1*8)
	end
	self.shield.timer = 4*8 -- 4*8, 2*8
	if self.eid == 1000 then
		self.shield.timer = 6*8 -- 4*8, 2*8
	end
	self.shield.currtimer = self.shield.timer
	self.shield.damage = 0.1
end
