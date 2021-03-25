--
-- Xbox One GDK support for Visual Studio backend.
-- Copyright Blizzard Entertainment, Inc
--

--
-- Non-overrides
--

local p = premake
local vstudio = p.vstudio
local vc2010 = p.vstudio.vc2010

p.XBOXONE_GDK     = "xboxone_gdk"

if vstudio.vs2010_architectures ~= nil then
	vstudio.vs2010_architectures.xboxone_gdk = "Gaming.Xbox.XboxOne.x64"
	p.api.addAllowed("system", p.XBOXONE_GDK)

	os.systemTags[p.XBOXONE_GDK] = { "xboxone_gdk", "xboxone", "gdk", "xbox", "console" }

	local osoption = p.option.get("os")
	if osoption ~= nil then
		table.insert(osoption.allowed, { p.XBOXONE_GDK,  "Xbox One (GDK)" })
	end
end


filter { "system:xboxone_gdk" }
	architecture "x86_64"

filter { "system:xboxone_gdk", "kind:ConsoleApp or WindowedApp" }
	targetextension ".exe"

filter { "system:xboxone_gdk", "kind:StaticLib" }
	targetprefix ""
	targetextension ".lib"

filter {}
