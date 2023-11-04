/*
	the misc file, for object thinkers, netvars, and stuff not
	directly related to takis
	
*/

local function L_ZCollide(mo1,mo2)
	if mo1.z > mo2.height+mo2.z then return false end
	if mo2.z > mo1.height+mo1.z then return false end
	return true
end
local transtonum = {
	[FF_TRANS90] = 9,
	[FF_TRANS80] = 8,
	[FF_TRANS70] = 7,
	[FF_TRANS60] = 6,
	[FF_TRANS50] = 5,
	[FF_TRANS40] = 4,
	[FF_TRANS30] = 3,
	[FF_TRANS20] = 2,
	[FF_TRANS10] = 1,
}
local numtotrans = {
	[9] = FF_TRANS90,
	[8] = FF_TRANS80,
	[7] = FF_TRANS70,
	[6] = FF_TRANS60,
	[5] = FF_TRANS50,
	[4] = FF_TRANS40,
	[3] = FF_TRANS30,
	[2] = FF_TRANS20,
	[1] = FF_TRANS10,
	[0] = 0,
}

addHook("MapChange", function(mapid)
	TAKIS_MAX_HEARTCARDS = 6
	if (mapheaderinfo[mapid].takis_maxheartcards)
		if (tonumber(mapheaderinfo[mapid].takis_maxheartcards) > 0)
			TAKIS_MAX_HEARTCARDS = tonumber(mapheaderinfo[mapid].takis_maxheartcards)
		end
	end
	if ultimatemode
		TAKIS_MAX_HEARTCARDS = 1
	end
	
	TAKIS_NET.ideyadrones = {}
	HH_Reset()
end)

addHook("MapLoad", function(mapid)
	local t = TAKIS_NET
		
	t.inbossmap = false
	
	t.numdestroyables = 0
	
	t.inspecialstage = G_IsSpecialStage(mapid)
	t.isretro = (maptol & TOL_MARIO)
	
	t.livescount = 0
	
	for mt in mapthings.iterate
		if mt.mobj and mt.mobj.valid
			local mobj = mt.mobj
			
			if mobj.type == MT_CYBRAKDEMON
				t.inbrakmap = true
			end
			
			if mobj.type == MT_EGGMAN_BOX
				continue
			end
			
			if (mobj.flags & (MF_ENEMY|MF_MONITOR))
			or (SPIKE_LIST[mobj.type] == true)
			or (mobj.takis_flingme)
				mobj.partofdestoys = true
				t.numdestroyables = $+1
			end
		else
			continue
		end
		
	end
	
	local numplayers = 0
	for p in players.iterate
		if p.quittime
			continue
		end
		if p.bot
			continue
		end
		
		numplayers = $+1		
	end
		
	t.partdestroy = t.numdestroyables/(numplayers+2) or 1
	
end)

//thinkframe for netvars
addHook("ThinkFrame", do
	
	if gamestate == GS_TITLESCREEN
		TAKIS_TITLETIME = $+1
		
		//you probably wont get this without stalling
		if TAKIS_TITLETIME == (120*FU)
			S_ChangeMusic("D",false)
			S_StartSound(nil,sfx_jumpsc)
			TAKIS_TITLEFUNNY = (TR)+1
			TAKIS_TITLEFUNNYY = 500*FU
		end
		if TAKIS_TITLEFUNNY > 0
			if TAKIS_TITLEFUNNY == 1
				COM_BufInsertText(consoleplayer,"quit")
			end
			TAKIS_TITLEFUNNY = $-1
		end
	else
		TAKIS_TITLETIME = 0
	end
	
	if gamestate ~= GS_LEVEL
		return
	end
	
	if (gametyperules & GTR_TAG)
		return
	elseif (G_GametypeHasTeams())
		return
	else
		
		if (G_GametypeUsesLives())
			
			if ((netgame or multiplayer) and G_GametypeUsesCoopLives() and (CV_FindVar("cooplives").value == 3))
				
				local lives = 0
				
				for p in players.iterate
					if p.lives < 1
						continue
					end
					
					if (p.lives == INFLIVES)
						lives = INFLIVES
						break
					elseif lives < 99
						lives = $+p.lives
					end
					
				end
				
				TAKIS_NET.livescount = lives
			end
		end
	end
	
	local nump = 0
	local numt = 0
	local exitors = 0
	local pizzatime = HAPPY_HOUR.happyhour
	for p in players.iterate
		if not p
		or not p.valid
			continue
		end
		
		if p.quittime
			continue
		end
		if p.bot
			continue
		end
		
		nump = $+1
		if skins[p.skin].name == TAKIS_SKIN
			numt = $+1
		end
		if p.exiting or p.spectator or (p.pizzaface or (p.playerstate == PST_DEAD and pizzatime))
			exitors = $+1
		end
		
		if not p.takistable
			continue
		end
		
		if ((p.mo) and (p.mo.valid))
			if p.mo.skin ~= TAKIS_SKIN
				continue
			end
			
			if p.pflags & PF_SLIDING
				p.takistable.inwaterslide = true
			else
				p.takistable.inwaterslide = false
			end
		end
		
	end

	TAKIS_NET.playercount = numplayers
	TAKIS_NET.exitingcount = exitors
	
	if not (leveltime % 3*TR)
		if numt >= 6
		and ((multiplayer) and not splitscreen)
			for p in players.iterate
				if skins[p.skin].name == TAKIS_SKIN
					TakisAwardAchievement(p,ACHIEVEMENT_TAKISFEST)
				end
			end
			
		end
	end
	
	if (ultimatemode)
		if TAKIS_MAX_HEARTCARDS ~= 1
			TAKIS_MAX_HEARTCARDS = 1
		end
	else
		if TAKIS_MAX_HEARTCARDS < 1
			TAKIS_MAX_HEARTCARDS = 6
		end
	end
	
end)

