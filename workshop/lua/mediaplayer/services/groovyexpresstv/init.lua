AddCSLuaFile "shared.lua"
include "shared.lua"

local APIUrl = "https://groovyexpress.tv"

function SERVICE:GetMetadata( callback )
	if self._metadata then
		callback( self._metadata )
		return
	end

	local cache = MediaPlayer.Metadata:Query(self)

	if cache then
		local metadata = {}
		metadata.title = cache.title
		metadata.duration = tonumber(cache.duration)
		metadata.thumbnail = cache.thumbnail

		self:SetMetadata(metadata)
		MediaPlayer.Metadata:Save(self)
		callback(self._metadata)
	else
		local videoId = self:GetGroovyExpressTvVideoId()

		self:FetchVideoAPI( videoId, callback )
	end
end

function SERVICE:FetchVideoAPI( videoId, callback )
	local request = {
		url = APIUrl .. "/posts/" .. videoId .. ".json",
		method = "GET",

		success = function( code, body, headers )
			if MediaPlayer.DEBUG then
				print("GroovyExpressTV Video API Results["..code.."]:", APIUrl)
				print(body)
			end

			local response = util.JSONToTable( body )
			if not response then
				callback(false, "Failed to parse GroovyExpressTV API response")
				return
			end

			local metadata = self:ParseVideoAPIResponse(response)

			if not metadata.title then
				callback(false, "Failed to get video metadata from GroovyExpressTV API")
				return
			end

			self:SetMetadata(metadata, true)
			MediaPlayer.Metadata:Save(self)
			callback(self._metadata)
		end,

		failed = function( err )
			callback(false, "Failed to fetch GroovyExpressTV video metadata: " .. tostring(err))
		end
	}

	if MediaPlayer.DEBUG then
		print("GroovyExpressTV Video API Request for ID:", videoId)
		PrintTable(request)
	end

	HTTP(request)
end

function SERVICE:ParseVideoAPIResponse( response )
	local metadata = {}

	if response.post.title then
		metadata.title = response.post.title
	end

	if response.post.preview and response.post.preview.url then
		metadata.thumbnail = response.post.preview.url
	end

	if response.post.duration then
		metadata.duration = response.post.duration
	end

	return metadata
end
