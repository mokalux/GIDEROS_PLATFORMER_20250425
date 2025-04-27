EDoor = Core.class()

function EDoor:init(xid, xspritelayer, xcolor, xtexpath, xpos, w, h, dx, dy, xdir, xspeed, xbgfxlayer)
	-- ids
	self.isdoor = true
	self.eid = xid -- player1 needs key matching the door name
--	print("isdoor", self.eid)
	-- sprite layers
	self.spritelayer = xspritelayer
	self.bgfxlayer = xbgfxlayer
	-- params
	self.pos = xpos
	self.sx = 1
	self.sy = self.sx
	self.flip = 1
	if xcolor then
		self.sprite = Pixel.new(xcolor, 1, w, h)
	else -- texture
--		self.sprite = Bitmap.new(Texture.new(xtexpath))
--		self.sprite = Pixel.new(w, h, Texture.new(xtexpath)) -- stretched
--		self.sprite = Pixel.new(Texture.new(xtexpath), w, h) -- letterbox
		self.sprite = Pixel.new(Texture.new(xtexpath), w, h, 0.2, 0.2) -- letterbox
		self.sprite:setColorTransform(6.5*32/255, 6.5*32/255, 6*32/255, 8*32/255)
		--
--		self.sprite = Pixel.new(0xffffff, 1, w, h)
--		self.sprite:setTexture(Texture.new(xtexpath))
--		self.sprite:setNinePatch(8)
	end
	self.sprite:setAnchorPoint(0.5, 0.5)
	self.sprite:setScale(self.sx, self.sy)
	self.w, self.h = self.sprite:getWidth(), self.sprite:getHeight()
	-- COMPONENTS
	-- BODY: CBody:init(xmass, xspeed, xupspeed)
	self.body = CBody.new(1, xspeed.x, xspeed.y) -- xmass, xspeed, xupspeed
	-- COLLISION BOX: CCollisionBox:init(xcollwidth, xcollheight)
	local collw, collh = self.w, self.h -- full size collision box
	self.collbox = CCollisionBox.new(collw, collh)
	-- motion AI: CDistance:init(xstartpos, dx, dy)
	self.distance = CDistance.new(self.pos, dx, dy)
	self.dir = xdir
end
