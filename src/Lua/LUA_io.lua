//io file

//thank you SMS reborn for being reusable!
//Y7GDSUYFHIDJPK AAAAAAAAAAAHHHHHHHHH!!!!!!!!

//if you use this manually and mess something up, its not my fault!
COM_AddCommand("takis_load", function(p, a1,a2,a3,a4,t1,t2,a5,a6,a7,a8,a9,a10,a11,a12,a13)

	if a1 == nil
	CONS_Printf(p,"\x85"+"Do not use this command manually! You may risk messing up Takis or your config!")
	return
	end

	print("Loading "..p.name.."'s config...")

	a1 = tonumber($) //Turn all of you to numbers!
	a2 = tonumber($)
	a3 = tonumber($)
	a4 = tonumber($)
	//quick taunts
	t1 = tonumber($)
	t2 = tonumber($)

	a5 = tonumber($)
	a6 = tonumber($)
	a7 = tonumber($)
	a9 = tonumber($)
	a10 = tonumber($)
	a11 = tonumber($)
	a12 = tonumber($)
	a13 = tonumber($)

	//insert to buffer or set vars directly?
	//well i say set vars as to  not clutter up the player's console
	local takis = p.takistable

	if a1 == 1
		takis.io.nostrafe = 1
	elseif a1 == 0
		takis.io.nostrafe = 0
	else
		CONS_Printf(p,"\x85"+"Error loading No-Strafe! Defaulting to 0...")
	end

	if a2 == 1
		takis.io.nohappyhour = 1
	elseif a2 == 0
		takis.io.nohappyhour = 0
	else
		CONS_Printf(p,"\x85"+"Error loading No Happy Hour! Defaulting to 0...")
	end

	if a3 == 1
		takis.io.happyhourstyle = 1
	elseif a3 == 2
		takis.io.happyhourstyle = 2
	else
		CONS_Printf(p,"\x85"+"Error loading Happy Hour Style! Defaulting to new...")
	end

	if a4 == 1
		takis.io.morehappyhour = 1
	elseif a4 == 0
		takis.io.morehappyhour = 0
	else
		CONS_Printf(p,"\x85"+"Error loading More Happy Hour! Defaulting to 0...")
	end

	//1-7 pls
	print("quick taunt1 : "..t1)
	if t1 ~= nil
	and (t1 < 8)
		takis.tauntquick1 = t1
	else
		CONS_Printf(p,"\x85"+"Error loading Quick Taunt slot 1! Defaulting to 0...")
	end

	print("quick taunt2 : "..t2)
	//1-7 pls
	if t2 ~= nil
	and (t2 < 8)
		takis.tauntquick2 = t2
	else
		CONS_Printf(p,"\x85"+"Error loading Quick Taunt slot 2! Defaulting to 0...")
	end

	if a5 == 1
		takis.io.tmcursorstyle = 1
	elseif a5 == 2
		takis.io.tmcursorstyle = 2
	else
		CONS_Printf(p,"\x85"+"Error loading Cursor Style! Defaulting to 1...")
	end

	if a5 == 1
		takis.io.quakes = 1
	elseif a5 == 0
		takis.io.quakes = 0
	else
		CONS_Printf(p,"\x85"+"Error loading Quakes! Defaulting to 1...")
	end

	if a7 == 1
		takis.io.flashes = 1
	elseif a7 == 0
		takis.io.flashes = 0
	else
		CONS_Printf(p,"\x85"+"Error loading Flashes! Defaulting to 1...")
	end

	if a9 == 1
		takis.io.additiveai = 1
	elseif a9 == 0
		takis.io.additiveai = 0
	else
		CONS_Printf(p,"\x85"+"Error loading Additive Afterimages! Defaulting to 0...")
	end

	if a10 == 1
		takis.io.ihavemusicwad = 1
		if not (modeattacking)
			if (p and p.valid)
				COM_BufInsertText(p, "addfile takismusic.pk3")
			elseif consoleplayer
				COM_BufInsertText(consoleplayer, "addfile takismusic.pk3")
			end
			if (leveltime > 2*TR)
				P_RestoreMusic(p)
			end
		end
	elseif a10 == 0
		takis.io.ihavemusicwad = 0
	else
		CONS_Printf(p,"\x85"+"Error telling if you have the Music Wad! Defaulting to 0...")
	end

	if a11 == 1
		takis.io.clutchstyle = 1
	elseif a11 == 0
		takis.io.clutchstyle = 0
	else
		CONS_Printf(p,"\x85"+"Error loading Clutch Style! Defaulting to 1..")
	end

	if a12 == 1
		takis.io.sharecombos = 1
	elseif a12 == 0
		takis.io.sharecombos = 0
	else
		CONS_Printf(p,"\x85"+"Error loading Share Combos! Defaulting to 1...")
	end

	if a13 == 1
		takis.io.dontshowach = 1
	elseif a13 == 0
		takis.io.dontshowach = 0
	else
		CONS_Printf(p,"\x85"+"Error loading Don't show Achs.! Defaulting to 1...")
	end

	CONS_Printf(p, "\x82Loaded "..skins[TAKIS_SKIN].realname.."' Settings!")
end)

rawset(_G, "TakisSaveStuff", function(p, silent)
	//write
	local a1 = 0 
	local a2 = 0 
	local a3 = 0
	local a4 = 0
	local t1 = 0
	local t2 = 0
	local a5 = 0
	local a6 = 0
	local a7 = 0
	local a8 = ''
	local a9 = 0
	local a10 = 0
	local a11 = 0
	local a12 = 0
	local a13 = 0
	
	local t = p.takistable.io
	local tay = p.takistable
	
	a1 = t.nostrafe
	a2 = t.nohappyhour
	a3 = t.happyhourstyle
	a4 = t.morehappyhour
	t1 = tay.tauntquick1
	t2 = tay.tauntquick2
	a5 = t.tmcursorstyle
	a6 = t.quakes
	a7 = t.flashes
	a8 = '_'
	a9 = t.additiveai
	a10 = t.ihavemusicwad
	a11 = t.clutchstyle
	a12 = t.sharecombos
	a13 = t.dontshowach
	
	if io
		DEBUG_print(p,"Using I/O, Writing")
		
		t.hasfile = true
		
		local file = io.openlocal("client/takisthefox/config.dat", "w+")
		file:write(" "..a1.." "..a2.." "..a3.." "..a4.." "..t1.." "
			..t2.." "..a5.." "..a6.." "..a7.." "..a8.." "..a9.." "
			..a10.." "..a11.." "..a12.." "..a13
		)
		
		if not silent
			CONS_Printf(p, "\x82Saved "..skins[TAKIS_SKIN].realname.."' settings!")
		end
			
		file:close()
		
	end
end)

rawset(_G, "TakisLoadStuff", function(p)
	
	if p.takistable.io.loaded
		return
	end
	
	if io --load savefile
		DEBUG_print(p,"Using I/O, Loading")
		
		local file = io.openlocal("client/takisthefox/config.dat")
		
		
		//load file
		if file 
		
			p.takistable.io.hasfile = true

			local code = file:read("*a")
			
			if code ~= nil and not (string.find(code, ";"))
				COM_BufInsertText(p, "takis_load "..code)
				p.takistable.io.loaded = true
			end
		
			file:close()
		
		else
		
			p.takistable.HUD.cfgnotifstuff = 6*TR+18
			//whatever...
			p.takistable.io.loaded = true
			
		end
		
	end
end)

filesdone = $+1
