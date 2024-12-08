local PLUGIN = PLUGIN

if !mysql then ErrorNoHalt("[Good Permaprops Manager] MySQL is not enabled!") end
if !mysql:IsConnected() then ErrorNoHalt("[Good Permaprops Manager] MySQL is not connected!") end

do -- Configure Database if not already done

    local function configureDBTable()
        local query = mysql:Create("good_permaprops")
            query:Create("map", "TEXT")
            query:Create("PersistentID", "TEXT")
            query:Create("class", "TEXT")

            query:Create("pos_x", "FLOAT")
            query:Create("pos_y", "FLOAT")
            query:Create("pos_z", "FLOAT")
            query:Create("ang_p", "FLOAT")
            query:Create("ang_y", "FLOAT")
            query:Create("ang_r", "FLOAT")
            query:Create("scale", "FLOAT")

            query:Create("model", "TEXT")
            query:Create("skin", "INTEGER")
            query:Create("material", "TEXT")
            query:Create("color_r", "INTEGER")
            query:Create("color_g", "INTEGER")
            query:Create("color_b", "INTEGER")
            query:Create("color_a", "INTEGER")


            query:Create("materials", "TEXT")
            query:Create("bodygroups", "TEXT")
            query:Create("Bones", "TEXT")
            query:Create("PhysObjs", "TEXT")

            query:Create("Data", "TEXT")
            query:Create("IsLocked", "BOOLEAN")

            query:Callback(function(result, status, lastID)
                -- print("[Good PermaProps Manager] Database configuration : " .. (status and "Success" or "Failed"))
            end)
        query:Execute()

        query = mysql:Create("good_permaremoveprops")
            query:Create("map", "TEXT")
            query:Create("entityCreationID", "TEXT")
            query:Create("class", "TEXT")
            query:Create("pos_x", "FLOAT")
            query:Create("pos_y", "FLOAT")
            query:Create("pos_z", "FLOAT")
            query:Create("ang_p", "FLOAT")
            query:Create("ang_y", "FLOAT")
            query:Create("ang_r", "FLOAT")
            query:Create("scale", "FLOAT")
            query:Create("model", "TEXT")
        query:Execute()
    end

    configureDBTable()
end

function PLUGIN:SaveNewEntity(ent)
    if !ent:IsValid() then return end

    local query = mysql:Insert("good_permaprops")
    query:Insert("map", game.GetMap())
    query:Insert("PersistentID", ent:GetNetVar("PersistentID", PLUGIN:GenerateUUID(ent)))
    query:Insert("class", ent:GetClass())

    local pos = ent:GetPos()
    query:Insert("pos_x", pos.x)
    query:Insert("pos_y", pos.y)
    query:Insert("pos_z", pos.z)

    local ang = ent:GetAngles()
    query:Insert("ang_p", ang.p)
    query:Insert("ang_y", ang.y)
    query:Insert("ang_r", ang.r)

    query:Insert("scale", ent:GetModelScale())

    query:Insert("model", ent:GetModel())
    query:Insert("skin", ent:GetSkin())
    query:Insert("material", ent:GetMaterial())

    local color = ent:GetColor()
    query:Insert("color_r", color.r)
    query:Insert("color_g", color.g)
    query:Insert("color_b", color.b)
    query:Insert("color_a", color.a)

    local subMat, bodyGroups = self:GetSubMaterialAndBodyGroups(ent)
    if istable(subMat) then query:Insert("materials", util.TableToJSON(subMat)) end
    if istable(bodyGroups) then query:Insert("bodygroups", util.TableToJSON(bodyGroups)) end
    
    local boneData, PhysObj = self:GetBoneAndPhysObj(ent)
    if istable(boneData) then query:Insert("Bones", util.TableToJSON(boneData)) end
    if istable(PhysObj) then query:Insert("PhysObjs", util.TableToJSON(PhysObj)) end

    query:Insert("Data", util.TableToJSON(self:EntityGetPersistSaveData(ent)))
    query:Insert("IsLocked", ent:GetNetVar("Locked", false) and 1 or 0) // this is weird i know ...

    query:Callback(function(result, status, lastID)
        ErrorNoHalt("New entity saved ".. (status and "Success" or "Failed"))
    end)
    query:Execute()
end

function PLUGIN:UpdateEntity(ent)
    if !ent:IsValid() then return end

    local query = mysql:Update("good_permaprops")
    query:Where("map", game.GetMap())
    query:Where("PersistentID", ent:GetNetVar("PersistentID", PLUGIN:GenerateUUID(ent)))
    query:Where("class", ent:GetClass())

    local pos = ent:GetPos()
    query:Update("pos_x", pos.x)
    query:Update("pos_y", pos.y)
    query:Update("pos_z", pos.z)

    local ang = ent:GetAngles()
    query:Update("ang_p", ang.p)
    query:Update("ang_y", ang.y)
    query:Update("ang_r", ang.r)

    query:Update("scale", ent:GetModelScale())

    query:Update("model", ent:GetModel())
    query:Update("skin", ent:GetSkin())
    query:Update("material", ent:GetMaterial())

    local color = ent:GetColor()
    query:Update("color_r", color.r)
    query:Update("color_g", color.g)
    query:Update("color_b", color.b)
    query:Update("color_a", color.a)

    local subMat, bodyGroups = self:GetSubMaterialAndBodyGroups(ent)
    if istable(subMat) then query:Update("materials", util.TableToJSON(subMat)) end
    if istable(bodyGroups) then query:Update("bodygroups", util.TableToJSON(bodyGroups)) end
    
    local boneData, PhysObj = self:GetBoneAndPhysObj(ent)
    if istable(boneData) then query:Update("Bones", util.TableToJSON(boneData)) end
    if istable(PhysObj) then query:Update("PhysObjs", util.TableToJSON(PhysObj)) end

    query:Update("Data", util.TableToJSON(self:EntityGetPersistSaveData(ent)))
    query:Update("IsLocked", ent:GetNetVar("Locked", false) and 1 or 0)

    query:Callback(function(result, status, lastID)
        ErrorNoHalt("Entity updated")
    end)
    query:Execute()

