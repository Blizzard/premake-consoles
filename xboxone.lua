--
-- Shared code for Xbox support to Visual Studio backend.
-- Copyright Blizzard Entertainment, Inc
--

local p = premake
local vstudio = p.vstudio
local vc2010 = p.vstudio.vc2010

--
-- Methods.
--

local function isXboxOneConfig(cfg)
	return (cfg.system == p.XBOXONE_GDK or cfg.system == p.DURANGO)
end

local function consoleProperties(cfg)
	vc2010.element("ReferencePath", nil, "$(Console_SdkLibPath);$(Console_SdkWindowsMetadataPath)")
	vc2010.element("LibraryWPath", nil, "$(Console_SdkLibPath);$(Console_SdkWindowsMetadataPath)")
end

local function deploy0(cfg, context)
	if not context.excluded and (context.prjCfg.kind == p.CONSOLEAPP or context.prjCfg.kind == p.WINDOWEDAPP) then
		p.x('{%s}.%s.Deploy.0 = %s|%s', context.prj.uuid, context.descriptor, context.platform, context.architecture)
	end
end

--
-- Overrides
--

p.override(vc2010.elements, "outputProperties", function(base, cfg)
	local calls = base(cfg)
	if isXboxOneConfig(cfg) then
		table.insert(calls, consoleProperties)
	end
	return calls
end)

p.override(vc2010, "libraryPath", function(base, cfg)
	if not isXboxOneConfig(cfg) then
		return base(cfg)
	end

	local dirs = vstudio.path(cfg, cfg.syslibdirs)
	table.insert(dirs, '$(Console_SdkLibPath)')
	vc2010.element("LibraryPath", nil, "%s", table.concat(dirs, ";"))
end)

p.override(vc2010, "includePath", function(base, cfg)
	if not isXboxOneConfig(cfg) then
		return base(cfg)
	end

	local dirs = vstudio.path(cfg, cfg.sysincludedirs)
	table.insert(dirs, '$(Console_SdkIncludeRoot)')
	vc2010.element("IncludePath", nil, "%s", table.concat(dirs, ";"))
end)

p.override(vc2010, "executablePath", function(base, cfg)
	if not isXboxOneConfig(cfg) then
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

	vc2010.element("ExecutablePath", nil, "%s", table.concat(dirs, ";"))
end)

p.override(vstudio.sln2005.elements, "projectConfigurationPlatforms", function(base, cfg, context)
	local calls = base(cfg, context)
	-- Enable "Deploy" in the configuration manager for executable targets
	if isXboxOneConfig(cfg) then
		table.insert(calls, deploy0)
	end
	return calls
end)
