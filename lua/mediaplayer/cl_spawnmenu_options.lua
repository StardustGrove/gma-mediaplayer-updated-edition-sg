
local function CreateSpacer(parent, height)
	if (height == nil) then height = 10 end
	
	local spacer = vgui.Create("DLabel", parent)
	spacer:Dock(TOP)
	spacer:SetText("")
	spacer:SetHeight(height)
	
	return spacer
end


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
			
			
			--// Video resolution
			local cvar_mediaplayer_resolution = GetConVar("mediaplayer_resolution")
			
			local resolutionCB = form:ComboBox("Video resolution", "mediaplayer_resolution")
			resolutionCB:SetSortItems(false)
			
			-- Lots of boilerplate is needed here to make the DComboBox control not blow ass and actually stay synced with the convar
			local cvar_mediaplayer_resolution_ValueAtLastCbItemRebuild = nil
			
			local function rebuildResolutionCbItems()
				resolutionCB:Clear()
				
				--// Standard resolutions (height-based)
				local standardCbItems = {
					{ 240, "240" }, -- value, display text
					{ 360, "360" },
					{ 480, "480" },
					{ 540, "540" },
					{ 720, "720" },
					{ 960, "960" },
					{ 1080, "1080" },
				}
				local defaultCbItemValue = 480
				
				local standardCbValueLookup = {}
				for _, itemInfo in ipairs(standardCbItems) do
					standardCbValueLookup[ itemInfo[1] ] = true
				end
				
				--// Custom non-standard resolution in the user's cvar (if any)
				local includeUserRes = false
				local userRes = cvar_mediaplayer_resolution:GetInt()
				if (userRes ~= nil and userRes >= 32 and userRes <= 4096) then
					defaultCbItemValue = userRes
					if (standardCbValueLookup[userRes] ~= true) then
						includeUserRes = true -- When the user has specified a VALID non-standard resolution for their cvar, we'll add that to the combobox so they can keep using that value (otherwise the combobox's behavior will CHANGE the user's cvar value to the default item)
					end
				end
				
				--// Add items to combobox
				for _, itemInfo in pairs(standardCbItems) do
					local value = itemInfo[1]
					local displayText = itemInfo[2]
					resolutionCB:AddChoice( displayText, value, (defaultCbItemValue == value) )
				end
				
				if (includeUserRes) then
					resolutionCB:AddChoice("User Custom: " .. tostring(userRes), userRes, (defaultCbItem == "userRes"))
				end
			end
			
			function resolutionCB:Think()
				--// We are replacing the existing Think() method here, which only calls self:CheckConVarChanges() and does nothing else, which is not good enough. A simple call like that is unaware of the need to rebuild the combobox items to include the newly changed user's custom value (if any).
				local cvar_mediaplayer_resolution_Value = cvar_mediaplayer_resolution:GetInt()
				
				if (cvar_mediaplayer_resolution_ValueAtLastCbItemRebuild == nil or cvar_mediaplayer_resolution_ValueAtLastCbItemRebuild ~= cvar_mediaplayer_resolution_Value) then
					cvar_mediaplayer_resolution_ValueAtLastCbItemRebuild = cvar_mediaplayer_resolution_Value
					
					rebuildResolutionCbItems()
					
					for itemIndex, data in ipairs(self.Data) do -- DComboBox's interface sucks and has no built-in function to do this
						if (data == cvar_mediaplayer_resolution_Value) then
							resolutionCB:ChooseOptionID(itemIndex)
							break
						end
					end
				end
			end
			
			form:ControlHelp("Render resolution when playing videos.")
			form:ControlHelp("- DVD resolution is 480.")
			form:ControlHelp("- HD resolution is 720.")
			form:ControlHelp("- FHD resolution is 1080.")
			form:ControlHelp("WARNING: Resolutions above 480 may significantly affect your framerate!")
			form:ControlHelp("Changing this value only takes effect after you turn a Media Player off then back on again.")
			
			CreateSpacer(form)
			
			--// Audio volume
			--local cvar_mediaplayer_volume = GetConVar("mediaplayer_volume") -- For some stupid reason, there is no min or max defined for this cvar
			--form:NumSlider("Audio volume", "mediaplayer_volume", cvar_mediaplayer_volume:GetMin(), cvar_mediaplayer_volume:GetMax(), 2)
			form:NumSlider("Audio volume", "mediaplayer_volume", 0, 1, 2) -- so we have to assume a reasonable range instead
			form:ControlHelp("Sound volume level for all Media Players.")
			
			--// Audio fade out range
			form:NumSlider("Audio fade out start", "mediaplayer_proximity_min", 0, 10000, 0) -- these cvars also do not have any range defined, so have to assume one
			form:NumSlider("Audio fade out end", "mediaplayer_proximity_max", 0, 10000, 0) -- ^
			form:ControlHelp("Range where Media Players' audio will start to fade out, as you get farther away from them.")
			
			CreateSpacer(form)
			
			--// 3D BASS audio
			form:CheckBox("Enable 3D audio", "mediaplayer_3daudio")
			form:ControlHelp("Enables realistic directional sound from Media Players. ONLY WORKS WHEN PLAYING AUDIO FILES! (not videos)")
			
			CreateSpacer(form)
			
			--// Mute when unfocused
			form:CheckBox("Mute when unfocused", "mediaplayer_mute_unfocused")
			form:ControlHelp("Mutes all Media Players when Garry's Mod is not focused.")
			
			CreateSpacer(form)
			
			--// Show media thumbnails
			form:CheckBox("Show media thumbnails", "mediaplayer_draw_thumbnails")
			form:ControlHelp("Show thumbnails for supported media types on Media Players which are turned off.")
			
			CreateSpacer(form)
			
			--// Enable mouse input on media player screens
			form:CheckBox("Enable mouse input on screens", "mediaplayer_enable_screen_mouse_input")
			form:ControlHelp("Enables clicking and scrolling on media player screens, while looking at them and holding your context menu keybind (C by default).")
			form:ControlHelp("Tip: Disable this in order to prevent accidentally pausing videos when clicking on the screen.")
			
			CreateSpacer(form, 20)
			
			local resetAll = form:Button("Reset all to defaults")
			resetAll.DoClick = function()
				--// Only reset the cvars that are shown in this panel
				local cvars = {
					MediaPlayer.Cvars.Resolution,
					MediaPlayer.Cvars.Audio3D,
					MediaPlayer.Cvars.Volume,
					MediaPlayer.Cvars.MuteUnfocused,
					MediaPlayer.Cvars.DrawThumbnails,
					MediaPlayer.Cvars.ProximityMin,
					MediaPlayer.Cvars.ProximityMax,
					MediaPlayer.Cvars.EnableScreenMouseInput,
				}
				for _, cvar in ipairs(cvars) do
					cvar:Revert()
				end
			end
			
		end
	)
	
end


hook.Add("PopulateToolMenu", "MediaPlayer_PopulateToolMenu", function()
	RegisterOptionsMenu()
end)