end

function PLUGIN:SaveEntity(ent)
    ErrorNoHalt("Saving entity")
    if !ent:IsValid() then return end
    local query = mysql:Select("good_permaprops")
    query:Where("map", game.GetMap())
    query:Where("PersistentID", ent:GetNetVar("PersistentID", PLUGIN:GenerateUUID(ent)))
    query:Where("class", ent:GetClass())
    query:Callback(function(result, status, lastID)
        if #result == 0 then
            self:SaveNewEntity(ent)
            ErrorNoHalt("New entity saved")
        else
            self:UpdateEntity(ent)
            ErrorNoHalt("Entity updated")
        end
    end)
    query:Execute()
end

function PLUGIN:DeleteEntity(ent)
    if !ent:IsValid() then return end

    local query = mysql:Delete("good_permaprops")
    query:Where("map", game.GetMap())
    query:Where("PersistentID", ent:GetNetVar("PersistentID", PLUGIN:GenerateUUID(ent)))
    query:Where("class", ent:GetClass())
    query:Execute()
end

function PLUGIN:SaveAllEntity(ent)
    for k, v in pairs(ents.GetAll()) do
        if v:GetNetVar("Persistent", false) then
            self:SaveEntity(v)
        end
    end
end

function PLUGIN:LoadAllEntities()
    ErrorNoHalt("Loading all entities")
    local query = mysql:Select("good_permaprops")
    query:Where("map", game.GetMap())
    query:Callback(function(result, status, lastID)
        ErrorNoHalt("Loading " .. #result .. " entities")
        for k, v in pairs(result) do
            local ent = ents.Create(v.class)
            ent:SetModel(v.model)
            ent:SetSkin(v.skin)
            ent:SetMaterial(v.material)
            ent:SetColor(Color(v.color_r, v.color_g, v.color_b, v.color_a))
            ent:SetModelScale(v.scale)

            v.materials = util.JSONToTable(v.materials)
            if (istable(v.materials)) then
                for k2, v2 in pairs(v.materials) do
                    ent:SetSubMaterial(k2 - 1, v2)
                end
            end

            v.bodygroups = util.JSONToTable(v.bodygroups)
            if (istable(v.bodygroups)) then
                for k2, v2 in pairs(v.bodygroups) do
                    ent:SetBodygroup(k2, v2)
                end
            end



            v.Data = util.JSONToTable(v.Data)
            PLUGIN:EntitySetPersistLoadData(ent, v.Data)

            ent:Spawn()
            if v.IsLocked == 1 then
                PLUGIN:Lock(ent)
            else
                PLUGIN:Unlock(ent)
            end
            ent:SetPos(Vector(v.pos_x, v.pos_y, v.pos_z))
            ent:SetAngles(Angle(v.ang_p, v.ang_y, v.ang_r))

            -- Uncomment this for halloween
            -- v.Bones = util.JSONToTable(v.Bones)
            -- if (istable(v.Bones)) then
            --     for k2, v2 in pairs(v.Bones) do
            --         local bone = ent:LookupBone(v2.name)
            --         if bone then
            --             ent:ManipulateBonePosition(bone, v2.pos)
            --             ent:ManipulateBoneAngles(bone, v2.ang)
            --         end
            --     end
            -- end

            v.PhysObjs = util.JSONToTable(v.PhysObjs)
            if (istable(v.PhysObjs)) then
                for k2, v2 in pairs(v.PhysObjs) do
                    local phys = ent:GetPhysicsObjectNum(k2)
                    if phys then
                        phys:SetPos(v2.pos)
                        phys:SetAngles(v2.ang)
                        phys:EnableCollisions(v2.collide)
                        phys:EnableMotion(v2.moveable)
                    end
                end
            end

            ent:SetNetVar("Persistent", true)
            ent:SetNetVar("PersistentID", v.PersistentID)
        end
    end)
    query:Execute()
end

-- WIP
-- function PLUGIN:AddPermaRemove(ent)
--     local query = mysql:Insert("good_permaremoveprops")
--     query:Insert("map", game.GetMap())
--     query:Insert("entityCreationID", ent:GetNetVar("PersistentID", PLUGIN:GenerateUUID(ent)))
--     query:Insert("class", ent:GetClass())
--     query:Insert("pos_x", ent:GetPos().x)
--     query:Insert("pos_y", ent:GetPos().y)
--     query:Insert("pos_z", ent:GetPos().z)
--     query:Insert("ang_p", ent:GetAngles().p)
--     query:Insert("ang_y", ent:GetAngles().y)
--     query:Insert("ang_r", ent:GetAngles().r)
--     query:Insert("scale", ent:GetModelScale())
--     query:Insert("model", ent:GetModel())
--     query:Callback(function(result, status, lastID)
--         if status then
--             ent:Remove()
--         end
--     end)
-- end

-- //WIP
-- function PLUGIN:delPermaRemove(entityCreationID)
--     local query = mysql:Delete("good_permaremoveprops")
--     query:Where("map", game.GetMap())
--     query:Where("entityCreationID", entityCreationID)
--     query:Execute()
-- end
-- function PLUGIN:respawnPermaRemove(entityCreationID)
-- end