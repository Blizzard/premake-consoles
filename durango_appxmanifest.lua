--
-- Deal with the appxmanifest file
-- Copyright (c) 2015-2017 Blizzard Entertainment
--

local p       = premake
local vstudio = p.vstudio
local config  = p.config

local resources = {
	"consoles/assets/Logo.png",
	"consoles/assets/SmallLogo.png",
	"consoles/assets/SplashScreen.png",
	"consoles/assets/StoreLogo.png",
	"consoles/assets/WideLogo.png",
}

---
-- Local methods.
---

p.api.register {
	name = "dummyappxmanifest",
	scope = "config",
	kind = "boolean"
}

p.override(p.oven, "bakeFiles", function (base, prj)
	local files =  base(prj)

	local function addFile(cfg, fname)
		-- If this is the first time I've seen this file, start a new
		-- file configuration for it. Track both by key for quick lookups
		-- and indexed for ordered iteration.
		local fcfg = files[fname]
		if not fcfg then
			fcfg = p.fileconfig.new(fname, prj)
			fcfg.vpath = path.join("appxmanifest", fcfg.name)
			files[fname] = fcfg
			table.insert(files, fcfg)
		end
		p.fileconfig.addconfig(fcfg, cfg)
	end

	local fn = p.filename(prj, ".appxmanifest")
	for cfg in p.project.eachconfig(prj) do
		if cfg.system == p.DURANGO and cfg.dummyappxmanifest then
			addFile(cfg, fn)

			for _, asset in ipairs(resources) do
				addFile(cfg, path.join(prj.location, path.getname(asset)))
			end

			prj._createsDummyManifest = true
		end
	end

	table.sort(files, function(a,b)
		return a.vpath < b.vpath
	end)

	return files
end)


---
-- AppxManifest group
---
vstudio.vc2010.categories.AppxManifest = {
	name       = "AppxManifest",
	extensions = ".appxmanifest",
	priority   = 4,

	emitFiles = function(prj, group)
		vstudio.vc2010.emitFiles(prj, group, "AppxManifest", nil, {excludedFromBuild})
	end,

	emitFilter = function(prj, group)
		vstudio.vc2010.filterGroup(prj, group, "AppxManifest")
	end
}


---
-- AppxManifest Generator
---

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

	--p.push('<Capabilities>')
	--p.w('<Capability Name="internetClientServer" />');
	--p.pop('</Capabilities>')

	--p.push('<Extensions>')
	--p.pop('</Extensions>')

	p.pop('</Package>')
end

p.override(vstudio.vs2010, "generateProject", function(base, prj)
	base(prj)

	if prj._createsDummyManifest then
		p.generate(prj, ".appxmanifest", function()
			generateAppxManifest(prj)
		end)

		for _, asset in ipairs(resources) do
			local file = p.getEmbeddedResource(asset)
			if file ~= nil then
				os.writefile_ifnotequal(file, path.join(prj.location, path.getname(asset)))
			end
		end
	end
end)