//after image
addHook("MobjThinker", function(ai)
	if not ai
	or not ai.valid
		return
	end
	
	//we need a thing to follow
	if not ai.target
	or not ai.target.valid
		P_RemoveMobj(ai)
		return
	end
	
	local p = ai.target.player or server
	local me = p.mo
	
	//bruh
	if not me
	or not me.valid
		P_RemoveMobj(ai)
		return	
	end
	
	ai.spritexoffset = ai.takis_spritexoffset or 0
	ai.spriteyoffset = ai.takis_spriteyoffset or 0
	ai.spritexscale = ai.takis_spritexscale or FU
	ai.spriteyscale = ai.takis_spriteyscale or FU
	ai.rollangle = ai.takis_rollangle or 0
	
	ai.frame = ai.takis_frame|FF_TRANS30
	
	ai.colorized = true
	if not ai.timealive
		ai.timealive = 1	
	else
		ai.timealive = $+1
	end
	
	/*
	if p.takistable.io.additiveai
		local transnum = numtotrans[((ai.timealive*2/3)+1) %9]
		ai.frame = $|transnum
	else
		if ai.timealive % 6 <= 2
			ai.frame = $|FF_TRANS10
		else
			if P_RandomChance(FU/2)
				ai.frame = $|FF_TRANS70
			else
				ai.frame = $|FF_TRANS50
			end
		end
	end
	*/
	
	if not (camera.chase)
		//only dontdraw afterimages that are too close to the player
		local dist = TAKIS_TAUNT_DIST*3
		
		local dx = me.x-ai.x
		local dy = me.y-ai.y
		local dz = me.z-ai.z
		if FixedHypot(FixedHypot(dx,dy),dz) < dist
			ai.flags2 = $|MF2_DONTDRAW
		else
			ai.flags2 = $ &~MF2_DONTDRAW
		end
	else
		ai.flags2 = $ &~MF2_DONTDRAW
	end
	
	if p.takistable.io.additiveai
		ai.blendmode = AST_ADD
	else
		ai.blendmode = AST_TRANSLUCENT
	end
	
	local fuselimit = 5

	//because fuse doesnt wanna work
	if ai.timealive > fuselimit
		P_RemoveMobj(ai)
		return
	end
	
end, MT_TAKIS_AFTERIMAGE)

addHook("MobjSpawn",function(AA)
	AA.spritexscale,AA.spriteyscale = 2*FU,2*FU
	AA.timealive = 1
	AA.scale = FU*2
end,MT_TAKIS_BADNIK_RAGDOLL_A)
addHook("MobjThinker",function(AA)
	if not AA
	or not AA.valid
		return
	end
	local flip = P_MobjFlip(AA)
	if AA.timealive <= 10
		AA.z = $ - ((10-AA.timealive)*FU)*flip
	else
		AA.z = $ + ((AA.timealive-10)*FU)*flip
		AA.destscale = 0
	end
	AA.timealive = $+1
end,MT_TAKIS_BADNIK_RAGDOLL_A)

addHook("MobjThinker", function(rag)
	if not rag
	or not rag.valid
		return
	end
	
	rag.speed = abs(FixedHypot(rag.momx,rag.momy))
	rag.timealive = $+1
	if not (rag.timealive % 2)
		local aa = P_SpawnMobjFromMobj(rag,0,0,rag.height/2,MT_TAKIS_BADNIK_RAGDOLL_A)
		aa.color = SKINCOLOR_KETCHUP
	end
	if rag.timealive % 5 == 0
		local poof = P_SpawnMobjFromMobj(rag,0,0,rag.height/2,MT_SPINDUST)
		poof.scale = FixedMul(2*FRACUNIT,rag.scale)
		poof.colorized = true
		poof.destscale = rag.scale/4
		poof.scalespeed = FRACUNIT/4
		poof.fuse = 10				
	end
	//do hitboxes
	//make hitting stuff more generous
	local oldbox = {rag.radius,rag.height}
	rag.radius,rag.height = $1*2, $2*2
	
	local oldpos = {rag.x,rag.y,rag.z}
	P_SetOrigin(rag,oldpos[1],oldpos[2],
		oldpos[3]-(rag.height/2*P_MobjFlip(rag))
	)
	local px = rag.x
	local py = rag.y
	local br = FixedDiv(rag.radius*5/2,2*FU)
	searchBlockmap("objects", function(rag, found)
		if found and found.valid
		and (found.health)
		and (L_ZCollide(rag,found))
			if (found.takis_flingme ~= false)
				if (found.flags & (MF_ENEMY|MF_BOSS))
				or (found.flags & MF_MONITOR)
				or (found.takis_flingme)
					SpawnRagThing(found,rag,rag.parent2)
				elseif (SPIKE_LIST[found.type] == true)
					P_KillMobj(found,rag,rag.parent2)
				end
			end
		end
	end, rag, px-br, px+br, py-br, py+br)
	rag.radius,rag.height = unpack(oldbox)
	P_SetOrigin(rag,oldpos[1],oldpos[2],oldpos[3])
	//
	
	rag.angle = $-ANG10
	if rag.speed == 0
	or ((P_IsObjectOnGround(rag)) and (rag.timealive > 4))
		for i = 0, 34
			A_BossScream(rag,1,MT_SONIC3KBOSSEXPLODE)
		end
		
		//collaterals
		local px = rag.x
		local py = rag.y
		local br = 420*rag.scale
		local h = 20
		
		if (TAKIS_DEBUGFLAG & DEBUG_BLOCKMAP)
			local me = rag
			for i = 0,10
				local f1 = P_SpawnMobj(px-br,py-br,me.z+((h*FU)*i),MT_THOK)
				f1.tics = -1
				f1.fuse = TR
				f1.sprite = SPR_RING
			end
			for i = 0,10
				local f2 = P_SpawnMobj(px-br,py+br,me.z+((h*FU)*i),MT_THOK)
				f2.tics = -1
				f2.fuse = TR
				f2.sprite = SPR_RING
			end
			for i = 0,10
				local f3 = P_SpawnMobj(px+br,py-br,me.z+((h*FU)*i),MT_THOK)
				f3.tics = -1
				f3.fuse = TR
				f3.sprite = SPR_RING
			end
			for i = 0,10
				local f4 = P_SpawnMobj(px+br,py+br,me.z+((h*FU)*i),MT_THOK)
				f4.tics = -1
				f4.fuse = TR
				f4.sprite = SPR_RING
			end
		end
		
		local helper = P_SpawnGhostMobj(rag)
		helper.flags2 = $|MF2_DONTDRAW
		helper.fuse = 5
		helper.parent2 = rag.parent2
		searchBlockmap("objects", function(helper, found)
			if found and found.valid
			and (found.health)
				if (found.takis_flingme ~= false)
					if (found.flags & (MF_ENEMY|MF_BOSS))
					or (found.flags & MF_MONITOR)
					or (found.takis_flingme)
						SpawnRagThing(found,helper,helper.parent2)
					elseif (SPIKE_LIST[found.type] == true)
						P_KillMobj(found,helper,helper.parent2)
					end
				end
			end
		end, helper, px-br, px+br, py-br, py+br)		
		
		for i = 0,4
			local ring = P_SpawnMobjFromMobj(rag,
				0,0,0,MT_WINDRINGLOL
			)
			if (ring and ring.valid)
				ring.renderflags = RF_FLOORSPRITE
				ring.frame = $|FF_TRANS50
				ring.startingtrans = FF_TRANS50
				ring.scale = FixedMul(rag.scale,5*FU-(i*3*FU/2))
				ring.fuse = 10
				ring.destscale = FixedMul(ring.scale,2*FU)
				ring.scalespeed = 3*FU/2-(i*FU/2)
				ring.colorized = true
				ring.color = SKINCOLOR_WHITE
			end
		end
		
		local f = P_SpawnGhostMobj(rag)
		f.flags2 = $|MF2_DONTDRAW
		f.fuse = 2*TR
		S_StartSound(f,sfx_tkapow)
		P_RemoveMobj(rag)
	end
end, MT_TAKIS_BADNIK_RAGDOLL)

