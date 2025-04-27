EMvpf = Core.class()

function EMvpf:init(xspritelayer, xpos, xcolor, w, h, dx, dy, xdir, xspeed, xbgfxlayer, xisptmvpf)
	-- ids
	self.ismvpf = true
	self.isptmvpf = xisptmvpf -- is it a passthrough moving platform?
	-- sprite layers
	self.spritelayer = xspritelayer
	self.bgfxlayer = xbgfxlayer
	-- params
	self.pos = xpos
	self.sx = 1
	self.sy = self.sx
	self.flip = 1
	-- texture
--	local texpath = "gfx/logo.png"
--	self.sprite = Bitmap.new(Texture.new(texpath))
	self.sprite = Pixel.new(xcolor, 1, w, h)
	self.sprite:setAnchorPoint(0.5, 0.5)
	self.sprite:setScale(self.sx, self.sy)
	self.w, self.h = self.sprite:getWidth(), self.sprite:getHeight()
	-- COMPONENTS
	-- BODY: CBody:init(xmass, xspeed, xupspeed)
	self.body = CBody.new(0, xspeed.x, xspeed.y) -- xmass, xspeed, xupspeed
	-- COLLISION BOX: CCollisionBox:init(xcollwidth, xcollheight)
	local collw, collh = self.w, self.h
	self.collbox = CCollisionBox.new(collw, collh)
	-- motion AI: CDistance:init(xstartpos, dx, dy)
	self.distance = CDistance.new(self.pos, dx, dy)
	-- start moving
	self.dir = xdir
	if self.dir:match("l") then self.isleft = true end
	if self.dir:match("r") then self.isright = true end
	if self.dir:match("u") then self.isup = true end
	if self.dir:match("d") then self.isdown = true end
end
