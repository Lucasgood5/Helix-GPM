local PLUGIN = PLUGIN


function PLUGIN:PhysgunPickup(ply, ent)
    if ent:GetNetVar("Locked") then
        return false
    end
end

function PLUGIN:CanTool(ply, trace, tool)
    if trace.Entity:GetNetVar("Locked") then
        return false
    end
end

-- Cannot use this hook because it is also called when the server is shutting down
-- function PLUGIN:EntityRemoved(ent)
--     if ent:GetNetVar("Persistent") then
--         self:DeleteEntity(ent)
--     end
-- end

function PLUGIN:SaveData()
    self:SaveAllEntity()
end

function PLUGIN:LoadData()
    self:LoadAllEntities()
end

