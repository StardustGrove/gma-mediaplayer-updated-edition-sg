SERVICE.Name	= "HTML5 Video"
SERVICE.Id		= "h5v"
SERVICE.Base	= "res"

SERVICE.PrefetchMetadata = true

SERVICE.FileExtensions = {
	"webm",
	"mp4",
}

DEFINE_BASECLASS( "mp_service_base" )

function SERVICE:IsTimed()
	if self._istimed == nil then
		self._istimed = self:Duration() > 0
	end

	return self._istimed
end

if CLIENT then

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
		<video id="player" autoplay loop style="
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

	function SERVICE:GetHTML()
		local url = self.url

		local path = self.urlinfo.path
		local ext = path:match("[^/]+%.(%S+)$")

		local mime = MimeTypes[ext]

		return EmbedHTML:format(url, mime)
	end

	function SERVICE:Pause()
		BaseClass.Pause( self )

		if IsValid(self.Browser) then
			self.Browser:RunJavascript(JS_Pause)
		end

	end
	
	function SERVICE:SetVolume( volume )
		if (IsValid(self.Browser)) then
			volume = math.Clamp( volume + (math.random() * 0.0001), 0, 1 )
			local js = JS_Volume:format( volume )
			self.Browser:RunJavascript(js)
		end
	end

	function SERVICE:Sync()
		if (IsValid(self.Browser)) then
			local seekTime = self:CurrentTime()
			if self:IsTimed() and seekTime > 0 then
				self.Browser:RunJavascript(JS_Seek:format(seekTime))
			end
		end
	end

	function SERVICE:IsMouseInputEnabled()
		return IsValid( self.Browser )
	end

	function SERVICE:PreRequest( callback )
		MediaPlayerUtils.GatherVideoDuration( self.url, function(success, response)

			if success then
				self._metaDuration = response
				callback()

				return
			end

			callback(response)
		end )
	end

	function SERVICE:NetWriteRequest()
		net.WriteUInt( self._metaDuration, 16 )
	end

end

if SERVER then
	function SERVICE:GetMetadata( callback )

		if self._metadata then
			callback( self._metadata )
			return
		end

		local cache = MediaPlayer.Metadata:Query(self)

		if MediaPlayer.DEBUG then
			print("MediaPlayer.GetMetadata Cache results:")
			PrintTable(cache or {})
		end

		if cache then

			local metadata = {}
			metadata.title = cache.title
			metadata.duration = tonumber(cache.duration)
			metadata.thumbnail = cache.thumbnail

			self:SetMetadata(metadata)
			MediaPlayer.Metadata:Save(self)

			callback(self._metadata)

		else
			local metadata = {}

			metadata.title = self.url
			metadata.duration = self._metaDuration

			self:SetMetadata(metadata, true)
			MediaPlayer.Metadata:Save(self)

			callback(self._metadata)
		end
	end

	function SERVICE:NetReadRequest()

		if not self.PrefetchMetadata then return end

		self._metaDuration = net.ReadUInt( 16 )

	end
end