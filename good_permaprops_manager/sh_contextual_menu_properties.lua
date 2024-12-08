local PLUGIN = PLUGIN

properties.Add("addtopersistent", {
	MenuLabel = "#makepersistent",
	Order = 400,
	MenuIcon = "icon16/link.png",

	Filter = function(self, entity, client)
		if (entity:IsPlayer() or entity:IsVehicle() or entity.bNoPersist) then return false end
		if (!gamemode.Call("CanProperty", client, "persist", entity)) then return false end

		return !entity:GetNetVar("Persistent", false)
	end,

	Action = function(self, entity)
		self:MsgStart()
			net.WriteEntity(entity)
		self:MsgEnd()
	end,

	Receive = function(self, length, client)
		local entity = net.ReadEntity()
		if (!IsValid(entity)) then return end
		if (!self:Filter(entity, client)) then return end

		local uuid = entity:GetNetVar("PersistentID", nil)
		if !uuid then
			entity:SetNetVar("PersistentID", PLUGIN:GenerateUUID(entity))
		end

		entity:SetNetVar("Persistent", true)
		PLUGIN:SaveEntity(entity)

		ix.log.Add(client, "gpm persist", entity:GetModel(), true)
	end
})

properties.Add("removefrompersistent", {
	MenuLabel = "#stoppersisting",
	Order = 400,
	MenuIcon = "icon16/link_break.png",

	Filter = function(self, entity, client)
		if (entity:IsPlayer()) then return false end
		if (!gamemode.Call("CanProperty", client, "persist", entity)) then return false end

		return entity:GetNetVar("Persistent", false)
	end,

	Action = function(self, entity)
		self:MsgStart()
			net.WriteEntity(entity)
		self:MsgEnd()
	end,

	Receive = function(self, length, client)
		local entity = net.ReadEntity()

		if (!IsValid(entity)) then return end
		if (!self:Filter(entity, client)) then return end

		entity:SetNetVar("Persistent", false)
		PLUGIN:DeleteEntity(entity)

		ix.log.Add(client, "gpm persist", entity:GetModel(), false)
	end
})

properties.Add("lockAsStatic", {
	MenuLabel = "#lockAsStatic",
	Order = 400,
	MenuIcon = "icon16/lock.png",

	Filter = function(self, entity, client)
		if (entity:IsPlayer() or entity:IsVehicle() or entity.bNoPersist) then return false end
		if (!gamemode.Call("CanProperty", client, "persist", entity)) then return false end

		return !entity:GetNetVar("Locked", false)
	end,

	Action = function(self, entity)
		self:MsgStart()
			net.WriteEntity(entity)
		self:MsgEnd()
	end,

	Receive = function(self, length, client)
		local entity = net.ReadEntity()
		if (!IsValid(entity)) then return end
		if (!self:Filter(entity, client)) then return end

		entity:SetNetVar("Locked", true)

		ix.log.Add(client, "gpm lock", entity:GetModel(), true)
	end
})

properties.Add("unlockAsStatic", {
	MenuLabel = "#unlockAsStatic",
	Order = 400,
	MenuIcon = "icon16/lock_open.png",

	Filter = function(self, entity, client)
		if (entity:IsPlayer() or entity:IsVehicle() or entity.bNoPersist) then return false end
		if (!gamemode.Call("CanProperty", client, "persist", entity)) then return false end

		return entity:GetNetVar("Locked", false)
	end,

	Action = function(self, entity)
		self:MsgStart()
			net.WriteEntity(entity)
		self:MsgEnd()
	end,

	Receive = function(self, length, client)
		local entity = net.ReadEntity()
		if (!IsValid(entity)) then return end
		if (!self:Filter(entity, client)) then return end

		entity:SetNetVar("Locked", false)

		ix.log.Add(client, "gpm lock", entity:GetModel(), false)
	end
})