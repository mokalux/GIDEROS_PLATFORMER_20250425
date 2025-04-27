--!NEEDS:luashader/luashader.lua

local function makeEffect(name,vshader,fshader)
	local s=Shader.lua(vshader,fshader,0,
	{
	{name="vMatrix",type=Shader.CMATRIX,sys=Shader.SYS_WVP,vertex=true},
	{name="fColor",type=Shader.CFLOAT4,sys=Shader.SYS_COLOR,vertex=false},
	{name="fTexture",type=Shader.CTEXTURE,vertex=false},
	{name="fTextureInfo",type=Shader.CFLOAT4,sys=Shader.SYS_TEXTUREINFO,vertex=false},
	{name="fTime",type=Shader.CFLOAT,sys=Shader.SYS_TIMER,vertex=false},
	},
	{
	{name="vVertex",type=Shader.DFLOAT,mult=2,slot=0,offset=0},
	{name="vColor",type=Shader.DUBYTE,mult=4,slot=1,offset=0},
	{name="vTexCoord",type=Shader.DFLOAT,mult=2,slot=2,offset=0},
	},
	{
	{name="fTexCoord",type=Shader.CFLOAT2},
	}
	)
	s.name=name
	return s
end

Effect={}

Effect.none=makeEffect("None",
	function (vVertex,vColor,vTexCoord) : Shader
		local vertex = hF4(vVertex,0.0,1.0)
		fTexCoord=vTexCoord
		return vMatrix*vertex
	end,
	function () : Shader
	 local frag=lF4(fColor)*texture2D(fTexture, fTexCoord)
	 if (frag.a==0.0) then discard() end
	 return frag
	end)	
	
--[[
Effect.blur=makeEffect("Blur",
	function (vVertex,vColor,vTexCoord) : Shader
		local vertex = hF4(vVertex,0.0,1.0)
		fTexCoord=vTexCoord
		return vMatrix*vertex
	end,
	function () : Shader
	 local frag=lF4(0.0,0.0,0.0,0.0)
--	 local frad=floor((1+sin(fTime))*4)%9 --For the demo use time for rad
	 local frad = 3.0 -- 0.7
--	 local ext=2*frad+1
	 local ext = 1*frad+8
--	 local tc=fTexCoord-fTextureInfo.zw*frad
	 local tc=fTexCoord-fTextureInfo.zw*frad
--	 for v=0,19 do
	 for v = 0, 32 do
		if v<ext then
			frag=frag+lF4(fColor)*texture2D(fTexture, tc)
		end
		tc+=fTextureInfo.zw
	 end
	 frag=frag/ext
	 if (frag.a==0.0) then discard() end
	 return frag
	end)
]]

Effect.grayscale=makeEffect("Grayscale",
	function (vVertex,vColor,vTexCoord) : Shader
		local vertex = hF4(vVertex,0.0,1.0)
		fTexCoord=vTexCoord
		return vMatrix*vertex
	end,
	function () : Shader
	 local frag=lF4(fColor)*texture2D(fTexture, fTexCoord)
--	 local coef=lF3(0.2125, 0.7154, 0.0721)
	 local coef=lF3(0.9, 0.1, 0.1)
	 local gray=dot(frag.rgb,coef)
--	 frag.rgb=lF3(gray,gray,gray)
	 frag.rgb=lF3(2*32/255, gray, gray)
	 if (frag.a==0.0) then discard() end
	 return frag
	end)
Effect.saturate=makeEffect("Saturate",
	function (vVertex,vColor,vTexCoord) : Shader
		local vertex = hF4(vVertex,0.0,1.0)
		fTexCoord=vTexCoord
		return vMatrix*vertex
	end,
	function () : Shader
--	 local frad=(1+sin(fTime))*0.5
	 local frad = -0.2 -- 0.1
	 local frag=lF4(fColor)*texture2D(fTexture, fTexCoord)
	 local coef=lF3(0.2125, 0.7154, 0.0721)
	 local dp=dot(frag.rgb,coef)
	 frag.rgb=mix(frag.rgb,frag.rgb/dp,frad)
	 if (frag.a==0.0) then discard() end
	 return frag
	end)