//starposts refill combo bar
addHook("MobjSpawn", function(post)
	post.activators = {
		cards = {},
		combo = {},
		cardsrespawn = {},
		comborespawn = {},
	}
end, MT_STARPOST)

local function docards(post,touch)
	if touch.skin ~= TAKIS_SKIN
		return
	end
	
	if touch.player.takistable.heartcards == TAKIS_MAX_HEARTCARDS
		return
	end
	
	post.activators.cards[touch] = true
	
	if CV_FindVar("respawnitem").value
	and (splitscreen or multiplayer)
		local time = CV_FindVar("respawnitemtime").value * TICRATE
		post.activators.cardsrespawn[touch] = time
	else
		post.activators.cardsrespawn[touch] = -1
	end	
	
	TakisHealPlayer(touch.player,touch,touch.player.takistable,2)
	S_StartSound(post,sfx_takhel,touch.player)
	touch.player.takistable.HUD.statusface.happyfacetic = 3*TR/2
	
end
local function docombo(post,touch)
	if touch.skin ~= TAKIS_SKIN
		return
	end
	
	
	if not touch.player.takistable.combo.time
		return
	end
	
	post.activators.combo[touch] = true
	
	if CV_FindVar("respawnitem").value
	and (splitscreen or multiplayer)
		local time = CV_FindVar("respawnitemtime").value * TICRATE
		post.activators.comborespawn[touch] = time
	else
		post.activators.comborespawn[touch] = -1
	end	
	
	TakisGiveCombo(touch.player,touch.player.takistable,false,true)
	S_StartSound(post,sfx_ptchkp,touch.player)
	

end

addHook("TouchSpecial", function(post,touch)
	if not L_ZCollide(post,touch)
		return
	end
	
	if not post.activators
		post.activators = {
			cards = {},
			combo = {}
		}
	end
	if not post.activators.cards
		post.activators.cards = {}
	end
	if not post.activators.combo
		post.activators.combo = {}
	end
	
	//thanks amperbee
	if not post.activators.cards[touch]
		
		if ((post.activators.cards[touch] == false) or (post.activators.cards[touch] == nil))
			docards(post,touch)
		end
	end
	if not post.activators.combo[touch]
		if ((post.activators.combo[touch] == false) or (post.activators.combo[touch] == nil))
			docombo(post,touch)
		end
	end
	if not touch.player.takistable.HUD.menutext.tics
		touch.player.takistable.HUD.menutext.tics = 3*TR+9
	end
end, MT_STARPOST)

addHook("MobjDeath",function(t,i,s)
	if s
	and s.skin == TAKIS_SKIN
	and s.player
	
		if s.player.takistable.combo.time
			TakisGiveCombo(s.player,s.player.takistable,false,true)
		end
		
		if s.player.powers[pw_shield] & SH_FIREFLOWER
			TakisHealPlayer(s.player,s,s.player.takistable,1,1)
			S_StartSound(s,sfx_takhel,s.player)
		end
	end
end,MT_FIREFLOWER)

addHook("MobjDeath", function(target,inflict,source)
	if source
	and source.skin == TAKIS_SKIN
	and source.player
		for p in players.iterate
			p.takistable.HUD.statusface.happyfacetic = 3*TR/2
		end
	end
end, MT_TOKEN)

addHook("MobjThinker", function(sweat)
	if not sweat
	or not sweat.valid
		return
	end
	
	if not sweat.tracer
	or not sweat.tracer.valid
		P_RemoveMobj(sweat)
		return
	end
	
	if not (camera.chase)
		sweat.flags2 = $|MF2_DONTDRAW
	else
		sweat.flags2 = $ &~MF2_DONTDRAW
	end
	
	if sweat.tracer.skin ~= TAKIS_SKIN
		sweat.flags2 = $|MF2_DONTDRAW
	end
	
	if sweat.tracer.eflags & MFE_VERTICALFLIP
		sweat.eflags = $|MFE_VERTICALFLIP
		P_MoveOrigin(sweat, sweat.tracer.x, sweat.tracer.y, (sweat.tracer.z + sweat.tracer.height - sweat.height)-sweat.tracer.height+(45*sweat.scale))
	else
		sweat.eflags = $ &~MFE_VERTICALFLIP
		P_MoveOrigin(sweat, sweat.tracer.x, sweat.tracer.y, (sweat.tracer.z+sweat.tracer.height)-(45*sweat.scale))
	end	
	sweat.scale = sweat.tracer.scale
end,MT_TAKIS_SWEAT)

