/*	WIP Text Script

	Originally made by D00D64

	Modified to be displayed everywhere possible
	
	modified again to prevent those silly errors that say "mo is nil"
*/

local function wipRender(v, player)
	if not player.realmo
	or not player.mo
		return
	end
	
	if player.takistable.isTakis then
		if not G_RingSlingerGametype()
			v.drawString(160, 180, ("Work in Progress - indev0.0.1"),V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_30TRANS|V_REDMAP, "thin-center")
		else
			v.drawString(160, 160, ("Work in Progress - indev0.0.1"),V_SNAPTOBOTTOM|V_ALLOWLOWERCASE|V_30TRANS|V_REDMAP, "thin-center")
		end
	end
end

hud.add(wipRender, "game")
