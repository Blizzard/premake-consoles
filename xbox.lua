--
-- Shared code Xbox support for Visual Studio backend.
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

local function hasXboxConfig(prj)
	for cfg in p.project.eachconfig(prj) do
		if isXboxConfig(cfg) then
			return true
		end
	end
	return false
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

local function mgcPath(prj)
	return string.format("manifests\\%s\\MicrosoftGame.Config", prj.name)
end

local function generateAppxManifest(prj)
	p.utf8()
	p.w('<?xml version="1.0" encoding="utf-8"?>')
	p.push('<Package xmlns="http://schemas.microsoft.com/appx/2010/manifest" xmlns:mx="http://schemas.microsoft.com/appx/2013/xbox/manifest" IgnorableNamespaces="mx">')

	p.w('<Identity Name="%s" Publisher="CN=Publisher" Version="1.0.0.0" />', os.uuid('appxmanifest' .. prj.name):lower())

	p.push('<Properties>')
	p.w('<DisplayName>%s</DisplayName>', prj.name)
	p.w('<PublisherDisplayName>%s</PublisherDisplayName>', prj.name)
	p.w('<Logo>StoreLogo.png</Logo>')
	p.w('<Description>%s</Description>', prj.name)
	p.pop('</Properties>')

	p.push('<Prerequisites>')
	p.w('<OSMinVersion>6.2</OSMinVersion>')
	p.w('<OSMaxVersionTested>6.2</OSMaxVersionTested>')
	p.pop('</Prerequisites>')

	p.push('<Resources>')
	p.w('<Resource Language="en-us"/>')
	p.pop('</Resources>')

	p.push('<Applications>')
	p.push('<Application Id="App" Executable="$targetnametoken$.exe" EntryPoint="%s.App">', prj.name)
	p.push('<VisualElements')
	p.w('  DisplayName="%s"', prj.name)
	p.w('  Logo="Logo.png"')
	p.w('  SmallLogo="SmallLogo.png"')
	p.w('  Description="%s"', prj.name)
	p.w('  ForegroundText="light"')
	p.w('  BackgroundColor="#464646" >')
	p.w('<SplashScreen Image="SplashScreen.png" />')
	p.w('<DefaultTile WideLogo="WideLogo.png" />')
	p.pop('</VisualElements>')
	p.pop('</Application>')
	p.pop('</Applications>')

	p.pop('</Package>')
end

local function generateMGConfig(prj)
	p.utf8()
	p.w('<?xml version="1.0" encoding="utf-8"?>')
	p.push('<Game configVersion="0">')

	p.w('<Identity Name="%s" Publisher="CN=Publisher" Version="1.0.0.0" />', prj.name:gsub('[^%w]', ''))

	p.push('<ExecutableList>')
	local targets = {}
	for cfg in p.project.eachconfig(prj) do
		if not table.contains(targets, cfg.buildtarget.name) then
			table.insert(targets, cfg.buildtarget.name)
			p.w('<Executable Name="%s" Id="Game" IsDevOnly="true" />', cfg.buildtarget.name)
		end
	end
	p.pop('</ExecutableList>')

	p.push('<ShellVisuals')
	p.w('DefaultDisplayName="%s"', prj.name)
	p.w('Square44x44Logo="SmallLogo.png"')
	p.w('Square150x150Logo="Logo.png"')
	p.w('Description="%s"', prj.name)
	p.w('ForegroundText="light"')
	p.w('BackgroundColor="#000040"')
	p.w('StoreLogo="StoreLogo.png"')
	p.w('SplashScreenImage="SplashScreen.png" />')
	p.pop()

	p.pop('</Game>')
end


--
-- Properties
--

p.api.register {
	name = "xbox_dummymanifest",
	scope = "config",
	kind = "boolean"
}

p.api.alias("xbox_dummymanifest", "dummyappxmanifest")


--
-- Extensions
--

vc2010.categories.AppxManifest = {
	name = "AppxManifest",
	extensions = ".appxmanifest",
	priority = 4,

	emitFiles = function(prj, group)
		local fileCfgFunc = function(fcfg, condition)
			return {
				vc2010.excludedFromBuild
			}
		end
		vc2010.emitFiles(prj, group, "AppxManifest", nil, fileCfgFunc, function(cfg)
			return isXdkConfig(cfg)
		end)
	end,

	emitFilter = function(prj, group)
		vc2010.filterGroup(prj, group, "AppxManifest")
	end
}

vc2010.categories.MGCCompile = {
	name = "MGCCompile",
	priority = 4,

	emitFiles = function(prj, group)
		local fileCfgFunc = function(fcfg, condition)
			return {
				vc2010.excludedFromBuild
			}
		end
		vc2010.emitFiles(prj, group, "MGCCompile", nil, fileCfgFunc, function(cfg)
			return isGdkConfig(cfg)
		end)
	end,

	emitFilter = function(prj, group)
		vc2010.filterGroup(prj, group, "MGCCompile")
	end
}

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

local resources = {
	"consoles/assets/Logo.png",
	"consoles/assets/SmallLogo.png",
	"consoles/assets/SplashScreen.png",
	"consoles/assets/StoreLogo.png",
	"consoles/assets/WideLogo.png",
}

p.override(p.oven, "bakeFiles", function (base, prj)
	local files = base(prj)

	if hasXboxConfig(prj) then
		local function addFile(cfg, fname, isXdk)
			-- If this is the first time I've seen this file, start a new
			-- file configuration for it. Track both by key for quick lookups
			-- and indexed for ordered iteration.
			local fcfg = files[fname]
			if not fcfg then
				fcfg = p.fileconfig.new(fname, prj)
				if isXdk then
					fcfg.vpath = path.join("appxmanifest", fcfg.name)
				else
					fcfg.vpath = path.join("MicrosoftGameConfig", fcfg.name)
				end
				files[fname] = fcfg
				table.insert(files, fcfg)
			end
			return p.fileconfig.addconfig(fcfg, cfg)
		end

		for cfg in p.project.eachconfig(prj) do
			if cfg.xbox_dummymanifest then
				local fn
				local isXdk = isXdkConfig(cfg)
				if isXdk then
					fn = p.filename(prj, ".appxmanifest")
				else
					fn = p.filename(prj, mgcPath(prj))
				end

				local fcfg = addFile(cfg, fn, isXdk)
				if not isXdk then
					fcfg.buildaction = "MGCCompile"
				end

				for _, asset in ipairs(resources) do
					addFile(cfg, path.join(prj.location, path.getname(asset)), isXdk)
				end

				prj._createsDummyManifest = true
			end
		end

		if prj._createsDummyManifest then
			table.sort(files, function(a,b)
				return a.vpath < b.vpath
			end)
		end
	end

	return files
end)

p.override(vstudio.vs2010, "generateProject", function(base, prj)
	base(prj)

	if prj._createsDummyManifest then
		if hasXdkConfig(prj) then
			p.generate(prj, ".appxmanifest", function()
				generateAppxManifest(prj)
			end)
		elseif hasGdkConfig(prj) then
			p.generate(prj, mgcPath(prj), function()
				generateMGConfig(prj)
			end)
		end

		for _, asset in ipairs(resources) do
			local file = p.getEmbeddedResource(asset)
			if file ~= nil then
				os.writefile_ifnotequal(file, path.join(prj.location, path.getname(asset)))
			end
		end
	end
end)