--[[
Effect.emphasize=makeEffect("Emphasize",
	function (vVertex,vColor,vTexCoord) : Shader
		local vertex = hF4(vVertex,0.0,1.0)
		fTexCoord=vTexCoord
		return vMatrix*vertex
	end,
	function () : Shader
	 local frag=lF4(fColor)*texture2D(fTexture, fTexCoord)
	 local e=lF1(2+sin(fTime))
	 frag.rgb=lF3(frag.r^e,frag.g^e,frag.b^e)
	 if (frag.a==0.0) then discard() end
	 return frag
	end)
]]
Effect.emphasize = makeEffect("emphasize",
	function (vVertex, vColor, vTexCoord) : Shader
		local vertex = hF4(vVertex, 0.0, 1.0)
		fTexCoord = vTexCoord
		return vMatrix * vertex
	end,
	function () : Shader
		local frag = lF4(fColor) * texture2D(fTexture, fTexCoord)
		local e = 0.6 -- xemphasize is a shader constant!, xemphasize, 1.15, 2, 3
		frag.rgb = lF3(frag.r^e, frag.g^e, frag.b^e)
		if (frag.a == 0.0) then discard() end
		return frag
	end)
Effect.emphasize_actor = makeEffect("emphasize",
	function (vVertex, vColor, vTexCoord) : Shader
		local vertex = hF4(vVertex, 0.0, 1.0)
		fTexCoord = vTexCoord
		return vMatrix * vertex
	end,
	function () : Shader
		local frag = lF4(fColor) * texture2D(fTexture, fTexCoord)
		local e = 0.7 -- xemphasize is a shader constant!, xemphasize, 1.15, 2, 3
		frag.rgb = lF3(frag.r^e, frag.g^e, frag.b^e)
		if (frag.a == 0.0) then discard() end
		return frag
	end)

Effect.waves=makeEffect("Waves",
	function (vVertex,vColor,vTexCoord) : Shader
		local vertex = hF4(vVertex,0.0,1.0)
		fTexCoord=vTexCoord
		return vMatrix*vertex
	end,
	function () : Shader
		local tc=hF2(fTexCoord.x+(1+sin(fTexCoord.x*10+fTime*2))*0.05,fTexCoord.y)*0.9
--		local tc=hF2(fTexCoord.x+(1+sin(fTexCoord.x*10+2))*0.5,fTexCoord.y)--*0.9
		local frag=lF4(fColor)*texture2D(fTexture, tc)
		if (frag.a==0.0) then discard() end
		return frag
	end)

