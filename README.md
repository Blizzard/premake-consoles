# Console Premake Module

This Premake module allows you to create projects targeting the following consoles:

* Xbox One (Both GDK and XDK)
* Xbox Series X/S

## Requirements

* Premake5 (https://premake.github.io/)
* Microsoft GDK (When targeting Xbox Series X/S or Xbox One GDK)
* Microsoft XDK (When targeting Xbox One XDK)

## How To Use

Clone or download this repository somewhere Premake will be able to find it.
In your project's premake script import the module:

```lua
require("premake-consoles/consoles.lua")
```

This will add the following new options to `system`:

* `durango` (Xbox One XDK)
* `xboxone_gdk` (Xbox One GDK)
* `scarlett` (Xbox Series X/S)

## Example

```lua
workspace "MyWorkspace"
  configurations { "Debug", "Release" }	
  system "xboxone_gdk"
```
