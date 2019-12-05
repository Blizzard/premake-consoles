--
-- Add Xbox GDK support to Visual Studio backend.
-- Copyright (c) 2015-2019 Blizzard Entertainment
--

--
-- Non-overrides
--

local p = premake
local vstudio = p.vstudio
local vc2010 = p.vstudio.vc2010
local config = p.config

p.XBOXONE_GDK     = "xboxone_gdk"

if vstudio.vs2010_architectures ~= nil then
	vstudio.vs2010_architectures.xboxone_gdk = "Gaming.Xbox.x64"
	p.api.addAllowed("system", p.XBOXONE_GDK)

	os.systemTags[p.XBOXONE_GDK] = { "xboxone_gdk", "gdk", "xboxone", "console" }

	local osoption = p.option.get("os")
	if osoption ~= nil then
		table.insert(osoption.allowed, { p.XBOXONE_GDK,  "Xbox One (GDK)" })
	end
end


filter { "system:xboxone_gdk", "kind:ConsoleApp or WindowedApp" }
	targetextension ".exe"

filter { "system:xboxone_gdk", "kind:StaticLib" }
	targetprefix ""
	targetextension ".lib"

--
-- Methods.
--

local function hasXboxOneGdkConfig(prj)
	for cfg in p.project.eachconfig(prj) do
		if cfg.system == p.XBOXONE_GDK then
			return true
		end
	end
	return false
end

local function gdkConfig(prj)
	vc2010.element("DefaultLanguage", nil, "en-US")
	vc2010.element("TargetRuntime", nil, "Native")
end

--
-- Overrides
--

p.override(vc2010.elements, "globals", function(base, prj)
	local calls = base(prj)

	if hasXboxOneGdkConfig(prj) then
		table.insert(calls, gdkConfig)
	end

	return calls
end)

p.override(vc2010, "additionalDependencies", function(base, cfg, explicit)
	-- Remove %(AdditionalDependencies) as that references Win32 libraries that aren't supported
	if cfg.system ~= p.XBOXONE_GDK then
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

	if cfg.project.kind ~= p.STATICLIB then
		links[#links + 1] = "$(Console_Libs);%(XboxExtensionsDependencies)"
		links = path.translate(table.concat(links, ";"))
		vc2010.element("AdditionalDependencies", nil, "%s", links)
	end
end)

p.override(vc2010, "generateManifest", function(base, cfg)
	if cfg.system ~= p.XBOXONE_GDK then
		return base(cfg)
	end

	if cfg.project.kind == p.CONSOLEAPP or cfg.project.kind == p.WINDOWEDAPP then
		vc2010.element("EmbedManifest", nil, "false")
		vc2010.element("GenerateManifest", nil, "false")
	end
end)

p.override(vc2010, "ignoreDefaultLibraries", function(base, cfg)
	if cfg.system ~= p.XBOXONE_GDK then
		return base(cfg)
	end

	-- TODO: This explicit list can go away in a future GDK release. The defaults are currently not sufficient
	if cfg.project.kind == p.CONSOLEAPP or cfg.project.kind == p.WINDOWEDAPP then
		vc2010.element("IgnoreSpecificDefaultLibraries", nil, "$(IgnoreSpecificDefaultLibraries);advapi32.lib;comctl32.lib;comsupp.lib;dbghelp.lib;gdi32.lib;gdiplus.lib;guardcfw.lib;kernel32.lib;mmc.lib;msimg32.lib;msvcole.lib;msvcoled.lib;mswsock.lib;ntstrsafe.lib;ole2.lib;ole2autd.lib;ole2auto.lib;ole2d.lib;ole2ui.lib;ole2uid.lib;ole32.lib;oleacc.lib;oleaut32.lib;oledlg.lib;oledlgd.lib;oldnames.lib;runtimeobject.lib;shell32.lib;shlwapi.lib;strsafe.lib;urlmon.lib;user32.lib;userenv.lib;wlmole.lib;wlmoled.lib;onecore.lib")
	end
end)
