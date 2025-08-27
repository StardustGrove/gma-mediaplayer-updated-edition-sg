include "shared.lua"

DEFINE_BASECLASS( "mp_service_browser" )

local APIUrl = "https://groovyexpress.tv"

local JS_Pause = "if(window.MediaPlayer) MediaPlayer.pause();"
local JS_Play = "if(window.MediaPlayer) MediaPlayer.play();"
local JS_Volume = "if(window.MediaPlayer) MediaPlayer.volume = %s;"
local JS_Seek = [[
	if (window.MediaPlayer) {
		var seekTime = %s;
		var curTime = window.MediaPlayer.currentTime;

		var diffTime = Math.abs(curTime - seekTime);
		if (diffTime > 5) {
			window.MediaPlayer.currentTime = seekTime
		}
	}
]]

local MimeTypes = {
	webm = "video/webm",
	mp4 = "video/mp4",
}

local EmbedHTML = [[
	<video id="player" autoplay style="
			width: 100%%;
			height: 100%%;">
		<source src="%s" type="%s">
	</video>

	<script>
		var checkerInterval = setInterval(function() {
			var player = document.getElementsByTagName("VIDEO")[0]
			if (!!player) {
				if (player.paused) {player.play();}
				if (player.paused === false && player.readyState === 4) {
					clearInterval(checkerInterval);

					window.MediaPlayer = player;
					player.style = "width:100%%; height: 100%%;";
				}
			}
		}, 50);
	</script>
]]

function SERVICE:OnBrowserReady( browser )

	-- Resume paused player
	if self._BCPaused then
		self.Browser:RunJavascript( JS_Play )
		self._BCPaused = nil
		return
	end

	BaseClass.OnBrowserReady( self, browser )

	local videoId = self:GetGroovyExpressTvVideoId()

	http.Fetch(APIUrl .. "/posts/" .. videoId .. ".json", function(body, length, headers, code)
		if not body or code ~= 200 then
			print(("Not expected response received from GroovyExpressTV (Code: %d)"):format(code))
			return
		end

		local response = util.JSONToTable( body )
		if not response then
			print("Failed to parse GroovyExpressTV API response")
			return
		end

		local samples = response.post.sample.alternates
		local resolution = MediaPlayer.Cvars.Resolution:GetString()
		if not samples then
			print("Failed to get video metadata from GroovyExpressTV API")
			return
		end

		local url = self.url

		-- webm low res
		if samples.samples_webm and samples.samples_webm[resolution] then
			url = samples.samples_webm[resolution]["url"]

		-- webm full res
		elseif samples.variants and samples.variants.webm then
			url = samples.variants.webm.url
			-- groovyexpresstv bug
			url = string.Replace(url, "mp4", "webm")
		elseif samples.original and (samples.original.codec == "av01.0.00M.08" or samples.original.codec == "vp9") then
			url = samples.original.url

		-- mp4 low res
		elseif samples.samples and samples.samples[resolution] then
			url = samples.samples[resolution]["url"]

		-- mp4 full res
		elseif samples.variants and samples.variants["mp4"] then
			url = samples.variants["mp4"]["url"]
		else
			url = samples.original.url
		end

		local urlext = string.Split(url, "/")[8] or string.Split(url, "/")[7]
		local ext = string.match(urlext, "%.(%S+)$")
		local mime = MimeTypes[ext]
		local html = EmbedHTML:format(url, mime)
		html = self.WrapHTML( html )

		self.Browser:SetHTML( html )
	end, function(error)
		print(false, "Failed to fetch GroovyExpressTV video metadata: " .. tostring(err))
	end, {})
end

function SERVICE:Pause()
	BaseClass.Pause( self )

	if IsValid(self.Browser) then
		self.Browser:RunJavascript(JS_Pause)
		self._BCPaused = true
	end

end

function SERVICE:SetVolume( volume )
	local js = JS_Volume:format( volume )
	self.Browser:RunJavascript(js)
end

function SERVICE:Sync()

	local seekTime = self:CurrentTime()
	if IsValid(self.Browser) and self:IsTimed() and seekTime > 0 then
		self.Browser:RunJavascript(JS_Seek:format(seekTime))
	end
end