addHook("MobjThinker", function(bolt)
	if not bolt
	or not bolt.valid
		return
	end
	
	if not bolt.tracer
	or not bolt.tracer.valid
		P_RemoveMobj(bolt)
		return
	end
	
	if not (camera.chase)
		bolt.flags2 = $|MF2_DONTDRAW
	else
		bolt.flags2 = $ &~MF2_DONTDRAW
	end
	
end,MT_SOAP_SUPERTAUNT_FLYINGBOLT)

//eject from carts
addHook("MobjThinker",function(cart)
	if not cart
	or not cart.valid
	or not cart.target
		return
	end
	
	if ((cart.target) and (cart.target.valid))
	and cart.target.skin == TAKIS_SKIN
		
		local p = cart.target.player
		local takis = p.takistable
		
		if (p.cmd.buttons & BT_CUSTOM1)
		and (p.powers[pw_carry] == CR_MINECART)
			p.powers[pw_carry] = CR_NONE
			
			p.mo.momx,p.mo.momy = cart.momx,cart.momy
			
			p.pflags = $|PF_JUMPED &~PF_THOKKED
			takis.thokked = false
			takis.dived = false

			p.mo.momz = (8*p.mo.scale)*P_MobjFlip(p.mo)
			P_DoJump(p,true)
			p.mo.state = S_PLAY_ROLL
			
			TakisGiveCombo(p,takis,true)
			cart.target = nil
			return
			
		end
		
	end
	
	
end,MT_MINECART)

addHook("MobjDeath",function(mo,i,s)
	local gst = P_SpawnGhostMobj(mo)
	gst.flags2 = $|MF2_DONTDRAW
	gst.fuse = 3*TR
	
	S_StartSound(gst,mobjinfo[MT_SPIKE].deathsound)

	for i = 0,16
		local debris = P_SpawnMobjFromMobj(mo,
			(P_RandomRange(-10,10)*mo.scale),
			(P_RandomRange(-10,10)*mo.scale),
			(P_RandomRange(-10,10)*mo.scale),
			MT_THOK
		)
		debris.sprite = SPR_USPK
		debris.frame = P_RandomRange(E,F)
		debris.tics = -1
		debris.fuse = 3*TR
		debris.angle = R_PointToAngle2(debris.x,debris.y, mo.x,mo.y)
		debris.flags = $ &~MF_NOGRAVITY
		P_SetObjectMomZ(debris,10*mo.scale)
		P_Thrust(debris,InvAngle(debris.angle),2*mo.scale)
	end
	
end,MT_SPIKEBALL)

local function happyhourmus(oldname, newname, mflags,looping,pos,prefade,fade)
	if splitscreen
		return
	end
	
	if not (consoleplayer and consoleplayer.valid)
		return
	end
	
	if not (consoleplayer.takistable)
		return
	end
	
	local dohhmus = true
	if (consoleplayer.takistable.io.nohappyhour == 1)
		dohhmus = false
	end
	
	if (skins[consoleplayer.skin].name ~= TAKIS_SKIN)
	and (consoleplayer.takistable.io.morehappyhour == 0)
		dohhmus = false
	end
	
	if (HAPPY_HOUR.happyhour)
	and dohhmus
	
		
		local song = "hapyhr"
		if (consoleplayer.takistable.io.happyhourstyle == 2)
			song = "hpyhr2"
		end
		
		local pizzatime = HAPPY_HOUR.happyhour
		newname = string.lower(newname)
		local isspecsong
		isspecsong = string.sub(newname,1,1) == "_"
		if not isspecsong
			isspecsong = TAKIS_NET.specsongs[newname]
		end
		
		//stop any lap music
		if pizzatime 
		and (not isspecsong)
		
			local changetohappy = true
			
			if HAPPY_HOUR.timelimit
			and (consoleplayer.takistable.io.happyhourstyle == 1)
				
				if HAPPY_HOUR.timeleft
					local tics = HAPPY_HOUR.timeleft
					
					if tics <= (56*TR)
						changetohappy = false
					end
				end
			end
			
			if changetohappy
				if oldname ~= song
					return ReturnTakisMusic(song,consoleplayer),mflags,looping,pos,prefade,fade
				end
			
			else
				if oldname ~= "hpyhre"
					return ReturnTakisMusic("hpyhre",consoleplayer),mflags,looping,pos,prefade,fade
				end
			end
			
			return true
		end
		
	else

		if not consoleplayer.takistable.shotgunned
			return
		end
		
		local newname = string.lower(newname)
		
		if (TAKIS_NET.specsongs[newname] ~= true)
			return ReturnTakisMusic("war",consoleplayer),mflags,looping,pos,prefade,fade
		end
	end
end
addHook("MusicChange", happyhourmus)

/*
addHook("MobjMoveBlocked", function(mo, thing, line)
	if not mo
	or not mo.valid
		return
	end
	
	local p = mo.player
	local takis = p.takistable
	
	if p.mo
	and p.mo.valid
		local me = p.mo
		
		if me.skin ~= TAKIS_SKIN
			return
		end
		
		if takis.accspeed < 8*skins[TAKIS_SKIN].normalspeed/5
			return
		end
		
		if ((thing) and (thing.valid)) or ((line) and (line.valid))
			if takis.afterimaging
				if thing and thing.valid
					if thing.flags & MF_MONITOR
						return
					end
					
					P_DoPlayerPain(p, thing, thing)
					local ang = R_PointToAngle2(me.x,me.y, thing.x,thing.y)
					P_InstaThrust(me,ang,-takis.accspeed/5)
				elseif line and line.valid
					P_DoPlayerPain(p)
					P_InstaThrust(me,p.drawangle,-takis.accspeed/5)
				end
				
				DoFlash(p,PAL_NUKE,5)
				DoQuake(p,15*me.scale,5)
				S_StartSound(me,sfx_shldls)				
				S_StartSound(me,sfx_slam)	
				me.momz = (7*me.scale)*takis.gravflip
				S_StartAntonOw(me)
			end
		end
	end
end, MT_PLAYER)
*/

