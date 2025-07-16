local function RegisterOptionsMenu()
	
	spawnmenu.AddToolMenuOption(
		"Options", -- tab name
		"Media Player", -- expander name
		"MediaPlayer_MainOptionsMenu_Main", -- unique "class" name for expander item
		"Settings", -- expander item name
		"", -- "Command to execute when the item is selected" (ignore)
		"", -- "Config name, used in older versions to load tool settings UI from a file. No longer works." (ignore)
		function (form) -- panel layout function; param form is a DForm
			form:Clear()
			
			
			local resolutionCB = form:ComboBox("Video resolution", "mediaplayer_resolution")
			resolutionCB:SetSortItems(false)
			resolutionCB:AddChoice("240", 240)
			resolutionCB:AddChoice("360", 360)
			resolutionCB:AddChoice("480", 480, true) -- default
			resolutionCB:AddChoice("540", 540)
			resolutionCB:AddChoice("720", 720)
			resolutionCB:AddChoice("960", 960)
			resolutionCB:AddChoice("1080", 1080)
			form:ControlHelp("Render resolution when playing videos.")
			form:ControlHelp("- DVD resolution is 480.")
			form:ControlHelp("- HD resolution is 720.")
			form:ControlHelp("- FHD resolution is 1080.")
			form:ControlHelp("WARNING: Resolutions above 480 may significantly affect your framerate!")
			form:ControlHelp("Changing this value only takes effect after you turn a Media Player off then back on again.")
			
			--local cvar_mediaplayer_volume = GetConVar("mediaplayer_volume") -- For some stupid reason, there is no min or max defined for this cvar
			--form:NumSlider("Audio volume", "mediaplayer_volume", cvar_mediaplayer_volume:GetMin(), cvar_mediaplayer_volume:GetMax(), 2)
			form:NumSlider("Audio volume", "mediaplayer_volume", 0, 1, 2) -- so we have to assume a reasonable range instead
			form:ControlHelp("Sound volume level for all Media Players.")
			
			form:CheckBox("Enable 3D audio", "mediaplayer_3daudio")
			form:ControlHelp("Enables realistic directional sound from Media Players. ONLY WORKS WHEN PLAYING AUDIO FILES! (not videos)")
			
			form:CheckBox("Mute when unfocused", "mediaplayer_mute_unfocused")
			form:ControlHelp("Mutes all Media Players when Garry's Mod is not focused.")
			
			form:CheckBox("Show media thumbnails", "mediaplayer_draw_thumbnails")
			form:ControlHelp("Show thumbnails for supported media types on Media Players which are turned off")
			
		end
	)
	
end

hook.Add("PopulateToolMenu", "MediaPlayer_PopulateToolMenu", function()
	RegisterOptionsMenu()
end)
