//happy hour stuff

rawset(_G,"HAPPY_HOUR",{
	happyhour = false,
	timelimit = 0,
	timeleft = 0,
	time = 0,
	othergt = false,
})
local hh = HAPPY_HOUR

rawset(_G,"HH_Trigger",function(timelimit)
	if hh.happyhour == true
		return
	end
	
	if timelimit ~= nil
		hh.timelimit = timelimit
	end
	hh.happyhour = true
	for p in players.iterate
		ChangeTakisMusic("HAPYHR",p)
	end
end)
rawset(_G,"HH_Reset",function()
	hh.happyhour = false
	hh.timelimit = 0
	hh.timeleft = 0
	hh.time = 0
end)

addHook("ThinkFrame",do
	hh.othergt = false 
	if (gamestate == GS_LEVEL)
		if (leveltime < 3)
			return
		end
		
		//cool
		if (gametype == GT_PIZZATIMEJISK)
			hh.happyhour = PTJE.pizzatime
			hh.timelimit = CV_PTJE.timelimit.value*TICRATE*60 or 0
			hh.timeleft = PTJE.timeleft
			hh.time = PTJE.pizzatime_tics
			hh.othergt = true
		end
		
		if hh.happyhour
			
			if (hh.timelimit)
				hh.timeleft = hh.timelimit-hh.time
				if hh.timeleft == 0
					return
				end
			end
			
			hh.time = $+1
		else
			hh.timelimit = 0
			hh.timeleft = 0
			hh.time = 0
		end
	else
		if hh.happyhour
			hh.timelimit = 0
			hh.timeleft = 0
			hh.time = 0
			hh.happyhour = false
		end
	end
end)

freeslot("SPR_HHT_")
freeslot("S_HHTRIGGER_IDLE")
freeslot("S_HHTRIGGER_PRESSED")
freeslot("S_HHTRIGGER_ACTIVE")
freeslot("MT_HHTRIGGER")
sfxinfo[freeslot("sfx_hhtsnd")].caption = "/"

states[S_HHTRIGGER_IDLE] = {
	sprite = SPR_HHT_,
	frame = A,
	tics = -1
}
states[S_HHTRIGGER_PRESSED] = {
	sprite = SPR_HHT_,
	frame = B,
	tics = 5,
	nextstate = S_HHTRIGGER_ACTIVE
}
states[S_HHTRIGGER_ACTIVE] = {
	sprite = SPR_HHT_,
	frame = C,
	tics = -1,
}

mobjinfo[MT_HHTRIGGER] = {
	doomednum = 3000,
	spawnstate = S_HHTRIGGER_IDLE,
	spawnhealth = 1,
	deathstate = S_HHTRIGGER_PRESSED,
	deathsound = sfx_mclang,
	height = 70*FU,
	radius = 35*FU,
	flags = MF_SOLID,
}

addHook("MobjSpawn",function(mo)
	mo.spritexscale,mo.spriteyscale = 2*FU,2*FU
end,MT_HHTRIGGER)

addHook("MobjThinker",function(trig)
	if not trig
	or not trig.valid
		return
	end
	
	trig.spritexscaleadd = $ or 0
	trig.spriteyscaleadd = $ or 0
	
	if trig.state == S_HHTRIGGER_ACTIVE
		if not S_SoundPlaying(trig,sfx_hhtsnd)
			S_StartSound(trig,sfx_hhtsnd)
		end
	end
	
	trig.spritexscale = 2*FU+trig.spritexscaleadd
	trig.spriteyscale = 2*FU+trig.spriteyscaleadd
	if trig.spritexscaleadd ~= 0
		trig.spritexscaleadd = 4*$/5
	end
	if trig.spriteyscaleadd ~= 0
		trig.spriteyscaleadd = 4*$/5
	end
	
end,MT_HHTRIGGER)

addHook("MobjCollide",function(trig,mo)
	if not mo
	or not mo.valid
		return
	end
	
	if HAPPY_HOUR.happyhour
		return
	end
	
	if not trig.health
		return
	end
	
	
	if P_MobjFlip(trig) == 1
		local myz = trig.z+trig.height
		if not (mo.z <= myz+trig.scale and mo.z >= myz-trig.scale)
			return
		end
		if (mo.momz)
			return
		end
		
		HH_Trigger(3*60*TR)
		S_StartSound(trig,trig.info.deathsound)
		trig.state = trig.info.deathstate
		trig.spritexscaleadd = FU
		trig.spriteyscaleadd = -FU*3/2
	else
	
	end
	return true
end,MT_HHTRIGGER)

filesdone = $+1
