--[[----------------------------------------------------------------------------
	Media Player client configuration
------------------------------------------------------------------------------]]
MediaPlayer.SetConfig({

	---
	-- HTML content
	--
	html = {

		---
		-- Base URL where HTML content is located.
		-- @type String
		--
		base_url = "https://purrcoding.github.io/gm-mediaplayer/"

	},

	---
	-- Request menu
	--
	request = {

		---
		-- URL of the request menu.
		-- @type String
		--
		url = "https://purrcoding.github.io/gm-mediaplayer/request.html"

	},

	---
	-- YoutTube player
	--
	youtube = {

		---
		-- URL where the YouTube player is located.
		-- @type String
		--
		url = "https://purrcoding.pages.dev/mediaplayer/youtube.html",
		url_meta = "https://purrcoding.pages.dev/mediaplayer/youtube_meta.html",

		-- Note to developers: if you want to host it yourself, 
		-- don't use GitHub Pages for this, otherwise the ads may appear more frequently!
	}

})
