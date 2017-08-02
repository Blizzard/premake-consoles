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

	local os = p.option.get("os")
	if os ~= nil then
		table.insert(os.allowed, { p.DURANGO,  "Xbox One" })
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

local function xdkProperties(cfg)
	vstudio.vc2010.element("ReferencePath", nil, "$(Console_SdkLibPath);$(Console_SdkWindowsMetadataPath)")
	vstudio.vc2010.element("LibraryWPath", nil, "$(Console_SdkLibPath);$(Console_SdkWindowsMetadataPath)")
end

local function winrt(cfg)
	if cfg.compileaswinrt ~= nil then
		vstudio.vc2010.element("CompileAsWinRT", nil, iif(cfg.compileaswinrt, "true", "false"))
	end
end

local function deploy0(cfg, context)
	if not context.excluded and (context.prjCfg.kind == p.CONSOLEAPP or context.prjCfg.kind == p.WINDOWEDAPP) then
		p.x('{%s}.%s.Deploy.0 = %s|%s', context.prj.uuid, context.descriptor, context.platform, context.architecture)
	end
end

local function excludedFromBuild(filecfg, condition)
	if not filecfg
		or filecfg.flags.ExcludeFromBuild
		or filecfg.config.system ~= p.DURANGO then
			vstudio.vc2010.element("ExcludedFromBuild", condition, "true")
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

p.override(vstudio.vc2010.elements, "outputProperties", function(base, cfg)
	local calls = base(cfg)
	-- XDK Properties are only for XB1
	if cfg.system == p.DURANGO then
		table.insert(calls, xdkProperties)
	end
	return calls
end)

p.override(vstudio.vc2010, "libraryPath", function(base, cfg)
	if cfg.system ~= p.DURANGO then
		return base(cfg)
	end

	local dirs = vstudio.path(cfg, cfg.syslibdirs)
	table.insert(dirs, '$(Console_SdkLibPath)')
	vstudio.vc2010.element("LibraryPath", nil, "%s", table.concat(dirs, ";"))
end)

p.override(vstudio.vc2010, "includePath", function(base, cfg)
	if cfg.system ~= p.DURANGO then
		return base(cfg)
	end

	local dirs = vstudio.path(cfg, cfg.sysincludedirs)
	table.insert(dirs, '$(Console_SdkIncludeRoot)')
	vstudio.vc2010.element("IncludePath", nil, "%s", table.concat(dirs, ";"))
end)

p.override(vstudio.vc2010, "executablePath", function(base, cfg)
	if cfg.system ~= p.DURANGO then
		return base(cfg)
	end

	local dirs = vstudio.path(cfg, cfg.bindirs)
	table.insert(dirs, '$(Console_SdkRoot)bin')
	table.insert(dirs, '$(VCInstallDir)bin\\x86_amd64')
	table.insert(dirs, '$(VCInstallDir)bin')
	table.insert(dirs, '$(WindowsSDK_ExecutablePath_x86)')
	table.insert(dirs, '$(VSInstallDir)Common7\\Tools\\bin')
	table.insert(dirs, '$(VSInstallDir)Common7\\tools')
	table.insert(dirs, '$(VSInstallDir)Common7\\ide')
	table.insert(dirs, '$(ProgramFiles)\\HTML Help Workshop')
	table.insert(dirs, '$(MSBuildToolsPath32)')
	table.insert(dirs, '$(FxCopDir)')
	table.insert(dirs, '$(PATH)')

	vstudio.vc2010.element("ExecutablePath", nil, "%s", table.concat(dirs, ";"))
end)

p.override(vstudio.vc2010.elements, "clCompile", function(base, cfg)
	local calls = base(cfg)

	if cfg.system == p.DURANGO and (cfg.kind == p.CONSOLEAPP or cfg.kind == p.WINDOWEDAPP) then
		table.insert(calls, winrt)
	end

	return calls
end)

p.override(vstudio.sln2005.elements, "projectConfigurationPlatforms", function(base, cfg, context)
	local calls = base(cfg, context)
	-- XB1 - Enable "Deploy" in the configuration manager for executable targets
	if cfg.system == p.DURANGO then
		table.insert(calls, deploy0)
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
