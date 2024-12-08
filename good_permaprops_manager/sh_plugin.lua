local PLUGIN = PLUGIN

PLUGIN.name = "Good Permaprops Manager"
PLUGIN.author = "Lucasgood"
PLUGIN.description = "Permanent props manager for Helix."
// Reused a lot of code from persistence plugin by alexgrist

ix.util.Include("sv_database.lua")
ix.util.Include("sh_contextual_menu_properties.lua")
ix.util.Include("cl_hud.lua")
ix.util.Include("sv_hooks.lua")
ix.util.Include("sv_utilities.lua")

if CLIENT then return end
ix.log.AddType("gpm persist", function(client, ...)
    local arg = {...}
    return string.format("%s has %s persistence for '%s'.", client:Name(), arg[2] and "enabled" or "disabled", arg[1])
end)

ix.log.AddType("gpm lock", function(client, ...)
    local arg = {...}
    return string.format("%s has %s movement for '%s'.", client:Name(), arg[2] and "locked" or "unlocked", arg[1])
end)