--[[
	Explosion Library
		based on TNT mod from MineTest NeXt
		https://forum.minetest.net/viewtopic.php?f=15&t=13383
]]

expl_lib = {}

local c_air = minetest.get_content_id("air")
local pr = PseudoRandom(os.time())

-- localize for speed
local add_particlespawner = minetest.add_particlespawner
local add_item = minetest.add_item
local get_objects_inside_radius = minetest.get_objects_inside_radius
local is_protected = minetest.is_protected
local remove_node = minetest.remove_node
local set_node = minetest.set_node
local get_node_drops = minetest.get_node_drops
local sound_play = minetest.sound_play
local get_node_timer = minetest.get_node_timer

-- loss probabilities array (one in X will be lost)
local loss_prob = {}
loss_prob["default:cobble"] = 3
loss_prob["default:dirt"] = 4

-- Fill a list with data for content IDs, after all nodes are registered
local cid_data = {}
minetest.after(0, function()
	for name, def in pairs(minetest.registered_nodes) do
		cid_data[minetest.get_content_id(name)] = {
			name = name,
			drops = def.drops,
			flammable = def.groups.flammable,
			on_blast = def.on_blast
		}
	end
end)

local function add_effects(pos, radius)
	add_particlespawner({
		amount = 128,
		time = 1,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x = -20, y = -20, z = -20},
		maxvel = {x = 20,  y = 20,  z = 20},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 3,
		minsize = 8,
		maxsize = 16,
		texture = "expl_lib_smoke.png",
	})
end

local function eject_drops(drops, pos, radius, velocity)
	local vel = {x = 3, y = 10, z = 3}
	if velocity then
		vel = {x = velocity.x, y = velocity.y, z = velocity.z}
	end
	local drop_pos = vector.new(pos)
	for _, item in pairs(drops) do
		local count = item:get_count()
		local max = item:get_stack_max()
		if count > max then
			item:set_count(max)
		end
		while count > 0 do
			if count < max then
				item:set_count(count)
			end
			drop_pos.x = pos.x + pr:next(-radius, radius)
			drop_pos.z = pos.z + pr:next(-radius, radius)
			local obj = add_item(drop_pos, item)
			if obj then
				obj:get_luaentity().collect = true
				obj:setacceleration({x = 0, y = -10, z = 0})
				obj:setvelocity({x = pr:next(-vel.x, vel.x), y = vel.y, z = pr:next(-vel.z, vel.z)})
			end
			count = count - max
		end
	end
end

local function calc_velocity(pos1, pos2, old_vel, power)
	local vel = vector.direction(pos1, pos2)
	vel = vector.normalize(vel)
	vel = vector.multiply(vel, power)
		-- Divide by distance
	local dist = vector.distance(pos1, pos2)
	dist = math.max(dist, 1)
	vel = vector.divide(vel, dist)
		-- Add old velocity
	vel = vector.add(vel, old_vel)
	return vel
end

local function add_drop(drops, item)
	item = ItemStack(item)
	local name = item:get_name()
	if loss_prob[name] ~= nil and pr:next(1, loss_prob[name]) == 1 then
		return
	end
	local drop = drops[name]
	if drop == nil then
		drops[name] = item
	else
		drop:set_count(drop:get_count() + item:get_count())
	end
end

local function destroy(drops, pos, cid, disable_drops, fire_node)
	if is_protected(pos, "") then
		return
	end
	local def = cid_data[cid]
	if def and def.on_blast then
		def.on_blast(vector.new(pos), 1)
		return
	end
	if def and def.flammable and fire_node then
		set_node(pos, {name=fire_node})
	else
		remove_node(pos)
		if disable_drops then return end
		if def then
			local node_drops = get_node_drops(def.name, "")
			for _, item in ipairs(node_drops) do
				add_drop(drops, item)
			end
		end
	end
end

local function explode(pos, radius, disable_drops, fire_node)
	local pos = vector.round(pos)
	local vm = VoxelManip()
	local p1 = vector.subtract(pos, radius)
	local p2 = vector.add(pos, radius)
	local minp, maxp = vm:read_from_map(p1, p2)
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()

	local drops = {}
	local p = {}

	for z = -radius, radius do
	for y = -radius, radius do
	local vi = a:index(pos.x + (-radius), pos.y + y, pos.z + z)
	for x = -radius, radius do
		if (x * x) + (y * y) + (z * z) <=
				(radius * radius) + pr:next(-radius, radius) then
			local cid = data[vi]
			p.x = pos.x + x
			p.y = pos.y + y
			p.z = pos.z + z
			if cid ~= c_air then
				destroy(drops, p, cid, disable_drops, fire_node)
			end
		end
		vi = vi + 1
	end
	end
	end

	return drops
end

function expl_lib.entity_physics(pos, radius)
	-- Make the damage radius larger than the destruction radius
	local objs = get_objects_inside_radius(pos, radius)
	for _, obj in pairs(objs) do
		local obj_pos = obj:getpos()
		local obj_vel = obj:getvelocity()
		local dist = math.max(1, vector.distance(pos, obj_pos))
		if obj_vel ~= nil then
			obj:setvelocity(calc_velocity(pos, obj_pos,
					obj_vel, radius * 10))
		end
		local damage = (4 / dist) * radius
		obj:set_hp(obj:get_hp() - damage)
	end
end
local entity_physics = expl_lib.entity_physics

function expl_lib.boom(pos, radius, damage_radius, disable_drops, fire_node)
	sound_play("expl_lib_explode", {pos = pos, gain = 1.5, max_hear_distance = 80})
	set_node(pos, {name = "expl_lib:boom"})
	get_node_timer(pos):start(0.5)

	local drops = explode(pos, radius, disable_drops, fire_node)
	entity_physics(pos, damage_radius)
	if not disable_drops then
		eject_drops(drops, pos, radius)
	end
	add_effects(pos, radius)
end

function expl_lib.spawn_drops(pos, list, count, radius, velocity)
	local spawn_drops = {}
	for i = 1, count do
		add_drop(spawn_drops, list[pr:next(1, #list)])
	end
	eject_drops(spawn_drops, pos, radius, velocity)
end

function expl_lib.register_drop_loss(name, probability)
	loss_prob[name] = probability
end

function expl_lib.get_random(vmin, vmax)
	if not vmax then
		vmax = vmin
		vmin = 1
	end
	return pr:next(vmin,vmax)
end

minetest.register_node("expl_lib:boom", {
	drawtype = "plantlike",
	tiles = {"expl_lib_boom.png"},
	light_source = 14,	--default.LIGHT_MAX,
	walkable = false,
	drop = "",
	groups = {dig_immediate = 3, not_in_creative = 1},
	on_timer = function(pos, elapsed)
		remove_node(pos)
	end,
	-- unaffected by explosions
	on_blast = function() end,
})

-- reset randomizer every 5 minutes to aviod patterns
local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 300 then
		pr = PseudoRandom(os.time())
		timer = 0
	end
end)
