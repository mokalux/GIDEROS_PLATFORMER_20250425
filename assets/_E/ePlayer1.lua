EPlayer1 = Core.class()

function EPlayer1:init(xspritelayer, xpos, xbgfxlayer)
	-- ids
	self.isplayer1 = true
	self.doanimate = true -- to save some cpu
	self.ispersistent = true
	-- sprite layers
	self.spritelayer = xspritelayer
	self.bgfxlayer = xbgfxlayer
	-- params
	self.pos = xpos
	self.sx = 1 -- 0.96, 0.8, 1.05, 1.1, 1.2
	self.sy = self.sx
	self.flip = 1
	self.totallives = 3 -- 3
	self.totalhealth = 3 -- 10
	if g_difficulty == 0 then -- easy
		self.totallives = 5
		self.totalhealth *= 2
	end
	self.currlives = self.totallives
	self.currhealth = self.totalhealth
	-- recovery
	self.washurt = 0
	self.wasbadlyhurt = 0
	self.recovertimer = 30
	self.recoverbadtimer = 90
	if g_difficulty == 0 then -- easy
		self.recovertimer *= 2
		self.recoverbadtimer *= 2
	elseif g_difficulty == 2 then -- hard
		self.recovertimer *= 0.5
		self.recoverbadtimer *= 0.5
	end
	self.ispaused = false -- 'P' key for pausing the game
	self.hitfx = Bitmap.new(Texture.new("gfx/fxs/2.png"))
	self.hitfx:setAnchorPoint(0.5, 0.5)
	-- COMPONENTS
	-- ANIMATION
	local anims = {} -- table to hold actor animations
	local animsimgs = {} -- table to hold actor animations images
	-- CAnimation:init(xanimspeed)
	local framerate = 1/14 -- 1/18
	self.animation = CAnimation.new(framerate)
	-- CAnimation:cutSpritesheet(xspritesheetpath, xcols, xrows, xanimsimgs, xoffx, xoffy, sx, sy)
	local texpath = "gfx/player1/Ely_By_K.Atienza_0002.png"
	self.animation:cutSpritesheet(texpath, 5, 4, animsimgs, 0, 1, self.sx, self.sy)
	-- 1st set of animations: CAnimation:createAnim(xanims, xanimname, xanimsimgs, xstart, xfinish)
	self.animation:createAnim(anims, g_ANIM_DEFAULT, animsimgs, 1, 9)
	self.animation:createAnim(anims, g_ANIM_IDLE_R, animsimgs, 1, 9) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_RUN_R, animsimgs, 10, 17) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_JUMPUP_R, animsimgs, 18, 18) -- fluid is best
	self.animation:createAnim(anims, g_ANIM_JUMPDOWN_R, animsimgs, 19, 19) -- fluid is best
--	self.animation:createAnim(anims, g_ANIM_LADDER_IDLE_R, animsimgs, 3, 3) -- fluid is best
	-- 2nd set of animations: CAnimation:createAnim(xanims, xanimname, xanimsimgs, xstart, xfinish)
--	local o = 6*3 -- previous spritesheet rows*columns
--	texpath = "gfx/player1/Ely_By_K.Atienza2_0050.png"
--	self.animation:cutSpritesheet(texpath, 6, 3, animsimgs, 0, 0, self.sx, self.sy)
--	self.animation:createAnim(anims, g_ANIM_JUMPUP_R, animsimgs, o+1, o+1) -- fluid is best
--	self.animation:createAnim(anims, g_ANIM_JUMPDOWN_R, animsimgs, o+2, o+2) -- fluid is best
--	self.animation:createAnim(anims, g_ANIM_LADDER_IDLE_R, animsimgs, o+3, o+3) -- fluid is best
--	self.animation:createAnim(anims, g_ANIM_LADDER_UP_R, animsimgs, o+3, o+10) -- fluid is best
--	self.animation:createAnim(anims, g_ANIM_LADDER_DOWN_R, animsimgs, o+11, o+18) -- fluid is best
	-- end animations
	self.animation.anims = anims
	self.sprite = self.animation.sprite
	self.animation.sprite = nil -- free some memory
	self.w, self.h = self.sprite:getWidth()//1, self.sprite:getHeight()//1 -- with applied scale
	print("player1 size (scaled): ", self.w, self.h)
	-- BODY: CBody:init(xmass, xspeed, xupspeed, xextra)
	self.body = CBody.new(1, 22*8, 70*8, true) -- 26*8, 72*8, 26*8, 60*8, 22*8, 53*8, 19*8, 52*8
	-- COLLISION BOX: CCollisionBox:init(xcollwidth, xcollheight)
	local collw, collh = -- coll box must be round size for cbump physics!
		(self.w*0.3)//1, (self.h*0.85)//1
	self.collbox = CCollisionBox.new(collw, collh)
	-- shield
	self.shield = {}
--	self.shield.sprite = Bitmap.new(Texture.new("gfx/fxs/Husky_0001.png"))
	self.shield.sprite = Pixel.new(0xffaa00, 0.75, 8, collh+4)
	self.shield.sprite.sx = 1
	self.shield.sprite.sy = self.shield.sprite.sx
	self.shield.sprite:setScale(self.shield.sprite.sx, self.shield.sprite.sy)
	self.shield.sprite:setAlpha(0.8)
	self.shield.sprite:setAnchorPoint(0.5, 0.5)
	self.spritelayer:addChild(self.shield.sprite)
	self.shield.offset = vector(3*8, 3.65*8) -- (5*8, -1*8)
	self.shield.timer = 3*8 -- 2*8
	self.shield.currtimer = self.shield.timer
	self.shield.damage = 0.1
end
