DEFINE_BASECLASS( "mp_service_base" )

SERVICE.Name = "GroovyExpressTV"
SERVICE.Id = "groovyexpresstv"
SERVICE.Base = "browser"

function SERVICE:New( url )
	local obj = BaseClass.New(self, url)
	obj._data = obj:GetGroovyExpressTvVideoId()
	return obj
end

function SERVICE:Match( url )
	return string.match( url, "groovyexpress%.tv/posts/([%d]+)" ) ~= nil
end

function SERVICE:GetGroovyExpressTvVideoId()
	return string.match( self.url, "groovyexpress%.tv/posts/([%d]+)" )
end

function SERVICE:IsTimed()
	return true
end