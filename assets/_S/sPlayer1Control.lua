SPlayer1Control = Core.class()

function SPlayer1Control:init(xtiny, xplayer1inputlayer) -- tiny function
	xtiny.system(self) -- called only once on init (no update)
	self.player1inputlayer = xplayer1inputlayer
end

function SPlayer1Control:filter(ent) -- tiny function
	return ent.isplayer1
end

function SPlayer1Control:onAdd(ent) -- tiny function
	-- some functions
	local function lerp(a,b,t) return a + (b-a) * t end
	-- listeners
	self.player1inputlayer:addEventListener(Event.KEY_DOWN, function(e)
		if ent.currlives > 0 then
			if e.keyCode == KeyCode.LEFT or e.keyCode == g_keyleft then -- left
				ent.isleft = true
			elseif e.keyCode == KeyCode.RIGHT or e.keyCode == g_keyright then -- right
				ent.isright = true
			end
			if e.keyCode == KeyCode.UP or e.keyCode == g_keyup then -- up
				ent.isup = true
				ent.wasup = false -- allows initial jump, XXX 20250308
				ent.body.currinputbuffer = ent.body.inputbuffer
			elseif e.keyCode == KeyCode.DOWN or e.keyCode == g_keydown then -- down
				ent.isdown = true
			end
			-- ACTIONS:
			if e.keyCode == g_keyaction1 then -- shoot
				if ent.shield.currtimer <= 0 then -- new 20250404 XXX
					ent.isaction1 = true
				end
			elseif e.keyCode == g_keyaction2 then -- shield
				ent.isaction2 = true
			elseif e.keyCode == g_keyaction3 then -- dash
				if ent.body.currdashcooldown <= 0 then
					ent.isaction3 = true
				end
			end
		end
	end)
	self.player1inputlayer:addEventListener(Event.KEY_UP, function(e)
		if ent.currlives > 0 then
			if e.keyCode == KeyCode.LEFT or e.keyCode == g_keyleft then -- left
				ent.isleft = false
			end
			if e.keyCode == KeyCode.RIGHT or e.keyCode == g_keyright then -- right
				ent.isright = false
			end
			if e.keyCode == KeyCode.UP or e.keyCode == g_keyup then -- up
				ent.isup = false
				ent.wasup = false -- prevent constant jumps
				if ent.body.vy < ent.body.upspeed/2 then
--					ent.body.vy = ent.body.upspeed/2
--					ent.body.vy = lerp(ent.body.vy, ent.body.upspeed/2, 0.5)
					ent.body.vy = lerp(ent.body.vy, ent.body.upspeed/1.2, 0.25)
				end
			end
			if e.keyCode == KeyCode.DOWN or e.keyCode == g_keydown then -- down
				ent.isdown = false
				ent.wasdown = false -- prevent constant going down ptpf
			end
			if e.keyCode == g_keyaction1 then ent.isaction1 = false end
			if e.keyCode == g_keyaction2 then ent.isaction2 = false end
			if e.keyCode == g_keyaction3 then ent.isaction3 = false end
		end
	end)
end
