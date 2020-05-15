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

local function isXboxConfig(cfg)
	return table.contains(os.getSystemTags(cfg.system), "xbox")
end

local function isXdkConfig(cfg)
	return table.contains(os.getSystemTags(cfg.system), "xdk")
end

local function isGdkConfig(cfg)
	return table.contains(os.getSystemTags(cfg.system), "gdk")
end

local function hasXdkConfig(prj)
	for cfg in p.project.eachconfig(prj) do
		if isXdkConfig(cfg) then
			return true
		end
	end
	return false
end

local function hasGdkConfig(prj)
	for cfg in p.project.eachconfig(prj) do
		if isGdkConfig(cfg) then
			return true
		end
	end
	return false
end

local function xdkGlobals(prj)
	vstudio.vc2010.element("DefaultLanguage", nil, "en-US")
	vstudio.vc2010.element("ApplicationEnvironment", nil, "title")
	vstudio.vc2010.element("TargetRuntime", nil, "Native")
end

local function gdkGlobals(prj)
	vc2010.element("DefaultLanguage", nil, "en-US")
	vc2010.element("TargetRuntime", nil, "Native")
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

p.override(vc2010.elements, "globals", function(base, prj)
	local calls = base(prj)

	if hasXdkConfig(prj) then
		table.insert(calls, xdkGlobals)
	end

	if hasGdkConfig(prj) then
		table.insert(calls, gdkGlobals)
	end

	return calls
end)

p.override(vc2010.elements, "outputProperties", function(base, cfg)
	local calls = base(cfg)
	if isXboxConfig(cfg) then
		table.insert(calls, consoleProperties)
	end
	return calls
end)

p.override(vc2010, "libraryPath", function(base, cfg)
	if not isXboxConfig(cfg) then
		return base(cfg)
	end

	local dirs = vstudio.path(cfg, cfg.syslibdirs)
	table.insert(dirs, '$(Console_SdkLibPath)')
	vc2010.element("LibraryPath", nil, "%s", table.concat(dirs, ";"))
end)

p.override(vc2010, "includePath", function(base, cfg)
	if not isXboxConfig(cfg) then
		return base(cfg)
	end

	local dirs = vstudio.path(cfg, cfg.sysincludedirs)
	table.insert(dirs, '$(Console_SdkIncludeRoot)')
	vc2010.element("IncludePath", nil, "%s", table.concat(dirs, ";"))
end)

p.override(vc2010, "executablePath", function(base, cfg)
	if not isXboxConfig(cfg) then
		return base(cfg)
	end

	local dirs = vstudio.path(cfg, cfg.bindirs)
	if isXdkConfig(cfg) then
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
	else
		table.insert(dirs, '$(Console_SdkRoot)bin')
		table.insert(dirs, '$(Console_SdkToolPath)')
	end

	vc2010.element("ExecutablePath", nil, "%s", table.concat(dirs, ";"))
end)

p.override(vc2010, "additionalDependencies", function(base, cfg, explicit)
	-- Remove %(AdditionalDependencies) as that references Win32 libraries that aren't supported
	if not isXboxConfig(cfg) then
		return base(cfg, explicit)
	end

	local links

	-- check to see if this project uses an external toolset. If so, let the
	-- toolset define the format of the links
	local toolset = p.config.toolset(cfg)
	if toolset then
		links = toolset.getlinks(cfg, not explicit)
	else
		links = vstudio.getLinks(cfg, explicit)
	end

	if isGdkConfig(cfg) and cfg.project.kind ~= p.STATICLIB then
		links[#links + 1] = "$(Console_Libs);%(XboxExtensionsDependencies)"
	end

	if #links > 0 then
		links = path.translate(table.concat(links, ";"))
		vc2010.element("AdditionalDependencies", nil, "%s", links)
	end
end)

p.override(vstudio.sln2005.elements, "projectConfigurationPlatforms", function(base, cfg, context)
	local calls = base(cfg, context)
	-- Enable "Deploy" in the configuration manager for executable targets
	if isXboxConfig(cfg) then
		table.insert(calls, deploy0)
	end
	return calls
end)

p.override(vc2010, "generateManifest", function(base, cfg)
	if not isGdkConfig(cfg) then
		return base(cfg)
	end

	if cfg.project.kind == p.CONSOLEAPP or cfg.project.kind == p.WINDOWEDAPP then
		vc2010.element("EmbedManifest", nil, "false")
		vc2010.element("GenerateManifest", nil, "false")
	end
end)