--[[
Effect.bloom=makeEffect("Bloom",
	function (vVertex,vColor,vTexCoord) : Shader
		local vertex = hF4(vVertex,0.0,1.0)
		fTexCoord=vTexCoord
		return vMatrix*vertex
	end,
	function () : Shader
	 local frag=lF4(0.0,0.0,0.0,0.0)
--	 local amount=0.5*(1+sin(fTime))
	 local amount=0.12499
--	 local frad=floor(amount*8)%9 --For the demo use time for rad
	 local frad=0.4 --For the demo use time for rad
--	 local ext=2*frad+1
	 local ext=2*frad+1.25
	 local tc=fTexCoord-fTextureInfo.zw*frad
--	 for v=0,19 do
	 for v = 0, 4 do
		if v<ext then
			frag=frag+lF4(fColor)*texture2D(fTexture, tc)
		end
		tc+=fTextureInfo.zw
	 end
	 frag=frag/ext
	 
	 local bfrag=lF4(fColor)*texture2D(fTexture, fTexCoord)
 	 local coef=lF3(0.2125, 0.7154, 0.0721)
	 local dp=dot(bfrag.rgb,coef)
--	 if dp<0.5 then bfrag.rgb=lF3(0,0,0) end
	 if dp<0.5 then bfrag.rgb=lF3(0.0,0.0,0.0) end
	 frag.rgb=frag.rgb+bfrag.rgb*amount	

	 if (frag.a==0.0) then discard() end
	 return frag
	end)
]]
--  _____  ____  _____   ____ _______ 
-- / ____|/ __ \|  __ \ / __ \__   __|
--| |  __| |  | | |  | | |  | | | |   
--| | |_ | |  | | |  | | |  | | | |   
--| |__| | |__| | |__| | |__| | | |   
-- \_____|\____/|_____/ \____/  |_|   
-- _____        _      ______ _______ _______ ______ 
--|  __ \ /\   | |    |  ____|__   __|__   __|  ____|
--| |__) /  \  | |    | |__     | |     | |  | |__   
--|  ___/ /\ \ | |    |  __|    | |     | |  |  __|  
--| |  / ____ \| |____| |____   | |     | |  | |____ 
--|_| /_/    \_\______|______|  |_|     |_|  |______|
-- cc0 @ https://godotshaders.com/shader/256-colour-pixelation/
Effect.palette = makeEffect("palette",
	function (vVertex, vColor, vTexCoord) : Shader
		local vertex = hF4(vVertex, 0.0, 1.0)
		fTexCoord = vTexCoord
		return vMatrix * vertex
	end,
	function () : Shader
		-- 0.100392156862 is the cube root of 255
		local rgb255 = lF3(0.100392156862, 0.100392156862, 0.100392156862)
		local tc = fTexCoord - fTextureInfo.zw
		local frag = lF4(fColor) * texture2D(fTexture, tc)
		if(frag.r < 1.0 and frag.g < 1.0 and frag.b < 1.0) then
			local remainder = mod(frag.rgb, rgb255)
			frag.rgb = frag.rgb - remainder
		end
		-- emphasize
		local e = 1.5 -- xemphasize
		frag.rgb = lF3(frag.r^e, frag.g^e, frag.b^e)
		if (frag.a == 0.0) then discard() end
		return frag
	end)
Effect.palette_actor = makeEffect("palette",
	function (vVertex, vColor, vTexCoord) : Shader
		local vertex = hF4(vVertex, 0.0, 1.0)
		fTexCoord = vTexCoord
		return vMatrix * vertex
	end,
	function () : Shader
		-- 0.100392156862 is the cube root of 255
		local rgb255 = lF3(0.100392156862, 0.100392156862, 0.100392156862)
		local tc = fTexCoord - fTextureInfo.zw
		local frag = lF4(fColor) * texture2D(fTexture, tc)
		if(frag.r < 1.0 and frag.g < 1.0 and frag.b < 1.0) then
			local remainder = mod(frag.rgb, rgb255)
			frag.rgb = frag.rgb - remainder
		end
		-- emphasize
		local e = 0.2 -- xemphasize
		frag.rgb = lF3(frag.r^e, frag.g^e, frag.b^e)
		if (frag.a == 0.0) then discard() end
		return frag
	end)
