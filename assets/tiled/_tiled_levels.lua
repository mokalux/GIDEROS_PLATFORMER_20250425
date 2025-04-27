TiledLevels = Core.class(Sprite)

function TiledLevels:init(tmpath, xtiny, xbworld, xlayers)
	local tm = require(tmpath) -- eg.: "tiled/test" without ".lua" extension + exclude from execution!
	local tsimgpath -- "tiled/", root path to tileset tilemap images
	if g_currlevel == 1 then tsimgpath = "tiled/lvl001/" -- level1
	elseif g_currlevel == 2 then tsimgpath = "tiled/lvl001/" -- level1 part2
	elseif g_currlevel == 3 then tsimgpath = "tiled/lvl003/"
	end
	-- _______ _____ _      ______  _____ ______ _______ 
	--|__   __|_   _| |    |  ____|/ ____|  ____|__   __|
	--   | |    | | | |    | |__  | (___ | |__     | |   
	--   | |    | | | |    |  __|  \___ \|  __|    | |   
	--   | |   _| |_| |____| |____ ____) | |____   | |   
	--   |_|  |_____|______|______|_____/|______|  |_|   
	-- this is the classic
	for i = 1, #tm.tilesets do -- important
		local tileset = tm.tilesets[i]
		-- add extra values (variables) to a tm.tilesets[i] table
		if tileset.image then -- only tileset tilemap layers
			tileset.numcols = math.floor(
				(tileset.imagewidth-tileset.margin+tileset.spacing)/
				(tileset.tilewidth+tileset.spacing)
			)
			tileset.numrows = math.floor(
				(tileset.imageheight-tileset.margin+tileset.spacing)/
				(tileset.tileheight+tileset.spacing)
			)
			tileset.lastgid = tileset.firstgid+(tileset.numcols*tileset.numrows)-1
			tileset.texture = Texture.new(
				tsimgpath..tileset.image, false,
				{ transparentColor=tonumber(tileset.transparentcolor) }
			)
		end
	end
	-- tileset function
	local function gid2tileset(tm, gid)
		for i = 1, #tm.tilesets do
			local tileset = tm.tilesets[i]
			if tileset.image then -- only valid tileset layers
				if tileset.firstgid <= gid and gid <= tileset.lastgid then
					return tileset
				end
			end
		end
	end
	-- _______ _____ _      ______  _____ ______ _______ 
	--|__   __|_   _| |    |  ____|/ ____|  ____|__   __|
	--   | |    | | | |    | |__  | (___ | |__     | |   
	--   | |    | | | |    |  __|  \___ \|  __|    | |   
	--   | |   _| |_| |____| |____ ____) | |____   | |   
	--   |_|  |_____|______|______|_____/|______|  |_|   
	-- _____ __  __          _____ ______  _____ 
	--|_   _|  \/  |   /\   / ____|  ____|/ ____|
	--  | | | \  / |  /  \ | |  __| |__  | (___  
	--  | | | |\/| | / /\ \| | |_ |  __|  \___ \ 
	-- _| |_| |  | |/ ____ \ |__| | |____ ____) |
	--|_____|_|  |_/_/    \_\_____|______|_____/ 
	-- this one parses individual images
	local tilesetimages = {} -- table holding all the tileset images info (path, width, height)
	for i = 1, #tm.tilesets do
		local tileset = tm.tilesets[i]
		if not tileset.image then -- filter out tileset tilemap layers, only tileset images
			local tiles = tileset.tiles
			for j = 1, #tiles do
				-- populate the tilesetimages table based on the tile gid and id
				-- note: you may have to adjust the path to point to the image folder
				tilesetimages[tileset.firstgid + tiles[j].id] = {
					path=tsimgpath..tiles[j].image,
					width=tiles[j].width,
					height=tiles[j].height,
				}
			end
		end
	end
	-- tileset images function
	local function parseImage(xobject, xlayer, xfx)
		local fx = xfx or 0
		local tex = Texture.new(tilesetimages[xobject.gid].path, false)
		local bitmap = Bitmap.new(tex)
		bitmap:setAnchorPoint(0, 1) -- because I always forget to modify Tiled objects alignment
		-- supports Tiled image scaling
		local scalex, scaley = xobject.width/tex:getWidth(), xobject.height/tex:getHeight()
		bitmap:setScale(scalex, scaley)
		bitmap:setRotation(xobject.rotation)
		bitmap:setPosition(xobject.x, xobject.y)
		xlayer:addChild(bitmap)
		-- table
