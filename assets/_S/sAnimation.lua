SAnimation = Core.class()

function SAnimation:init(xtiny)
	xtiny.processingSystem(self) -- called once on init and every frames
	self.sndstepgrass = Sound.new("audio/sfx/footstep/Grass02.wav")
	self.channel = self.sndstepgrass:play(0, false, true)
end

function SAnimation:filter(ent) -- tiny function
	return ent.animation
end

function SAnimation:onAdd(ent) -- tiny function
end

function SAnimation:onRemove(ent) -- tiny function
	ent.animation = nil -- free some memory?
end

local checkanim
--@native
function SAnimation:process(ent, dt) -- tiny function
	-- a little boost?
	local anim = ent.animation

--	checkanim = anim.curranim -- if you are sure all animations are set else use below ternary operator code
	-- luau ternary operator (no end at the end), it's a 1 liner and seems fast?
	checkanim = if anim.anims[anim.curranim] then anim.curranim else g_ANIM_DEFAULT
--	print("checkanim", checkanim)
--	print("#anim.anims[checkanim]", #anim.anims[checkanim])

	if not ent.doanimate then return end

	anim.animtimer -= dt
	if anim.animtimer < 0 then
		anim.frame += 1
		anim.animtimer = anim.animspeed
		if checkanim == g_ANIM_DEFAULT then
			if anim.frame > #anim.anims[checkanim] then
				anim.frame = 1
			end
		elseif checkanim == g_ANIM_LOSE1_R or checkanim == g_ANIM_STANDUP_R then
			if anim.frame >= #anim.anims[checkanim] then
				anim.frame = #anim.anims[checkanim]
			end
		elseif checkanim == g_ANIM_JUMPUP_R then
			anim.frame = 1
--			ent.poffset = vector(3*8*ent.flip, -0.9*8)
			ent.poffset = vector(ent.collbox.w*0.5+4.5*8*ent.flip, 0.4*8)
		elseif checkanim == g_ANIM_JUMPDOWN_R then
			anim.frame = 1
--			ent.poffset = vector(3*8*ent.flip, -0.9*8)
			ent.poffset = vector(ent.collbox.w*0.5+4.5*8*ent.flip, 1.4*8)
		elseif checkanim == g_ANIM_KICK_ATTACK1_R then
			ent.spinehitbox = ent.spinehitboxattack1
			if #anim.anims[checkanim] == 1 then -- 1 frame animation
				anim.frame = 1
				ent.spinehitboxattack1.isactive = true
				ent.isaction2 = false
			else -- multi frames animation
				if anim.frame > #anim.anims[checkanim] then
--					anim.frame = 1
					anim.frame = #anim.anims[checkanim]
					ent.spinehitboxattack1.isactive = false
					ent.isaction2 = false
				end
			end
		elseif checkanim == g_ANIM_KICK_ATTACK2_R then
			ent.spinehitbox = ent.spinehitboxattack2
			if anim.frame > #anim.anims[checkanim] then
--				anim.frame = 1
				anim.frame = #anim.anims[checkanim]
				ent.spinehitboxattack2.isactive = false
				ent.isactionkick2 = false
			end
		elseif checkanim == g_ANIM_JUMPUP_Rx then -- only jump, no attacks
			if anim.frame > #anim.anims[checkanim] then
				anim.frame = #anim.anims[checkanim]
			end
		else -- any looping animation
			-- player1 steps sound fx
			if ent.isplayer1 then
--				ent.poffset = vector(3*8*ent.flip, -0.4*8)
				ent.poffset = vector(ent.collbox.w*0.5+4.5*8*ent.flip, 1.4*8)
				if (anim.curranim == g_ANIM_WALK_R or anim.curranim == g_ANIM_RUN_R) and
					(anim.frame == 4 or anim.frame == 9) then
					self.channel = self.sndstepgrass:play()
					if self.channel then self.channel:setVolume(g_sfxvolume*0.01) end
				end
			end
			-- loop animations
			if anim.frame > #anim.anims[checkanim] then
				anim.frame = 1
			end
		end
		anim.bmp:setTextureRegion(anim.anims[checkanim][anim.frame])
	end
end