addHook("MobjThinker",function(mo)
	if not mo
	or not mo.valid
		return
	end
	
	if not mo.target
	or not mo.target.valid
		P_KillMobj(mo)
		return
	end
	
	if mo.target.eflags & MFE_VERTICALFLIP
		mo.eflags = $|MFE_VERTICALFLIP
		P_MoveOrigin(mo, mo.target.x, mo.target.y, (mo.target.z + mo.target.height - mo.height)-(mo.target.height*2))
	else
		P_MoveOrigin(mo, mo.target.x, mo.target.y, mo.target.z+(mo.target.height*2) )
	end	
	
end,MT_TAKIS_TAUNT_JOIN)

addHook("MobjThinker",function(mo)
	if not mo
	or not mo.valid
		return
	end
	
	if not mo.ragdoll
		if not mo.target
		or not mo.target.valid
			P_KillMobj(mo)
			return
		end
		
		local p = mo.target.player
		
		local trans = 0
		
		if (p.takistable.noability & NOABIL_SHOTGUN)
			trans = FF_TRANS50
		end
		
		local x = cos(p.drawangle-ANGLE_90)
		local y = sin(p.drawangle-ANGLE_90)
		
		mo.angle = p.drawangle
		
		if mo.target.eflags & MFE_VERTICALFLIP
			mo.eflags = $|MFE_VERTICALFLIP
			P_MoveOrigin(mo, mo.target.x+(16*x), mo.target.y+(16*y), (mo.target.z + mo.target.height - mo.height)-(mo.target.height/2))
		else
			P_MoveOrigin(mo, mo.target.x+(16*x), mo.target.y+(16*y), mo.target.z+(mo.target.height/2) )
		end
		
		mo.frame = A|trans
	else
		local rag = mo
		
		rag.timealive = $+1
		if rag.timealive % 5 == 0
			local poof = P_SpawnMobjFromMobj(rag,0,0,rag.height/2,MT_SPINDUST)
			poof.scale = FixedMul(FRACUNIT*4/5,rag.scale)
			poof.colorized = true
			poof.destscale = rag.scale/4
			poof.scalespeed = FRACUNIT/10
			poof.fuse = 10				
		end
		
	end
	
end,MT_TAKIS_SHOTGUN)

addHook("MobjMoveCollide",function(shot,mo)
	if not shot
	or not shot.valid
		return
	end
	
	if not shot.shotbytakis
		return
	end
	
	if not L_ZCollide(shot,mo)
		return
	end
	
	if not mo.health
		return
	end
	
	if (mo.flags & MF_MONITOR)
		SpawnRagThing(mo,shot,shot.tracer)
	end
	
	if (SPIKE_LIST[mo.type] == true)
		P_KillMobj(mo,shot,shot.tracer)
	end
	
	if (mo.flags & (MF_ENEMY|MF_BOSS))
		SpawnRagThing(mo,shot,shot.tracer)
		return true
	end
	
end,MT_THROWNSCATTER)

addHook("MobjDeath",function(gun,i)
	if not gun.ragdoll
		local rag = P_SpawnMobjFromMobj(gun,0,0,0,MT_TAKIS_SHOTGUN)
		rag.ragdoll = true
		rag.timealive = 0
		rag.flags = $ &~MF_NOGRAVITY
		rag.fuse = 4*TR
		rag.frame = B
		rag.rollangle = ANGLE_90-(ANG10*3)
		
		P_SetObjectMomZ(rag,10*FU)
		P_Thrust(rag, R_PointToAngle2(rag.x,rag.y, i.x,i.y), -5*rag.scale)
		
		S_StartSound(i,sfx_shgnk)
	end
end,MT_TAKIS_SHOTGUN)

addHook("MobjThinker",function(shot)
	if not shot.shotbytakis
		return
	end
	
	TakisBreakAndBust(nil,shot)
	
	if not shot.critcharged
		return
	end
	
	P_InstaThrust(shot,shot.angle,FU*10)
	shot.momz = FU
	
	shot.colorized = true
	shot.color = shot.tracer.player.skincolor
	
	if not (leveltime % 5)
		local rad = shot.radius/FRACUNIT
		local hei = shot.height/FRACUNIT
		local x = P_RandomRange(-rad,rad)*FRACUNIT
		local y = P_RandomRange(-rad,rad)*FRACUNIT
		local z = P_RandomRange(0,hei)*FRACUNIT
		local rang = P_RandomRange(-25,25)
		local xa,ya = ReturnTrigAngles(shot.angle)
		local spark = P_SpawnMobjFromMobj(shot,x+(rang*xa),y+(rang*ya),z,MT_SOAP_SUPERTAUNT_FLYINGBOLT)
		spark.tracer = shot
		spark.state = P_RandomRange(S_SOAP_SUPERTAUNT_FLYINGBOLT1,S_SOAP_SUPERTAUNT_FLYINGBOLT5)			
		spark.blendmode = AST_ADD
		spark.color = shot.color
		spark.angle = shot.angle
		spark.rollangle = R_PointToAngle2(0, 0, R_PointToDist2(0, 0, shot.momx, shot.momy), shot.momz) + ANGLE_90
		
		local g = P_SpawnGhostMobj(shot)
		g.colorized = true
		g.frame = shot.frame|FF_TRANS50
		g.angle = shot.angle
	end
	
end,MT_THROWNSCATTER)