-- _____ _______   ________ _            _______ _____ ____  _   _ 
--|  __ \_   _\ \ / /  ____| |        /\|__   __|_   _/ __ \| \ | |
--| |__) || |  \ V /| |__  | |       /  \  | |    | || |  | |  \| |
--|  ___/ | |   > < |  __| | |      / /\ \ | |    | || |  | | . ` |
--| |    _| |_ / . \| |____| |____ / ____ \| |   _| || |__| | |\  |
--|_|   |_____/_/ \_\______|______/_/    \_\_|  |_____\____/|_| \_|
Effect.colour_pixelation = makeEffect("colour_pixelation",
	function (vVertex, vColor, vTexCoord) : Shader
		local vertex = hF4(vVertex, 0.0, 1.0)
		fTexCoord = vTexCoord
		return vMatrix * vertex
	end,
	function () : Shader
		local resX = 16*16 -- 8*32, max=16*32
		local resY = 16*16 -- 8*32
		-- 0.100392156862 is the cube root of 255
		local rgb255 = lF3(0.100392156862, 0.100392156862, 0.100392156862)
		local uvX = fTexCoord.x - mod(fTexCoord.x * resX, 1) / resX
		local uvY = fTexCoord.y - mod(fTexCoord.y * resY, 1) / resY
		local grid_uv = lF2(uvX, uvY)
		local frag = lF4(fColor) * texture2D(fTexture, grid_uv)
		if(frag.r < 1.0 and frag.g < 1.0 and frag.b < 1.0) then
			local remainder = mod(frag.rgb, rgb255)
			frag.rgb = frag.rgb - remainder
		end
		-- emphasize
--		local e = 1 -- xemphasize, 0.8, 1
--		frag.rgb = lF3(frag.r^e, frag.g^e, frag.b^e)
--		if (frag.a == 0.0) then discard() end

		return frag
	end)
Effect.colour_pixelation2 = makeEffect("colour_pixelation",
	function (vVertex, vColor, vTexCoord) : Shader
		local vertex = hF4(vVertex, 0.0, 1.0)
		fTexCoord = vTexCoord
		return vMatrix * vertex
	end,
	function () : Shader
		local resX = 16*16 -- 8*32, 32*6, 32*12, max=32*16, 32*8, 4, 32
		local resY = 16*16 -- 8*32, 32*6, 32*8, 32*12, 32*8, 4, 32
		-- 0.100392156862 is the cube root of 255
		local rgb255 = lF3(0.100392156862, 0.100392156862, 0.100392156862)
		local uvX = fTexCoord.x - mod(fTexCoord.x * resX, 1) / resX
		local uvY = fTexCoord.y - mod(fTexCoord.y * resY, 1) / resY
		local grid_uv = lF2(uvX, uvY)
		local frag = lF4(fColor) * texture2D(fTexture, grid_uv)
--		if(frag.r < 1.0 and frag.g < 1.0 and frag.b < 1.0) then
--			local remainder = mod(frag.rgb, rgb255)
--			frag.rgb = frag.rgb - remainder
--		end
		-- emphasize
--		local e = 0.7 -- xemphasize, 0.8, 1
--		frag.rgb = lF3(frag.r^e, frag.g^e, frag.b^e)
--		if (frag.a == 0.0) then discard() end

		return frag
	end)
Effect.colour_pixelation_actor = makeEffect("colour_pixelation",
	function (vVertex, vColor, vTexCoord) : Shader
		local vertex = hF4(vVertex, 0.0, 1.0)
		fTexCoord = vTexCoord
		return vMatrix * vertex
	end,
	function () : Shader
		local resX = 32*12 -- 32*12, max=32*16, 32*8, 4, 32
		local resY = 32*12 -- 32*8, 32*12, 32*8, 4, 32
		-- 0.100392156862 is the cube root of 255
		local rgb255 = lF3(0.100392156862, 0.100392156862, 0.100392156862)
		local uvX = fTexCoord.x - mod(fTexCoord.x * resX, 1) / resX
		local uvY = fTexCoord.y - mod(fTexCoord.y * resY, 1) / resY
		local grid_uv = lF2(uvX, uvY)
		local frag = lF4(fColor) * texture2D(fTexture, grid_uv)
		if(frag.r < 1.0 and frag.g < 1.0 and frag.b < 1.0) then
			local remainder = mod(frag.rgb, rgb255)
			frag.rgb = frag.rgb - remainder
		end
		-- emphasize
--		local e = 1 -- xemphasize
--		frag.rgb = lF3(frag.r^e, frag.g^e, frag.b^e)
--		if (frag.a == 0.0) then discard() end

		return frag
	end)
--  _____ ____  _      ____  _    _ _____    _____ _______   ________ _             _______ _____ ____  _   _ __ 
-- / ____/ __ \| |    / __ \| |  | |  __ \  |  __ \_   _\ \ / /  ____| |         /\|__   __|_   _/ __ \| \ | /_ |
--| |   | |  | | |   | |  | | |  | | |__) | | |__) || |  \ V /| |__  | |        /  \  | |    | || |  | |  \| || |
--| |   | |  | | |   | |  | | |  | |  _  /  |  ___/ | |   > < |  __| | |       / /\ \ | |    | || |  | | . ` || |
--| |___| |__| | |___| |__| | |__| | | \ \  | |    _| |_ / . \| |____| |____  / ____ \| |   _| || |__| | |\  || |
-- \_____\____/|______\____/ \____/|_|  \_\ |_|   |_____/_/ \_\______|______|/_/    \_\_|  |_____\____/|_| \_||_|
--                                      ______                               
--                                     |______|                              
Effect.colour_pixelation1 = makeEffect("colour_pixelation1",
	function (vVertex, vColor, vTexCoord) : Shader
		local vertex = hF4(vVertex, 0.0, 1.0)
		fTexCoord = vTexCoord
		return vMatrix * vertex
	end,
	function () : Shader
		local resX = 64.0 -- 32
		local resY = 64.0 -- 32
		-- 0.100392156862 is the cube root of 255
		local rgb255 = lF3(0.100392156862, 0.100392156862, 0.100392156862)
		local uvX = fTexCoord.x - mod(fTexCoord.x * resX, 1) / resX
		local uvY = fTexCoord.y - mod(fTexCoord.y * resY, 1) / resY
		local grid_uv = lF2(uvX, uvY)
		local frag = lF4(fColor) * texture2D(fTexture, grid_uv)
		if(frag.r < 1.0 and frag.g < 1.0 and frag.b < 1.0) then
			local remainder = mod(frag.rgb, rgb255)
			frag.rgb = frag.rgb - remainder
		end
		-- emphasize
		local e = 1 -- xemphasize
		frag.rgb = lF3(frag.r^e, frag.g^e, frag.b^e)
		if (frag.a == 0.0) then discard() end

		return frag
	end)

