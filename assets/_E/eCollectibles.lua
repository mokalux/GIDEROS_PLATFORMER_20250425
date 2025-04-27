ECollectibles = Core.class()

function ECollectibles:init(xid, xspritelayer, xpos, xspeed, xdx, xdy)
	-- ids
	self.iscollectible = true
	self.eid = xid
--	self.doanimate = true -- added in Collectibles System (SCollectibles)
	-- sprite layer
	self.spritelayer = xspritelayer
	-- params
	self.pos = xpos
	self.sx = 1
	self.sy = self.sx
	self.flip = 1
	self.totallives = 1
	self.currlives = self.totallives
	-- 10 = default to coin
	local framerate = 1/10 -- magik XXX
	local texpath = "gfx/collectibles/Coin_A_0_0001.png"
	local cols, rows = 4, 3
	self.sx = 0.7
	if self.eid == "lives" then -- heart
		texpath = "gfx/collectibles/Heart_2_0001.png"
		cols, rows = 4, 3
		self.sx = 0.8
	elseif self.eid:find("kdoor") then -- key
		texpath = "gfx/collectibles/Key_3_0001.png"
		cols, rows = 4, 3
		self.sx = 0.8
	end
	self.sy = self.sx
	-- COMPONENTS
	-- ANIMATION
	local anims = {} -- table to hold actor animations
	local animsimgs = {} -- table to hold actor animations images
	-- CAnimation:init(xanimspeed)
	self.animation = CAnimation.new(framerate)
	-- CAnimation:cutSpritesheet(xspritesheetpath, xcols, xrows, xanimsimgs, xoffx, xoffy, sx, sy)
	self.animation:cutSpritesheet(texpath, cols, rows, animsimgs, 0, 0, self.sx, self.sy)
	-- 1st set of animations: CAnimation:createAnim(xanims, xanimname, xanimsimgs, xstart, xfinish)
	self.animation:createAnim(anims, g_ANIM_DEFAULT, animsimgs, 1, cols*rows)
	self.animation:createAnim(anims, g_ANIM_IDLE_R, animsimgs, 1, cols*rows)
	-- end animations
	self.animation.anims = anims
	self.sprite = self.animation.sprite
	self.sprite:setScale(self.sx*self.flip, self.sy)
	self.animation.sprite = nil -- free some memory
	self.w, self.h = self.sprite:getWidth()//1, self.sprite:getHeight()//1 -- with applied scale
	-- COLLISION BOX: CCollisionBox:init(xcollwidth, xcollheight)
	local collw, collh = (self.w*self.sx)//1, (self.h*self.sy)//1 -- self.w*1, self.h*1, best all have same size?, magik XXX
	self.collbox = CCollisionBox.new(collw, collh)
	-- COscillation:init(xspeed, xamplitudex, xamplitudey)
	self.oscillation = COscillation.new(xspeed, xdx, xdy)
end