addHook("MobjDeath",function(shot,i,s)
	if ((i == shot.tracer) or (s == shot.tracer))
	or ((shot.timealive < 10) and (i.valid or s.valid))
		return true
	end
end,MT_THROWNSCATTER)

//specials

-- combo
local types = {
	MT_RING,
	MT_COIN,
	MT_BLUESPHERE,
	MT_TOKEN,
	MT_EMBLEM,
	MT_BOUNCERING,
	MT_RAILRING,
	MT_INFINITYRING,
	MT_AUTOMATICRING,
	MT_EXPLOSIONRING,
	MT_SCATTERRING,
	MT_GRENADERING,
	MT_REDTEAMRING,
	MT_BLUETEAMRING
}

local function makespecial(mo)
	mo.takis_givecombotime = true
end

for k,type in pairs(types)
	addHook("MobjSpawn",makespecial,type)
end
--

--cards
local types2 = {
	MT_RING,
	MT_COIN,
	MT_REDTEAMRING,
	MT_BLUETEAMRING
}


local function givepieces(mo)
	mo.takis_givecardpieces = true
end

for k,type in pairs(types2)
	addHook("MobjSpawn",givepieces,type)
end
--

//
addHook("PreThinkFrame",function()
	for p in players.iterate
		if not p
		or not p.valid
			continue
		end
		
		//p.HAPPY_HOURscream = {}
		
		if not p.takistable
			continue
		end
		
		local takis = p.takistable
		
		if (takis.cosmenu.menuinaction)
			TakisMenuThinker(p)
		end
				
	end
end)