-- @rrraptor V1 -- thick pixel colored outline
Effect.outline3 = makeEffect("outline3",
	function (vVertex, vColor, vTexCoord) : Shader
		local vertex = hF4(vVertex, 0.0, 1.0)
		fTexCoord = vTexCoord
		return vMatrix * vertex
	end,
	function () : Shader
		local outlinesize = 1.0 -- 1.0, 2.0
		local tc = fTexCoord - fTextureInfo.zw
		local original = lF4(fColor) * texture2D(fTexture, tc)
		if original.a == 0.0 then
--			local step = 1.57079632679 -- math.pi/2 -- perfect for 1 to 2 pixels outline
--			for theta = 0, 6.28318530718, step do -- 2 PI
--				local offset = lF2(fTextureInfo.z * cos(theta) * outlinesize, fTextureInfo.w * sin(theta) * outlinesize)
--				local frag = lF4(fColor) * texture2D(fTexture, tc+offset)
--				if not (frag.a == 0.0) then original = lF4(1.0, 1.0, 1.0, frag.a) end -- change outline color here
--			end
			local step = 1.57079632679 -- math.pi/2 -- perfect for 1 to 2 pixels outline
			for theta = 0, 6.28318530718, step do -- 2 PI
				local offset = lF2(fTextureInfo.z * cos(theta) * outlinesize, fTextureInfo.w * sin(theta) * outlinesize)
				local frag = lF4(fColor) * texture2D(fTexture, tc+offset)
				if not (frag.a == 0.0) then original = lF4(1.0, 1.0, 0.5, frag.a) end -- change outline color here
			end
		end
		-- emphasize
		local e = 1 -- xemphasize
		original.rgb = lF3(original.r^e, original.g^e, original.b^e)
		if (original.a == 0.0) then discard() end

		return original
	end)