--		xbworld.hidegfx[#xbworld.hidegfx + 1] = {bmp=bitmap, x=xobject.x, y=xobject.y}
--		print(#xbworld.hidegfx + 1)
		-- shader
		if fx == 1 then
			bitmap:setShader(Effect.colour_pixelation)
			bitmap:setColorTransform(8*32/255, 8*32/255, 5.5*32/255, 7*32/255)
		elseif fx == 2 then
			bitmap:setShader(Effect.colour_pixelation)
			bitmap:setColorTransform(8*32/255, 8*32/255, 5.5*32/255, 8*32/255)
		elseif fx == 3 then
			bitmap:setShader(Effect.colour_pixelation2)
--			bitmap:setColorTransform(8*32/255, 8*32/255, 6.0*32/255, 8*32/255)
			bitmap:setColorTransform(8*32/255, 8*32/255, 6.5*32/255, 8*32/255)
		else
--			bitmap:setShader(Effect.colour_pixelation2)
----			bitmap:setColorTransform(8*32/255, 8*32/255, 6.0*32/255, 8*32/255)
			bitmap:setColorTransform(8*32/255, 8*32/255, 6.5*32/255, 8*32/255)
		end
		-- EHideable:init(xbitmap, xpos)
		local e = EHideable.new(
			bitmap, vector(xobject.x, xobject.y)
		)
		xtiny.tworld:addEntity(e)
	end
	-- ____  _    _ _____ _      _____    _      ________      ________ _      
	--|  _ \| |  | |_   _| |    |  __ \  | |    |  ____\ \    / /  ____| |     
	--| |_) | |  | | | | | |    | |  | | | |    | |__   \ \  / /| |__  | |     
	--|  _ <| |  | | | | | |    | |  | | | |    |  __|   \ \/ / |  __| | |     
	--| |_) | |__| |_| |_| |____| |__| | | |____| |____   \  /  | |____| |____ 
	--|____/ \____/|_____|______|_____/  |______|______|   \/   |______|______|
	for i = 1, #tm.layers do
		local layer = tm.layers[i]
		local tilemaps = {}
		local group -- group = Sprite.new()
		-- _______ _____ _      ______ _           __     ________ _____  
		--|__   __|_   _| |    |  ____| |        /\\ \   / /  ____|  __ \ 
		--   | |    | | | |    | |__  | |       /  \\ \_/ /| |__  | |__) |
		--   | |    | | | |    |  __| | |      / /\ \\   / |  __| |  _  / 
		--   | |   _| |_| |____| |____| |____ / ____ \| |  | |____| | \ \ 
		--   |_|  |_____|______|______|______/_/    \_\_|  |______|_|  \_\
		if layer.type == "tilelayer" and (layer.name:match("bg") or layer.name:match("fg")) then
			if layer.name:match("bg") then group = xlayers["bg"]
			else group = xlayers["fg"]
			end
			for y = 1, layer.height do
				for x = 1, layer.width do
					local index = x + (y - 1) * layer.width
					local gid = layer.data[index]
					local gidtileset = gid2tileset(tm, gid)
					if gidtileset then
						local tilemap
						if tilemaps[gidtileset] then
							tilemap = tilemaps[gidtileset]
						else
							tilemap = TileMap.new(
								layer.width, layer.height,
								gidtileset.texture, gidtileset.tilewidth, gidtileset.tileheight,
								gidtileset.spacing, gidtileset.spacing,
								gidtileset.margin, gidtileset.margin,
								tm.tilewidth, tm.tileheight
							)
							tilemaps[gidtileset] = tilemap
							group:addChild(tilemap)
						end
						local tx = (gid - gidtileset.firstgid) % gidtileset.numcols + 1
						local ty = math.floor((gid - gidtileset.firstgid) / gidtileset.numcols) + 1
						-- set the tile with flip info (bug on reload so won't use it!)
--						tilemap:setTile(x, y, tx, ty, flipHor|flipVer|flipDia)
						tilemap:setTile(x, y, tx, ty)
					end
				end
			end
			group:setAlpha(layer.opacity)
		--  ____  ____       _ ______ _____ _______ _           __     ________ _____  
		-- / __ \|  _ \     | |  ____/ ____|__   __| |        /\\ \   / /  ____|  __ \ 
		--| |  | | |_) |    | | |__ | |       | |  | |       /  \\ \_/ /| |__  | |__) |
		--| |  | |  _ < _   | |  __|| |       | |  | |      / /\ \\   / |  __| |  _  / 
		--| |__| | |_) | |__| | |___| |____   | |  | |____ / ____ \| |  | |____| | \ \ 
		-- \____/|____/ \____/|______\_____|  |_|  |______/_/    \_\_|  |______|_|  \_\
		elseif layer.type == "objectgroup" then
			local o
			local myshape, mytable
			local levelsetup = {}
			--                             _       __ _       _ _   _             
			--                            | |     / _(_)     (_) | (_)            
			-- _ __ ___   __ _ _ __     __| | ___| |_ _ _ __  _| |_ _  ___  _ __  
			--| '_ ` _ \ / _` | '_ \   / _` |/ _ \  _| | '_ \| | __| |/ _ \| '_ \ 
			--| | | | | | (_| | |_) | | (_| |  __/ | | | | | | | |_| | (_) | | | |
			--|_| |_| |_|\__,_| .__/   \__,_|\___|_| |_|_| |_|_|\__|_|\___/|_| |_|
			--                | |                                                 
			--                |_|                                                 
			if layer.name == "physics_map_def" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					self.mapdef = {}
					self.mapdef.t = o.y
					self.mapdef.l = o.x
					self.mapdef.r = o.width
					self.mapdef.b = o.height
				end
			--     _                  _                           
			--    | |                | |                          
			--  __| | ___  ___ ___   | | __ _ _   _  ___ _ __ ___ 
			-- / _` |/ _ \/ __/ _ \  | |/ _` | | | |/ _ \ '__/ __|
			--| (_| |  __/ (_| (_) | | | (_| | |_| |  __/ |  \__ \
			-- \__,_|\___|\___\___/  |_|\__,_|\__, |\___|_|  |___/
			--                                 __/ |              
			--                                |___/               
			elseif layer.name == "bg_deco_texts" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					mytable = {
						color=layer.tintcolor,
					}
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					myshape = self:buildShapes(o, levelsetup)
					myshape:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(myshape)
				end
			elseif layer.name:match("bg_deco_images") then
				for i = 1, #layer.objects do
--					if layer.name:match("x$") then
--						parseImage(layer.objects[i], xlayers["bg"], 1)
--					else
----						if g_currlevel == 1 then parseImage(layer.objects[i], xlayers["bg"], 3)
----						else parseImage(layer.objects[i], xlayers["bg"], nil)
----						end
--						parseImage(layer.objects[i], xlayers["bg"], nil)
--					end
					parseImage(layer.objects[i], xlayers["bg"], nil)
				end
			elseif layer.name == "bg_deco_shapes_lights" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					myshape, mytable = nil, nil
					local pixel = Pixel.new(0xffffff, 1, o.width, o.height)
					pixel:setColor(0xffff7f,0.5, 0x5555ff,0, 3*30) -- 0x5555ff,1, 0xffaa7f,1 -- 0x55aaff,1, 0xffaa7f,1
					pixel:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(pixel)
--[[
--					local color = rgb2hex(table.unpack(layer.tintcolor))
					local color = 0x00aaff -- 0x185a66, math.random(0xffffff)
					mytable = {
						color=color,
					}
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					myshape = self:buildShapes(o, levelsetup)
					myshape:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(myshape)
]]
				end
			elseif layer.name == "bg_deco_shapes_sky" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					myshape, mytable = nil, nil
					local pixel = Pixel.new(0xffffff, 1, o.width, o.height)
					pixel:setColor(0xffff7f,1, 0x5555ff,1, 3*30) -- 0x5555ff,1, 0xffaa7f,1 -- 0x55aaff,1, 0xffaa7f,1
					pixel:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(pixel)
					-- stars
					local spritestars = Sprite.new() -- a sprite to hold all star shapes
					local starsh = 1.5*o.height/3 -- fill on 2.5/3 part of the sky, you choose!
					for i = 1, o.height//4 do -- @PaulH, 256
						local s = Shape.new()
						s:setLineStyle(2, 0xfdffd2) -- stars color
						s:moveTo(0, 0)
						s:lineTo(1, 1)
						s:endPath()
						s:setPosition(math.random(0, o.width), math.random(0, starsh))
						s:setScale(math.random(5, 15) / 10)
						s:setAlpha(math.random(10, 50) / 50)
						spritestars:addChild(s)
					end
					-- render stars to a render target
					local rtstars = RenderTarget.new(o.width, starsh, nil, { pow2=false })
					rtstars:draw(spritestars)
					-- create an image (Pixel) of the stars
					local bgstars = Pixel.new(rtstars, o.width, starsh)
					bgstars:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(bgstars)
				end
			elseif layer.name == "bg_deco_shapes" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					myshape, mytable = nil, nil
					local color = 0x00aaff -- 0x185a66, math.random(0xffffff)
					mytable = {
						color=color,
					}
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					myshape = self:buildShapes(o, levelsetup)
					myshape:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(myshape)
				end
			elseif layer.name == "bg_deco_shapes02" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					myshape, mytable = nil, nil
					local color = 0x768e7a -- 0x185a66, math.random(0xffffff)
					mytable = {
						color=color,
					}
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					myshape = self:buildShapes(o, levelsetup)
					myshape:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(myshape)
				end
			elseif layer.name == "bg_deco_shapes_shadows" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					myshape, mytable = nil, nil
					local color = 0x191919
					mytable = {
						color=color, alpha=0.8,
					}
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					myshape = self:buildShapes(o, levelsetup)
					myshape:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(myshape)
				end
			elseif layer.name == "fg_deco_texts" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					mytable = {
						color=layer.tintcolor,
					}
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					myshape = self:buildShapes(o, levelsetup)
					myshape:setPosition(o.x, o.y)
					xlayers["fg"]:addChild(myshape)
				end
			elseif layer.name:match("fg_deco_images") then
				for i = 1, #layer.objects do
					if layer.name:match("x$") then
						parseImage(layer.objects[i], xlayers["fg"], 2)
					else
						if g_currlevel == 1 then parseImage(layer.objects[i], xlayers["fg"], 3)
						else parseImage(layer.objects[i], xlayers["fg"], nil)
						end
					end
				end
			elseif layer.name == "fg_deco_shapes" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					myshape, mytable = nil, nil
					local shapelinewidth = nil
					if o.shape == "polyline" then shapelinewidth = 1 end
					local color = math.random(0xffffff)
					mytable = {
						color=color,
						shapelinewidth=shapelinewidth,
					}
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					myshape = self:buildShapes(o, levelsetup)
					myshape:setPosition(o.x, o.y)
					xlayers["fg"]:addChild(myshape)
				end
			--       _               _            _                           
			--      | |             (_)          | |                          
			-- _ __ | |__  _   _ ___ _  ___ ___  | | __ _ _   _  ___ _ __ ___ 
			--| '_ \| '_ \| | | / __| |/ __/ __| | |/ _` | | | |/ _ \ '__/ __|
			--| |_) | | | | |_| \__ \ | (__\__ \ | | (_| | |_| |  __/ |  \__ \
			--| .__/|_| |_|\__, |___/_|\___|___/ |_|\__,_|\__, |\___|_|  |___/
			--| |           __/ |                          __/ |              
			--|_|          |___/                          |___/               
			--                    _     _ 
			--                   | |   | |
			--__      _____  _ __| | __| |
			--\ \ /\ / / _ \| '__| |/ _` |
			-- \ V  V / (_) | |  | | (_| |
			--  \_/\_/ \___/|_|  |_|\__,_|
			elseif layer.name == "physics_exits" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					o.isexit = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_voids" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					o.isvoid = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_invisible_blocks" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					o.isinvisbleblock = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_spikes" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					o.isspike = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name:match("physics_doors") then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local dx, dy, speed, dir, angle
					local vx, vy
					local index
					index = o.name:find("x") -- index x
					dx = tonumber(o.name:sub(index):match("%d+")) -- find xNNN
					index = o.name:find("y") -- index y
					dy = tonumber(o.name:sub(index):match("%d+")) -- find yNNNN
					speed = 20*8 -- magik XXX
					dir = "ru" -- o.name:sub(#o.name-1) -- last two characters
					angle = math.atan2(dy, dx)
					vx, vy = speed*math.cos(angle), speed*math.sin(angle)
					local xid = o.name:sub(1, 7) -- examples: "doorA1", "doorZ1", ...
					local color = 0x272019 -- 0x1b1611, rgb2hex(table.unpack(layer.tintcolor))
					local texpath = "gfx/textures/1K-metal_grid.jpg-diffuse.jpg_0001.png"
					--EDoor:init(xid, xspritelayer, xcolor, xtexpath, xpos, w, h, dx, dy, xdir, xspeed, xlayers["bgfx"])
					local e = EDoor.new(
						xid, xlayers["actors"], color, texpath, opos, o.width, o.height,
						dx, dy, dir, vector(vx, vy), xlayers["bgfx"]
					)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
					e.sprite:setPosition(e.pos + vector(e.collbox.w/2, -e.h/2+e.collbox.h))
					-- some cleaning?
					e = nil
				end
			elseif layer.name == "physics_door_sensors" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local xid = o.name -- examples: "doorA1", "doorZ1", ...
					--EDoorSensor:init(xid, xpos, w, h)
					local e = EDoorSensor.new(xid, opos, o.width, o.height)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
					-- some cleaning?
					e = nil
				end
			elseif layer.name == "physics_springs" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					o.isspring = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_ptmvpfs" then -- passthrough moving platform
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local dx, dy, speed, dir, angle
					local vx, vy
					local index
					index = o.name:find("x") -- index x
					if index then dx = tonumber(o.name:sub(index):match("%d+")) -- find xNNN
					end dx = dx or 0
					index = o.name:find("y") -- index y
					if index then dy = tonumber(o.name:sub(index):match("%d+")) -- find yNNNN
					end dy = dy or 0
					index = o.name:find("s") -- index s
					speed = tonumber(o.name:sub(index):match("%d+")) -- find sNNNN
					dir = o.name:sub(#o.name-1) -- last two characters
					angle = math.atan2(dy, dx)
					vx, vy = speed*math.cos(angle), speed*math.sin(angle)
					--EMvpf:init(xspritelayer, xpos, xcolor, w, h, dx, dy, xdir, xspeed, xlayers["bgfx"], xisptmvpf)
					local color = 0x5500ff
					local e = EMvpf.new(
						xlayers["actors"], opos, color, o.width, o.height,
						dx, dy, dir, vector(vx, vy), xlayers["bgfx"], true
					)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
					-- some cleaning?
					e = nil
				end
			elseif layer.name == "physics_mvpfs" then -- non passthrough moving platform
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local dx, dy, speed, dir, angle
					local vx, vy
					local index
					index = o.name:find("x") -- index x
					if index then dx = tonumber(o.name:sub(index):match("%d+")) -- find xNNN
					end dx = dx or 0
					index = o.name:find("y") -- index y
					if index then dy = tonumber(o.name:sub(index):match("%d+")) -- find yNNNN
					end dy = dy or 0
					index = o.name:find("s") -- index s
					speed = tonumber(o.name:sub(index):match("%d+")) -- find sNNNN
					dir = o.name:sub(#o.name-1) -- last two characters
					angle = math.atan2(dy, dx)
					vx, vy = speed*math.cos(angle), speed*math.sin(angle)
					--EMvpf:init(xspritelayer, xpos, xcolor, w, h, dx, dy, xdir, xspeed, xlayers["bgfx"], xisptmvpf)
					local color = 0x5555ff
					local e = EMvpf.new(
						xlayers["actors"], opos, color, o.width, o.height,
						dx, dy, dir, vector(vx, vy), xlayers["bgfx"]
					)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
					-- some cleaning?
					e = nil
				end
			elseif layer.name == "physics_ladders" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					o.isladder = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_walls" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					o.pos = vector(o.x, o.y)
					o.iswall = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
					local pixel = Pixel.new(0xaa007f, 1, o.width, o.height)
					pixel:setColor(0x55557f)
					pixel:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(pixel)
				end
			elseif layer.name == "physics_steps" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					o.isstep = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_ptpfs02" then -- transparent
				for i = 1, #layer.objects do
					o = layer.objects[i]
					o.pos = vector(o.x, o.y)
					o.isptpf = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
				end
			elseif layer.name == "physics_ptpfs" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					o.pos = vector(o.x, o.y)
					o.isptpf = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
					local tex = "gfx/textures/roadCurve_0002.png"
					mytable = {
						texpath=tex, istexpot=true, scalex=1,
						r=5*32/255, g=5*32/255, b=7*32/255,
						alpha=8*32/255,
					}
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					myshape = self:buildShapes(o, levelsetup)
					myshape:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(myshape)
				end
			elseif layer.name == "physics_grounds02" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					o.isfloor = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
					local color = 0x1b1611 -- 0x373737, math.random(0xffffff)
					mytable = {
						color=color, alpha=1,
					}
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					myshape = self:buildShapes(o, levelsetup)
					myshape:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(myshape)
				end
			elseif layer.name == "physics_grounds" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					o.isfloor = true
					xbworld:add(o, o.x, o.y, o.width, o.height)
					local tex = "gfx/textures/wdipagu_2K_Albedo.jpg_0007.png"
					local color = 0x1b1611 -- 0x373737, math.random(0xffffff)
					if o.name == "a" then
						tex = "gfx/textures/roadCurve_0002.png"
						mytable = {
							texpath=tex, istexpot=true, scalex=1,
							r=5.5*32/255, g=5.5*32/255, b=4.5*32/255,
							alpha=8*32/255,
						}
					elseif o.name == "t" then -- transparent
						tex = nil
						mytable = {
							color=color,
							alpha=0,
						}
					else
						mytable = {
							texpath=tex, istexpot=true, scalex=1.4,
							r=8*32/255, g=8*32/255, b=5.5*32/255,
							alpha=8*32/255,
						}
					end
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					myshape = self:buildShapes(o, levelsetup)
					myshape:setPosition(o.x, o.y)
					xlayers["bg"]:addChild(myshape)
				end
			--           _ _           _   _ _     _           
			--          | | |         | | (_) |   | |          
			--  ___ ___ | | | ___  ___| |_ _| |__ | | ___  ___ 
			-- / __/ _ \| | |/ _ \/ __| __| | '_ \| |/ _ \/ __|
			--| (_| (_) | | |  __/ (__| |_| | |_) | |  __/\__ \
			-- \___\___/|_|_|\___|\___|\__|_|_.__/|_|\___||___/
			elseif layer.name == "physics_keys" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local xid = o.name
					--ECollectibles:init(xid, xspritelayer, xpos, xspeed, xdx, xdy)
					local e = ECollectibles.new(xid, xlayers["actors"], opos, 1*8, 5*8, 4*8)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_lives" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local xid = layer.name:gsub("physics_", "")
					--ECollectibles:init(xid, xspritelayer, xpos, xspeed, xdx, xdy)
					local e = ECollectibles.new(xid, xlayers["actors"], opos, 1*8, 5*8, 4*8)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_coins" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local xid = layer.name:gsub("physics_", "")
					--ECollectibles:init(xid, xspritelayer, xpos, xspeed, xdx, xdy)
					local e = ECollectibles.new(xid, xlayers["actors"], opos, 1*8, 4*8, 4*8)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			--            _                 
			--           | |                
			--  __ _  ___| |_ ___  _ __ ___ 
			-- / _` |/ __| __/ _ \| '__/ __|
			--| (_| | (__| || (_) | |  \__ \
			-- \__,_|\___|\__\___/|_|  |___/
			elseif layer.name == "physics_breakables" then
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					--EDestructibleObject:init(xspritelayer, xpos)
					local e = EDestructibleObject.new(xlayers["actors"], opos)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_turret_nmesx" then -- nmes
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					--ENme1:init(xid, xspritelayer, xpos, dx, dy, xlayers["bgfx"])
					local e = ENme1.new("fixed", xlayers["actors"], opos, 0*8, 0*8, xlayers["bgfx"])
					e.dir = o.name -- u, d, l, r, TODO ul, ur, dl, dr (diagonals)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_flying_nmesx" then -- nmes
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local collectible = o.name
					if collectible == "" then collectible = "coins" -- default to coins
					elseif collectible == "x" then collectible = nil
					end
					--ENme1:init(xid, xspritelayer, xpos, dx, dy, xlayers, xcollectible))
					local e = ENme1.new("flying", xlayers["actors"], opos, 16*8, 32*8, xlayers["bgfx"], collectible)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_ground_boss1" then -- nmes boss1
				-- 400: shoot all angles
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local collectible = o.name
					if collectible == "" then collectible = "coins" -- default to coins
					elseif collectible == "x" then collectible = nil
					end
					--ENme1:init(xid, xspritelayer, xpos, dx, dy, xlayers, xcollectible)
					local e = ENme1.new(1000, xlayers["actors"], opos, 0*8, 0*8, xlayers["bgfx"], collectible)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_ground_nmes04" then -- nmes
				-- 400: move, jump, shoot straight
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local collectible = o.name
					if collectible == "" then collectible = "coins" -- default to coins
					elseif collectible == "x" then collectible = nil
					end
					--ENme1:init(xid, xspritelayer, xpos, dx, dy, xlayers, xcollectible)
					local e = ENme1.new(400, xlayers["actors"], opos, 0*8, 0*8, xlayers["bgfx"], collectible)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_ground_nmes03" then -- nmes
				-- 300: no move, no jump, shoot all angles
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local collectible = o.name
					if collectible == "" then collectible = "coins" -- default to coins
					elseif collectible == "x" then collectible = nil
					end
					--ENme1:init(xid, xspritelayer, xpos, dx, dy, xlayers, xcollectible)
					local e = ENme1.new(300, xlayers["actors"], opos, 0*8, 0*8, xlayers["bgfx"], collectible)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_ground_nmes02" then -- nmes
				-- 200: move, jump, no shoot
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local collectible = o.name
					if collectible == "" then collectible = "coins" -- default to coins
					elseif collectible == "x" then collectible = nil
					end
					--ENme1:init(xid, xspritelayer, xpos, dx, dy, xlayers, xcollectible)
					local e = ENme1.new(200, xlayers["actors"], opos, 16*8, 32*8, xlayers["bgfx"], collectible)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_ground_nmes" then
				-- 100: no move, no jump, shoot straight
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					local collectible = o.name
					if collectible == "" then collectible = nil -- default to coins
					elseif collectible == "x" then collectible = nil
					end
					--ENme1:init(xid, xspritelayer, xpos, dx, dy, xlayers, xcollectible)
					local e = ENme1.new(100, xlayers["actors"], opos, 0*8, 0*8, xlayers["bgfx"], collectible)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_npcs" then -- npcs
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					--ENme1:init(xid, xspritelayer, xpos, dx, dy, xlayers, xcollectible)
					local e = ENpc1.new(100, xlayers["actors"], opos, 0*8, 0*8, xlayers["bgfx"], nil)
					xtiny.tworld:addEntity(e)
					xbworld:add(e, e.pos.x, e.pos.y, e.collbox.w, e.collbox.h)
				end
			elseif layer.name == "physics_players" then -- player1
				for i = 1, #layer.objects do
					o = layer.objects[i]
					local opos = vector(o.x, o.y)
					-- EPlayer1:init(xspritelayer, xpos, xbgfxlayer)
					self.player1 = EPlayer1.new(xlayers["actors"], opos, xlayers["bgfx"])
					xtiny.tworld:addEntity(self.player1)
					xbworld:add(
						self.player1,
						self.player1.pos.x, self.player1.pos.y,
						self.player1.collbox.w, self.player1.collbox.h
					)
				end
			end
			-- some cleaning?
			o = nil
			myshape, mytable = nil, nil
			levelsetup = {}
		end
	end
end

function TiledLevels:buildShapes(xobject, xlevelsetup)
	local myshape -- Tiled shapes: ellipse, point, polygon, polyline, rectangle, text
	local tablebase = {}
	if xobject.shape == "ellipse" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			w=xobject.width, h=xobject.height,
			rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Ellipse.new(tablebase)
	elseif xobject.shape == "point" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Point.new(tablebase)
	elseif xobject.shape == "polygon" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			coords=xobject.polygon,
			rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Polygon.new(tablebase)
	elseif xobject.shape == "polyline" then -- lines
		tablebase = {
			x=xobject.x, y=xobject.y,
			coords=xobject.polyline,
			rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Polyline.new(tablebase)
	elseif xobject.shape == "rectangle" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			w=xobject.width, h=xobject.height,
			rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Rectangle.new(tablebase)
	elseif xobject.shape == "text" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			text=xobject.text,
			w=xobject.width, h=xobject.height,
			rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Tiled_Shape_Text.new(tablebase)
	else
		print("*** CANNOT PROCESS THIS SHAPE! ***", xobject.shape, xobject.name)
		return
	end

	return myshape
end
