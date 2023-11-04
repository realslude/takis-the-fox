rawset(_G, "TAKIS_TAUNT_DIST",75*FU)

//taunt inits

local function init_ouch(p)
	local me = p.mo
	local takis = p.takistable
	local menu = takis.tauntmenu
	
	takis.taunttime = 24
	takis.tauntcanparry = true
	S_StartAntonOw(me)
end

local function init_smug(p)
	local me = p.mo
	local takis = p.takistable
	local menu = takis.tauntmenu
	
	takis.taunttime = 12
	takis.tauntspecial = P_RandomChance(FRACUNIT/10)
	takis.tauntcanparry = true
	S_StartSound(me,sfx_tawhip)
end

local function init_conga(p)
	local me = p.mo
	local takis = p.takistable
	local menu = takis.tauntmenu
	
	takis.taunttime = 2
	takis.stasistic = 2
	takis.tauntacceptspartners = false
	//maybe put this in with takis?
	ChangeTakisMusic("_CONGA",true,p)
	S_StartMusicCaption("Conga!!",300*TR,p)
end

local function init_bat(p)
	local me = p.mo
	local takis = p.takistable
	local menu = takis.tauntmenu
	
	if not (TAKIS_NET.tauntkillsenabled)
		CONS_Printf(p,"You cannot use this taunt as the server has tauntkills disabled.")
		S_StartSound(nil,sfx_adderr,p)
		return false
	end
	
	takis.taunttime = 3*TR
	S_StartSound(me,sfx_spndsh)
	takis.tauntcanparry = false
end

//taunt thinks

local function think_ouch(p)
	local me = p.mo
	local takis = p.takistable
	
	me.state = S_PLAY_PAIN
end

local function think_smug(p)
	local me = p.mo
	local takis = p.takistable

	if not takis.tauntspecial
		me.state = S_PLAY_TAKIS_SMUGASSGRIN
	else
		me.state = S_PLAY_TAKIS_SMUGASSGRIN2
	end
	if me.tics == -1
		me.tics = 12
	end

end

local function think_conga(p)
	local me = p.mo
	local takis = p.takistable
	
	takis.nocontrol = 2
	takis.taunttime = 2
	takis.tauntjoinable = true
	
	p.drawangle = me.angle
	P_InstaThrust(me,p.drawangle,2*me.scale)
	P_MovePlayer(p)
	if me.state ~= S_PLAY_TAKIS_CONGA
		me.state = S_PLAY_TAKIS_CONGA
	else
		me.frame = (leveltime/3)%8
	end
	
	
	//cancel conga
	if (p.cmd.buttons & BT_CUSTOM1)
		TakisResetTauntStuff(takis)
		S_StartMusicCaption("Conga!!",TR,p)
		P_RestoreMusic(p)
		me.state = S_PLAY_STND
	end
end

local function think_bat(p)
	local me = p.mo
	local takis = p.takistable
	
	takis.stasistic = 2
	if (takis.taunttime == 3*TR)
		takis.wascolorized = me.colorized
	else
		if takis.taunttime > TR
			if (takis.taunttime % 2)
				me.colorized = true
			else
				me.colorized = false
			end
		elseif takis.taunttime == TR
			me.colorized = takis.wascolorized
			S_StartSound(me,sfx_mswing)
		elseif takis.taunttime == 32
			local x = cos(p.drawangle)
			local y = sin(p.drawangle)
			local b = P_SpawnMobjFromMobj(me,28*x,28*y,0,MT_TAKIS_TAUNT_HITBOX)
			b.tracer = me
			b.boxtype = "bat"
			b.fuse = 2
		end
	end
end


rawset(_G, "TAKIS_TAUNT_INIT", {
	[1] = init_ouch,
	[2] = init_smug,
	[3] = init_conga,
	[4] = init_bat,
})

rawset(_G, "TAKIS_TAUNT_THINK", {
	[1] = think_ouch,
	[2] = think_smug,
	[3] = think_conga,
	[4] = think_bat,
})

filesdone = $+1
