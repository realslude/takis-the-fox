// "Terrible Character..."

if (VERSION == 202) and (SUBVERSION < 12)
	local special = P_RandomChance(FRACUNIT/13)

	local function deprecated(v)
	
		v.fadeScreen(0xFF00, 20)
		v.drawString(130, 60, "Your copy of SRB2 outdated!",V_ORANGEMAP|V_ALLOWLOWERCASE, "thin")
		v.drawString(130, 60+8, "This mod requires 2.2.12+,",V_ORANGEMAP|V_ALLOWLOWERCASE, "thin")
		v.drawString(130, 60+8+8, "please update your game!",V_ORANGEMAP|V_ALLOWLOWERCASE, "thin")
		
		local patch = v.cachePatch("PIRATESOAP")
		local size = FU/5
		local x = 0
		
		if special
			patch = v.cachePatch("HOLYMOLY")
			size = 3*FU/5
			x = 30*FU
		end
		
		v.drawScaled(50*FU+x, 35*FU, size, patch)
	end
	hud.add(deprecated, "title")
	hud.add(deprecated, "game")
	
	error("\x85".."Your copy of 2.2 (".."2.2."..SUBVERSION..") is too outdated for this mod.\x80", 0)
	return
end



//rawset(_G, "TAKIS_BUILDTIME", "9:44:31 PM")
//rawset(_G, "TAKIS_BUILDDATE", "9/26/2023")



local guh = {
	"init",
}
local filelistt1 = {
	"CustomHud",
	"achievements",
	"functions",
	"taunts",
	"menu",
	"happyhour",
}
local filelist = {
	"io",
	"main",
	"hud",
	"cmds",
	"misc",
	"MOTD",
}

rawset(_G, "filesdone", 0)
rawset(_G, "NUMFILES", (#guh)+(#filelistt1)+(#filelist) )

local function dofile2(file)
	dofile(file)
end


rawset(_G, "takis_printdebuginfo",function(p)
	if not p
		print("\x82".."Extra Debug Stuff:\n"..
			/*
			"\x8D".."Build Date (MM/DD/YYYY) = \x80"..TAKIS_BUILDDATE.."\n"..
			"\x8D".."Build Time = \x80"..TAKIS_BUILDTIME.."\n"..
			*/
			"\x8D".."# of files done = \x80"..filesdone.."/"..NUMFILES.."\n"
			
		)	
	else
		CONS_Printf(p,"\x82".."Extra Debug Stuff:\n"..
			/*
			"\x8D".."Build Date (MM/DD/YYYY) = \x80"..TAKIS_BUILDDATE.."\n"..
			"\x8D".."Build Time = \x80"..TAKIS_BUILDTIME.."\n"..
			*/
			"\x8D".."# of files done = \x80"..filesdone.."/"..NUMFILES.."\n"..
			
			"\n".."\x8D".."Used a Player for this".."\n"
		)	
	end
end)

rawset(_G, "takis_printwarning",function(p)
	if not p
		print("\x82This is free for anyone to host!\n"..
			"Please send feedback and bug reports to \x83luigibudd\x82 on Discord!"
			
		)	
	else
		CONS_Printf(p,"\x82This is free for anyone to host!\n"..
			"Please send feedback and bug reports to \x83luigibudd\x82 on Discord!"
		)	
	end
	
end)



//the file stuff
local pre = "LUA_"

for k,v in ipairs(guh)
	dofile2(pre..v)
end

for k,v in ipairs(filelistt1)
	dofile2("libs/".. pre..v)
	dofile2("libs/".. pre..v)
end

for k,v in ipairs(filelist)
	dofile2(pre..v)
end

//!?!?
//filesdone = $-1


print("Did init.lua\n")

takis_printdebuginfo()
takis_printwarning()
