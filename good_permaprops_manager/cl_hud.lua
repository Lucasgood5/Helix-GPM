local PLUGIN = PLUGIN

function PLUGIN:InitPostEntity()
    print(LocalPlayer())
    if LocalPlayer():IsAdmin() == false then return end

    local TextColor = Color(255, 255, 255)
    local BackgroundColor = Color(0, 0, 0, 200)
    local HighLightColor = ix.config.Get("color")
    
    ix.option.Add("ShowPersistentProps", ix.type.bool , false, {
        category = "Good PermaProps Manager",
    })
    ix.option.Add("ShowDistance", ix.type.number, 0, {
        category = "Good PermaProps Manager",
        min = 0,
        max = 2000
    })
    ix.option.Add("HighDetailMode", ix.type.bool, false, {
        category = "Good PermaProps Manager",
    })

    ix.option.Add("ShowNonPersistentProps", ix.type.bool, false, {
        category = "Good PermaProps Manager",
    })

    local function sweetClassName(cname) 
        local name_table = {
            ["prop_physics"] = "Props",
        }
        if name_table[cname] then return name_table[cname] end
        return cname
    end

    local function DrawEntityHUD(ent, highDetail)
        local pos = ent:GetPos()
        if highDetail then
            local screenPos = pos:ToScreen()
            local x, y = screenPos.x, screenPos.y
            local w,h = 0, 100
            local t_className = "Class: " .. sweetClassName( ent:GetClass() )
            local t_model = "Model: " .. ent:GetModel()
            local t_PersistentID = "UUID: " .. ent:GetNetVar("PersistentID", "No UUID !")
            local t_isLocked = "Locked: " .. (ent:GetNetVar("Locked", false) and "Yes" or "No")
            surface.SetFont("DermaLarge")
            local tcnw = surface.GetTextSize(t_className) or 0
            surface.SetFont("ixGenericFont")
            local tmw = surface.GetTextSize(t_model) or 0
            local tfw = surface.GetTextSize(t_isLocked) or 0
            local td = surface.GetTextSize(t_PersistentID) or 0
            w = math.max(tcnw , tmw, tfw, td) + 10
            
            surface.SetDrawColor(BackgroundColor)
            surface.DrawRect(x - w/2, y - h/2, w, h)
            surface.SetDrawColor(HighLightColor)
            surface.DrawOutlinedRect(x - w/2, y - h/2, w, h)

            surface.SetFont("DermaLarge")
            surface.SetTextColor(HighLightColor)
            surface.SetTextPos(x - w/2 + 5, y - h/2 + 5)
            surface.DrawText(t_className)

            surface.SetFont("ixGenericFont")
            surface.SetTextColor(TextColor)
            surface.SetTextPos(x - w/2 + 5, y - h/2 + 5 + 45)
            surface.DrawText(t_model)
            surface.SetTextPos(x - w/2 + 5, y - h/2 + 5 + 60)
            surface.DrawText(t_isLocked)
            surface.SetTextPos(x - w/2 + 5, y - h/2 + 5 + 75)
            surface.DrawText(t_PersistentID)
        else
            local screenPos = pos:ToScreen()
            local x, y = screenPos.x, screenPos.y
            local text = sweetClassName( ent:GetClass() )
            
            surface.SetFont("ixGenericFont")
            local w,h = surface.GetTextSize(text)
            surface.SetDrawColor(BackgroundColor)
            surface.DrawRect(x - w/2, y - h/2, w, h)
            surface.SetTextColor(TextColor)
            surface.SetTextPos(x - w/2, y - h/2)
            surface.DrawText(text)
        end
    end
    
    hook.Add("HUDPaint", "GoodPermaPropsManager.Hud", function()
        if !ix.option.Get("ShowPersistentProps", false) and !ix.option.Get("ShowNonPersistentProps", false) then return end
        local distance = ix.option.Get("ShowDistance", 0)/1
        local highDetail = ix.option.Get("HighDetailMode", false)
        local iterator
        if distance == 0 then iterator = ents.GetAll() else iterator = ents.FindInSphere(LocalPlayer():GetPos(), distance) end
        for _, ent in pairs(iterator) do
            if ent:GetNetVar("Persistent", false) or (ix.option.Get("ShowNonPersistentProps", false) and !ent:GetNetVar("Persistent", false)) then
                pcall(DrawEntityHUD, ent, highDetail)
            end
        end 
    end)
end