local function choose(...)
	local args = {...}
	local choice = P_RandomRange(1,#args)
	return args[choice]
end

addHook("MobjThinker",function(s)
	if not s
	or not s.valid
		return
	end
	
	if s.target.skin == TAKIS_SKIN
		local p = s.target.player
		local takis = p.takistable
		
		if takis.io.flashes
			/*
			choose(AST_ADD,AST_TRANSLUCENT,AST_MODULATE
				AST_ADD,AST_ADD,AST_TRANSLUCENT,AST_TRANSLUCENT,AST_MODULATE)
			*/
			
			if not (leveltime % 3)
				local rad = s.radius/FRACUNIT
				local hei = s.height/FRACUNIT
				local x = P_RandomRange(-rad,rad)*FRACUNIT
				local y = P_RandomRange(-rad,rad)*FRACUNIT
				local z = P_RandomRange(0,hei)*FRACUNIT
				local spark = P_SpawnMobjFromMobj(s,x,y,z,MT_SOAP_SUPERTAUNT_FLYINGBOLT)
				spark.tracer = s
				spark.state = P_RandomRange(S_SOAP_SUPERTAUNT_FLYINGBOLT1,S_SOAP_SUPERTAUNT_FLYINGBOLT5)			
				spark.blendmode = AST_ADD
				spark.color = P_RandomRange(SKINCOLOR_SALMON,SKINCOLOR_KETCHUP)
				spark.angle = p.drawangle+(FixedAngle( P_RandomRange(-337,337)*FRACUNIT ))
				spark.momz = P_RandomRange(0,4)*s.scale*takis.gravflip
				P_Thrust(spark,spark.angle,P_RandomRange(1,5)*s.scale)
			end
			
			//die
	/*
			local trans = 0
			local lt = (leveltime % 10)
			if lt == 1
				trans = FF_TRANS10
			elseif lt == 2
				trans = FF_TRANS20
			elseif lt == 3
				trans = FF_TRANS30
			elseif lt == 4
				trans = FF_TRANS40
			elseif lt == 5
				trans = FF_TRANS50
			elseif lt == 6
				trans = FF_TRANS60
			elseif lt == 7
				trans = FF_TRANS70
			elseif lt == 8
				trans = FF_TRANS80
			elseif lt == 9
				trans = FF_TRANS90
			end
	*/

			local trans = 0
			trans = choose(FF_TRANS10,FF_TRANS20,FF_TRANS30,FF_TRANS40,
				FF_TRANS50,FF_TRANS60,FF_TRANS70,FF_TRANS80,FF_TRANS90)
			
			s.frame = $|trans
			s.tracer.frame = $|trans
		end
	end
end,MT_ARMAGEDDON_ORB)

addHook("MobjThinker",function(me)
	if not me
	or not me.valid
		return
	end
	
	if me.activators == nil
		me.activators = {
			cards = {},
			combo = {},
			cardsrespawn = {},
			comborespawn = {},
		}
		return
	end
	
	for k,v in pairs(me.activators.cardsrespawn)
		if v == nil
			continue
		end
		
		if v > 0
			if v > CV_FindVar("respawnitemtime").value*TICRATE
				v = CV_FindVar("respawnitemtime").value*TICRATE
			end
			
			me.activators.cardsrespawn[k] = $-1
		elseif v == 0
		and (me.activators.cards[k] ~= false)
			me.activators.cards[k] = false
			table.remove(me.activators.cardsrespawn,me.activators.cardsrespawn[k])
			S_StartSound(me,sfx_sprcar)
			
			local g = P_SpawnMobjFromMobj(me,0,0,me.height/4,MT_THOK)
			g.sprite = SPR_HTCD
			g.frame = A
			g.tics = TR
			g.blendmode = AST_ADD
			g.scale = FixedMul(me.scale,2*FU)
			g.destscale = FixedDiv(me.scale,4*FU)
		end
	end

	for k,v in pairs(me.activators.comborespawn)
		if v == nil
			continue
		end
		
		if v > 0
			if v > CV_FindVar("respawnitemtime").value*TICRATE
				v = CV_FindVar("respawnitemtime").value*TICRATE
			end
			
			me.activators.comborespawn[k] = $-1
		elseif v == 0
		and (me.activators.combo[k] ~= false)
			me.activators.combo[k] = false
			table.remove(me.activators.comborespawn,me.activators.comborespawn[k])
			S_StartSound(me,sfx_sprcom)

			local g = P_SpawnMobjFromMobj(me,0,0,me.height/4,MT_THOK)
			g.sprite = SPR_CMBB
			g.frame = A
			g.tics = TR
			local scale =  FU/2
			g.spritexscale = scale
			g.spriteyscale = scale
			g.blendmode = AST_ADD
			g.scale = FixedMul(me.scale,2*FU)
			g.destscale = FixedDiv(me.scale,4*FU)
		end
	end
	
	local br = 145*me.scale
	
	for p in players.iterate
		if p and p.valid
		and p.realmo.health
		and P_CheckSight(me,p.realmo)
				
			if p.mo.skin ~= TAKIS_SKIN
				continue
			end
			
			local dx = me.x-p.mo.x
			local dy = me.y-p.mo.y
			
			if FixedHypot(dx,dy) > br
				continue
			end
			
			//thanks Monster Iestyn for this!
			if (p and p == displayplayer)
				local found = p.mo
				
				local x,y = ReturnTrigAngles(R_PointToAngle2(me.x,me.y, found.x,found.y))
				if found.flags2 & MF2_TWOD
				or twodlevel
					x,y = ReturnTrigAngles(InvAngle(R_PointToAngle(found.x,found.y)))
				end
				
				--card
				local card = P_SpawnMobjFromMobj(me,64*x,64*y,me.height/4+(FU*10),MT_UNKNOWN)
				card.sprite = SPR_HTCD
				card.tics = 2		
				if me.activators.cards[found] == true
					card.frame = B|FF_TRANS50
				else
					card.frame = A
				end
				
				card.frame = $|FF_PAPERSPRITE
				if found.flags2 & MF2_TWOD
				or twodlevel
					card.angle = (R_PointToAngle(me.x,me.y))-ANGLE_90
				else
					card.angle = (R_PointToAngle2(me.x,me.y, found.x,found.y))-ANGLE_90
				end
				--

				--combo
				local combo = P_SpawnMobjFromMobj(me,64*x,64*y,me.height/4-(FU*10),MT_UNKNOWN)
				combo.sprite = SPR_CMBB
				combo.tics = 2		
				if me.activators.combo[found] == true
					combo.frame = B|FF_TRANS50
				else
					combo.frame = A
				end
				local scale =  FU/2
				combo.spritexscale = scale
				combo.spriteyscale = scale
				
				combo.frame = $|FF_PAPERSPRITE
				if found.flags2 & MF2_TWOD
				or twodlevel
					combo.angle = (R_PointToAngle(me.x,me.y))-ANGLE_90
				else
					combo.angle = (R_PointToAngle2(me.x,me.y, found.x,found.y))-ANGLE_90
				end
				--
			end
		end
	end
	
end,MT_STARPOST)

//disable yd if we're in a bossstage
addHook("BossThinker", function(mo)
	if (not TAKIS_NET.inbossmap)
	and (mapheaderinfo[gamemap].muspostbossname ~= '')
		TAKIS_NET.inbossmap = true
	end
	
end)

addHook("MobjThinker",function(effect)
	if not effect
	or not effect.valid
		return
	end
	
	if not effect.tracer
	or not effect.tracer.valid
		return
	end
	
	local me = effect.tracer
	local p = effect.tracer.player
	local x,y = cos(p.drawangle),sin(p.drawangle)
	
	P_MoveOrigin(effect,me.x+17*x,me.y+17*y,me.z)
	effect.angle = p.drawangle
	effect.rollangle = R_PointToAngle2(0, 0, R_PointToDist2(0, 0, me.momx, me.momy), me.momz)
	effect.scale = me.scale
	
	if (effect.tics % 2)
		effect.flags2 = $|MF2_DONTDRAW
	else
		effect.flags2 = $ &~MF2_DONTDRAW
	end
	
end,MT_TAKIS_DRILLEFFECT)

addHook("HurtMsg", function(p, inf, sor)
	if (gametype == GT_COOP) or not (p.mo and p.mo.valid)
		return
	end
	if not inf
	or not inf.valid
		return
	end
	if not sor
	or not sor.valid
		return
	end
	
	if not (inf.skin == TAKIS_SKIN
	or sor.skin == TAKIS_SKIN)
		return
	end
	
	local takis = p.takistable
	local me = p.mo
	
	local livetext = me.health and "hurt" or "killed"
	
	for i = 0, #takis.hurtmsg-1
		if takis.hurtmsg[i].tics
			print(sor.player.ctfnamecolor.."'s "..takis.hurtmsg[i].text.." "..livetext.." "..p.ctfnamecolor)
			return true
		end
	end
end)

//fix this stupid zfighting issue in opengl
addHook("MobjSpawn",function(drone)
	if (maptol & TOL_NIGHTS)
		drone.dispoffset = -1
		table.insert(TAKIS_NET.ideyadrones,drone)
	end
end,MT_EGGCAPSULE)

addHook("MobjThinker",function(drone)
	if not drone
	or not drone.valid
		return
	end
	
	if not (maptol & TOL_NIGHTS)
		return
	end
	
	if not (drone.flags & MF_NOGRAVITY)
	and drone.hadnograv
	and not multiplayer
		local coolp = server
		local i = 0
		for p in players.iterate
			if i == 0
				coolp = p
			end
			
			if (skins[p.skin].name ~= TAKIS_SKIN)
				return
			end
			i = $+1
		end
		//only on the final mare
		if coolp.mare ~= #TAKIS_NET.ideyadrones-1
			return
		end
		HH_Trigger(drone,coolp.nightstime)
		coolp.mo.angle = coolp.drawangle
		NiGHTSFreeroam(coolp)
	end
	
	drone.hadnograv = drone.flags & MF_NOGRAVITY
end,MT_EGGCAPSULE)


local nightsthings = {
	[MT_RING] = true,
	[MT_FLINGRING] = true,
	[MT_BLUESPHERE] = true,
	[MT_FLINGBLUESPHERE] = true,
	[MT_NIGHTSCHIP] = true,
	[MT_FLINGNIGHTSCHIP] = true,
	[MT_NIGHTSSTAR] = true,
	[MT_FLINGNIGHTSSTAR] = true,
}

addHook("MobjMoveCollide",function(effect,t)
	if not effect
	or not effect.valid
		return
	end
	
	if not t
	or not t.valid
		return
	end
	
	if not L_ZCollide(t,effect)
		return
	end
	
	if (t.flags & MF_ENEMY)
	or (nightsthings[t.type] == true)
		P_KillMobj(t,effect.tracer ,effect.tracer)
	end
	
end,MT_TAKIS_DRILLEFFECT)

//i couldve sworn i had a postthink in here
//that may just be thinking this is soap lol
//anyway, thanks to Unmatched Bracket for this code!!!
//:iwantsummadat:
addHook("PostThinkFrame", function ()
    for p in players.iterate() do
        if not (p and p.valid) then continue end
		if not (p.mo and p.mo.valid) then continue end
		if not (p.mo.skin == TAKIS_SKIN) then continue end
		
		local takis = p.takistable
		
        if takis.inwaterslide
		and not (takis.inPain or takis.inFakePain) then
            takis.resettingtoslide = true
			p.mo.sprite2 = SPR2_SLID
            p.mo.frame = ($ & ~FF_FRAMEMASK) | (leveltime % 4) / 2
            p.drawangle = p.mo.angle
			continue
        end
		
		takis.resettingtoslide = false
    end
end)

addHook("MobjThinker",function(ring)
	if not ring
	or not ring.valid
		return
	end
	
	//idk why regular fuse cant do this
	local start = ring.startingtrans
	local startn = transtonum[ring.startingtrans]
	if ring.fuse < 10-startn
		ring.frame = A|numtotrans[10-ring.fuse]
	end
end,MT_WINDRINGLOL)

addHook("MobjDeath",function(brak,_,sor)
	if not (sor and sor.valid)
		return
	end
	
	if not (sor.player and sor.player.valid)
		return
	end
	
	if not (TAKIS_NET.inbrakmap)
		return
	end
	
	if (sor.skin ~= TAKIS_SKIN)
		return
	end
	
	TakisAwardAchievement(sor.player,ACHIEVEMENT_BRAKMAN)
end,MT_CYBRAKDEMON)

local function makefling(mo)
	if not mo
	or not mo.valid
		return
	end
	
	mo.takis_flingme = true

end

local flinglist = {
	MT_EGGROBO1,
}

for k,type in pairs(flinglist)
	addHook("MobjSpawn",makefling,type)
end

//heartcards mt
addHook("MobjSpawn",function(card)
	local cardscale = 2*FU
	
	if not card
	or not card.valid
		return
	end
	
	if (card.flags2 & MF2_AMBUSH)
		card.flags = $|MF_NOGRAVITY
	end
	
	card.spritexscale,card.spriteyscale = cardscale,cardscale
end,MT_TAKIS_HEARTCARD)

addHook("MobjThinker",function(card)
	if not card
	or not card.valid
		return
	end
	
	local grounded = P_IsObjectOnGround(card)
	card.angle = $+FixedAngle(5*FU)
	card.spawnflags = mobjinfo[card.type].flags
	if (card.flags2 & MF2_AMBUSH)
		card.spawnflags = $|MF_NOGRAVITY
	end
	if card.groundtime == nil
		card.groundtime = 0
	end
	if card.timealive == nil
		card.timealive = 1
	else
		card.timealive = $+1
	end
	
	if grounded
		if (card.eflags & MFE_JUSTHITFLOOR)
			if (-card.lastmomz > 2*FU)
				P_SetObjectMomZ(card,-card.lastmomz/2)
				S_StartSound(card,sfx_hrtcdt)
			end
		end
		
		card.groundtime = $+1
		local waveforce = FU
		local ay = FixedMul(waveforce,sin(card.groundtime*3*ANG2))
		card.spriteyoffset = 3*FU+ay
	else
		if card.groundtime
			card.groundtime = $-1
		end
	end
	card.lastmomz = card.momz
end,MT_TAKIS_HEARTCARD)

addHook("MobjDeath",function(card,_,sor)
	if not card
	or not card.valid
		return
	end
	
	local ttime = card.timealive or 0
	
	if sor
	and sor.skin == TAKIS_SKIN
	and sor.player
	and sor.player.valid
		local doreturn = false
		if (sor.player.takistable.heartcards ~= TAKIS_MAX_HEARTCARDS)
		and (ttime > 4)
			TakisHealPlayer(sor.player,sor,sor.player.takistable,1,1)
			local sound = P_SpawnGhostMobj(card)
			sound.flags2 = $|MF2_DONTDRAW
			sound.fuse = TR
			S_StartSound(sound,sfx_takhel,sor.player)
			doreturn = true
		end
		if (sor.player.takistable.combo.time)
		and (ttime > 4)
			TakisGiveCombo(sor.player,sor.player.takistable,false)
			S_StartSound(sor,sfx_ncitem,sor.player)
			local spark = P_SpawnMobjFromMobj(card,0,0,0,MT_THOK)
			spark.fuse = -1
			spark.state = mobjinfo[MT_RING].deathstate
			spark.scale = $*2
			doreturn = true
		end
		if (doreturn)
			return
		end
		card.health = 1000
		card.flags = card.spawnflags or mobjinfo[card.type].flags
		return true
	else
		card.health = 1000
		card.flags = card.spawnflags or mobjinfo[card.type].flags
		return true
	end
	
	
end,MT_TAKIS_HEARTCARD)

local function dontfling(mo)
	if not mo
	or not mo.valid
		return
	end
	
	mo.takis_flingme = false

end

local dontflinglist = {
	MT_EGGMAN_GOLDBOX,
	MT_EGGMAN_BOX,
	MT_BIGMINE
}

for k,type in ipairs(dontflinglist)
	addHook("MobjSpawn",dontfling,type)
end
filesdone = $+1
