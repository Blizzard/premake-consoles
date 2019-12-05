--
-- Add Durango support to Visual Studio backend.
-- Copyright (c) 2015-2017 Blizzard Entertainment
--

--
-- Non-overrides
--

local p = premake
local vstudio = p.vstudio
local config = p.config

p.DURANGO     = "durango"

if vstudio.vs2010_architectures ~= nil then
	vstudio.vs2010_architectures.durango = "Durango"
	p.api.addAllowed("system", p.DURANGO)

	os.systemTags[p.DURANGO] = { "durango", "xboxone", "console" }

	local osoption = p.option.get("os")
	if osoption ~= nil then
		table.insert(osoption.allowed, { p.DURANGO,  "Xbox One" })
	end
end


filter { "system:Durango", "kind:ConsoleApp or WindowedApp" }
	targetextension ".exe"

filter { "system:Durango", "kind:StaticLib" }
	targetprefix ""
	targetextension ".lib"

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

local function hasXboxConfig(prj)
	for cfg in p.project.eachconfig(prj) do
		if cfg.system == p.DURANGO then
			return true
		end
	end
	return false
end

local function xdkConfig(prj)
	vstudio.vc2010.element("DefaultLanguage", nil, "en-US")
	vstudio.vc2010.element("ApplicationEnvironment", nil, "title")
	vstudio.vc2010.element("TargetRuntime", nil, "Native")
end

local function winrt(cfg)
	if cfg.compileaswinrt ~= nil then
		vstudio.vc2010.element("CompileAsWinRT", nil, iif(cfg.compileaswinrt, "true", "false"))
	end
end

--
-- Overrides
--

p.override(vstudio.vc2010.elements, "globals", function(base, prj)
	local calls = base(prj)

	if hasXboxConfig(prj) then
		table.insert(calls, xdkConfig)
	end

	return calls
end)

p.override(vstudio.vc2010.elements, "clCompile", function(base, cfg)
	local calls = base(cfg)

	if cfg.system == p.DURANGO and (cfg.kind == p.CONSOLEAPP or cfg.kind == p.WINDOWEDAPP) then
		table.insert(calls, winrt)
	end

	return calls
end)

p.override(vstudio.vc2010, "additionalDependencies", function(base, cfg, explicit)
	-- Remove %(AdditionalDependencies) as that references Win32 libraries that aren't supported
	if cfg.system ~= p.DURANGO then
		return base(cfg, explicit)
	end

	local links

	-- check to see if this project uses an external toolset. If so, let the
	-- toolset define the format of the links
	local toolset = config.toolset(cfg)
	if toolset then
		links = toolset.getlinks(cfg, not explicit)
	else
		links = vstudio.getLinks(cfg, explicit)
	end

	if #links > 0 then
		links = path.translate(table.concat(links, ";"))
		vstudio.vc2010.element("AdditionalDependencies", nil, "%s", links)
	end
end)
