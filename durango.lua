--
-- Xbox One XDK support for Visual Studio backend.
-- Copyright Blizzard Entertainment, Inc
--

--
-- Non-overrides
--

local p = premake
local vstudio = p.vstudio
local vc2010 = p.vstudio.vc2010

p.DURANGO     = "durango"

if vstudio.vs2010_architectures ~= nil then
	vstudio.vs2010_architectures.durango = "Durango"
	p.api.addAllowed("system", p.DURANGO)

	os.systemTags[p.DURANGO] = { "durango", "xboxone_xdk", "xboxone", "xdk", "xbox", "console" }

	local osoption = p.option.get("os")
	if osoption ~= nil then
		table.insert(osoption.allowed, { p.DURANGO,  "Xbox One (XDK)" })
	end
end


filter { "system:Durango" }
	architecture "x86_64"

filter { "system:Durango", "kind:ConsoleApp or WindowedApp" }
	targetextension ".exe"

filter { "system:Durango", "kind:StaticLib" }
	targetprefix ""
	targetextension ".lib"

filter {}

--
-- Properties
--

p.api.register {
	name = "compileaswinrt",
	scope = "config",
	kind = "boolean"
}


--
-- Methods.
--

local function winrt(cfg)
	vc2010.element("CompileAsWinRT", nil, iif(cfg.compileaswinrt, "true", "false"))
end

--
-- Overrides
--

p.override(vc2010.elements, "clCompile", function(base, cfg)
	local calls = base(cfg)

	if cfg.system == p.DURANGO and (cfg.kind == p.CONSOLEAPP or cfg.kind == p.WINDOWEDAPP) then
		table.insert(calls, winrt)
	end

	return calls
end)
