--
-- Xbox Series X/S support for Visual Studio backend.
-- Copyright Blizzard Entertainment, Inc
--

--
-- Non-overrides
--

local p = premake
local vstudio = p.vstudio
local vc2010 = p.vstudio.vc2010
local config = p.config

p.SCARLETT     = "scarlett"

if vstudio.vs2010_architectures ~= nil then
	vstudio.vs2010_architectures.scarlett = "Gaming.Xbox.Scarlett.x64"
	p.api.addAllowed("system", p.SCARLETT)

	os.systemTags[p.SCARLETT] = { "scarlett", "xbox", "gdk", "console" }

	local osoption = p.option.get("os")
	if osoption ~= nil then
		table.insert(osoption.allowed, { p.SCARLETT,  "Xbox Series X/S" })
	end
end


filter { "system:scarlett" }
	architecture "x86_64"

filter { "system:scarlett", "kind:ConsoleApp or WindowedApp" }
	targetextension ".exe"

filter { "system:scarlett", "kind:StaticLib" }
	targetprefix ""
	targetextension ".lib"

filter {}
