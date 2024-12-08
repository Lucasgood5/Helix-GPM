local PLUGIN = PLUGIN

-- Any entity can save data by implementing :SaveData() and use them by implementing :LoadData(data) as callbacks.
function PLUGIN:EntityGetPersistSaveData(ent)
    if !ent:IsValid() then return {} end
    if ent.SaveData then
        return ent:SaveData()
    end
    return {}
end
function PLUGIN:EntitySetPersistLoadData(ent, data)
    if !ent:IsValid() then return end
    if ent.LoadData then
        ent:LoadData(data)
    end
end


function PLUGIN:GetSubMaterialAndBodyGroups(ent)
    local subMat = {}
    local bodyGroups = {}
    if istable(ent:GetMaterials()) then
        for k2, _ in pairs(ent:GetMaterials()) do
            if (ent:GetSubMaterial(k2 - 1) != "") then
                subMat[k2] = ent:GetSubMaterial(k2 - 1)
            end
        end
    end

    if istable(ent:GetBodyGroups()) then
        for _, v2 in pairs(ent:GetBodyGroups()) do
            if (ent:GetBodygroup(v2.id) > 0) then
                bodyGroups[v2.id] = ent:GetBodygroup(v2.id)
            end
        end
    end
    return subMat, bodyGroups
end

function PLUGIN:GetBoneAndPhysObj(ent)
    local boneData = {}
    local PhysObj = {}
    for i = 0, ent:GetBoneCount() - 1 do
        local boneName = ent:GetBoneName(i)
        local bonePos, boneAng = ent:GetBonePosition(i)
        boneData[i] = {name = boneName, pos = bonePos, ang = boneAng}
    end

    for i = 0, ent:GetPhysicsObjectCount() - 1 do
        local phys = ent:GetPhysicsObjectNum(i)
        PhysObj[i] = {pos = phys:GetPos(), ang = phys:GetAngles(), collide = phys:IsCollisionEnabled(), motion = phys:IsMotionEnabled()}
    end
    return boneData, PhysObj
end

function PLUGIN:GenerateUUID(ent) 
    local pos = ent:GetPos()
    local ang = ent:GetAngles()
    return util.CRC(ent:GetModel() .. pos.x .. pos.y .. pos.z .. ang.p .. ang.y .. ang.r)
end


function PLUGIN:Lock(ent)
    if !ent:IsValid() then return end
    local phys = ent:GetPhysicsObject()
    ent:SetNetVar("Locked", true)
    if phys:IsValid() then
        phys:EnableMotion(false)
    end
    ent:SetMoveType(MOVETYPE_NONE)
end

function PLUGIN:Unlock(ent)
    if !ent:IsValid() then return end
    local phys = ent:GetPhysicsObject()
    ent:SetNetVar("Locked", false)
    if phys:IsValid() then
        phys:EnableMotion(true)
    end
    ent:SetMoveType(MOVETYPE_VPHYSICS)
end