rawset(_G, "TAKIS_MENU",{})
local tm = TAKIS_MENU

tm.entries = {
	[0] = {
		title = "Takis Help",
		color = SKINCOLOR_CLOUDY,
		curcolor = SKINCOLOR_SUPERGOLD4,
		icon = "MISSING",
		text = {
			"Menu Help",
			"Takis Manual",
			"Important Letter",
		},
		commands = {
			"showmenuhints",
			"instructions",
			"importantletter",
		}
	},
	//hardcoded so you cant mess with it
	[1] = {
		title = "Achievements",
		color = SKINCOLOR_CARBON,
		nocursor = true,
		icon = "MISSING",
		text = {},
	},
	[2] = {
		title = "Takis Options",
		color = SKINCOLOR_CLOUDY,
		curcolor = SKINCOLOR_SUPERGOLD4,
		icon = "MISSING",
		text = {
			"No Strafe",
			"No Happy Hour",
			"Happy Hour Style",
			"More Happy Hour",
			"Taunt Menu Cursor",
			"Quakes",
			"Flashes",
			"Additive Afterimages",
			"I have the Music Wad!",
		},
		table = "takis.io",
		values = {
			"nostrafe",
			"nohappyhour",
			"happyhourstyle",
			"morehappyhour",
			"tmcursorstyle",
			"quakes",
			"flashes",
			"additiveai",
			"ihavemusicwad",
		},
		commands = {
			"nostrafe",
			"nohappyhour",
			"happyhourstyle",
			"morehappyhour",
			"tauntmenucursor",
			"quakes",
			"flashes",
			"additiveafterimages",
			"ihavethemusicwad",
		}
	},
	[3] = {
		title = "I/O Stuff",
		color = SKINCOLOR_CLOUDY,
		curcolor = SKINCOLOR_SUPERGOLD4,
		icon = "MISSING",
		text = {
			"Save Config",
			"Load Config",
			"Delete Achievements",
			"$$$$$",
		},
		commands = {
			"saveconfig",
			"loadconfig",
			"deleteachievements",
		}
	},
	[4] = {
		title = "Net Stuff",
		color = SKINCOLOR_GOLD,
		text = {
			"Don't Speed Boost",
			"Loud Taunts",
			"Tauntkills",
		},
		values = {
			"dontspeedboost",
			"loudtauntsenabled",
			"tauntkillsenabled",
		},
		commands = {
			"speedboosts",
			"loudtaunts",
			"tauntkills",
		}
	}
}

for i = 1,NUMACHIEVEMENTS
	if i > 7
		return
	end
	table.insert(tm.entries[1].text,'')
end

/*
rawset(_G,"Takis_AddMenuPage",function(title,color,text,table,value,commands)
	if not title
		error("arg1 (title) must be valid")
	end
	if not color
		error("arg2 (bg color) must be valid")
	end
	
	
	title = tostring($)
	
	
end)
*/

filesdone = $+1
