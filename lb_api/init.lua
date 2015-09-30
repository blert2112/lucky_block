lb_api = {}

local lucky_list = {
	--{"nod", "lb_api:super_lucky_block", 0}
}
local chest_stuff = {}
local use_default_schematics = false


-- EXTERNAL FUNCTIONS
-- ******************

-- ability to add new blocks to list
function lb_api:add_blocks(list)
	for s = 1, #list do
		table.insert(lucky_list, list[s])
	end
end

-- ability to add chest items
function lb_api:add_chest_items(list)
	for s = 1, #list do
		table.insert(chest_stuff, list[s])
	end
end

-- call to use default schematics,
-- boolean switch so it can be loaded only once
-- if called multiple times from other mods without
-- purging the block list
function lb_api:use_default_schematics(mult)
	if use_default_schematics == false then
		for i = 1, mult do
			dofile(minetest.get_modpath("lb_api").."/schems.lua")
		end
		use_default_schematics = true
	end
end

-- call to purge the block list
function lb_api:purge_block_list()
	lucky_list = {{"nod", "lb_api:super_lucky_block", 0}}
	use_default_schematics = false
end

-- call to purge the chest items list
function lb_api:purge_chest_items()
	chest_stuff = {}
end

-- ******************
-- END EXTERNAL FUNCTIONS


-- for random colour selection
local all_colours = {
	"grey", "black", "red", "yellow", "green", "cyan", "blue", "magenta",
	"orange", "violet", "brown", "pink", "dark_grey", "dark_green", "white"
}

-- particle effects
function effect(pos, amount, texture, max_size)
	minetest.add_particlespawner({
		amount = amount,
		time = 0.5,
		minpos = {x = pos.x - 1, y = pos.y - 1, z = pos.z - 1},
		maxpos = {x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
		minvel = {x = -5, y = -5, z = -5},
		maxvel = {x = 5,  y = 5,  z = 5},
		minacc = {x = -4, y = -4, z = -4},
		maxacc = {x = 4, y = 4, z = 4},
		minexptime = 1,
		maxexptime = 3,
		minsize = 0.5,
		maxsize = (max_size or 1),
		texture = texture,
	})
end

-- from TNT mod
function calc_velocity(pos1, pos2, old_vel, power)
	local vel = vector.direction(pos1, pos2)
	vel = vector.normalize(vel)
	vel = vector.multiply(vel, power)
	local dist = vector.distance(pos1, pos2)
	dist = math.max(dist, 1)
	vel = vector.divide(vel, dist)
	vel = vector.add(vel, old_vel)
	return vel
end

-- modified from TNT mod
function entity_physics(pos, radius)
	radius = radius * 2
	local objs = minetest.get_objects_inside_radius(pos, radius)
	local obj_pos, obj_vel, dist
	for _, obj in pairs(objs) do
		obj_pos = obj:getpos()
		obj_vel = obj:getvelocity()
		dist = math.max(1, vector.distance(pos, obj_pos))
		if obj_vel ~= nil then
			obj:setvelocity(calc_velocity(pos, obj_pos, obj_vel, radius * 10))
		end
		local damage = (4 / dist) * radius
		obj:set_hp(obj:get_hp() - damage)
	end
end

-- explosion
function explosion(pos, radius)

	local pos = vector.round(pos)
	local vm = VoxelManip()
	local minp, maxp = vm:read_from_map(vector.subtract(pos, radius), vector.add(pos, radius))
	local a = VoxelArea:new({MinEdge = minp, MaxEdge = maxp})
	local data = vm:get_data()
	local p = {}
	local c_air = minetest.get_content_id("air")
	local c_ignore = minetest.get_content_id("ignore")
	local c_obsidian = minetest.get_content_id("default:obsidian")
	local c_brick = minetest.get_content_id("default:obsidianbrick")
	local c_chest = minetest.get_content_id("default:chest_locked")

	minetest.sound_play("tnt_explode", {
		pos = pos,
		gain = 1.0,
		max_hear_distance = 16
	})

	-- if area protected then no blast damage
	if minetest.is_protected(pos, "") then
		return
	end

	for z = -radius, radius do
	for y = -radius, radius do
	local vi = a:index(pos.x + (-radius), pos.y + y, pos.z + z)
	for x = -radius, radius do
		p.x = pos.x + x
		p.y = pos.y + y
		p.z = pos.z + z
		if data[vi] ~= c_air
		and data[vi] ~= c_ignore
		and data[vi] ~= c_obsidian
		and data[vi] ~= c_brick
		and data[vi] ~= c_chest then
			local n = minetest.get_node(p).name
			if minetest.get_item_group(n, "unbreakable") ~= 1 then
				-- if chest then drop items inside
				if n == "default:chest" then
					local meta = minetest.get_meta(p)
					local inv  = meta:get_inventory()
					for i = 1, 32 do
						local m_stack = inv:get_stack("main", i)
						local obj = minetest.add_item(p, m_stack)
						if obj then
							obj:setvelocity({
								x = math.random(-2, 2),
								y = 7,
								z = math.random(-2, 2)
							})
						end
					end
				end

				minetest.set_node(p, {name = "air"})
				effect(p, 2, "tnt_smoke.png", 5)
			end
		end
		vi = vi + 1
	end
	end
	end
end

function fill_chest(pos, items)

	local stacks = items or {}
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("main", 8 * 4)

	for i = 0, 2, 1 do
		local stuff = chest_stuff[math.random(1, #chest_stuff)]
		table.insert(stacks, {name = stuff.name, count = math.random(1, stuff.max)})
	end

	for s = 1, #stacks do
		if not inv:contains_item("main", stacks[s]) then
			inv:set_stack("main", math.random(1, 32), stacks[s])
		end
	end
end

-- this is what happens when you dig a lucky block
local lucky_block = function(pos, digger)
	local luck = math.random(1, #lucky_list) ;  --luck = 1
	local action = lucky_list[luck][1]
	local schem

	print ("luck ["..luck.." of "..#lucky_list.."]", action)

	-- place schematic
	if action == "sch" then
		local offset = lucky_list[luck][4]
		local switch = lucky_list[luck][3]
		local schem = lucky_list[luck][2]
		local force = lucky_list[luck][5] or false
		if switch == 1 then
			pos = digger:getpos()
		end
		minetest.place_schematic(
			{
				x = pos.x - offset.x,
				y = pos.y - offset.y,
				z = pos.z - offset.z
			},
			schem, "", {}, force)

	-- place node (if chest then fill chest)
	elseif action == "nod" then
		local nod = lucky_list[luck][2]
		local switch = lucky_list[luck][3]
		local items = lucky_list[luck][4]
		if switch == 1 then
			pos = digger:getpos()
		end
		if not minetest.registered_nodes[nod] then
			print (nod)
			nod = "default:goldblock"
		end
		effect(pos, 25, "tnt_smoke.png", 8)
		minetest.set_node(pos, {name = nod})
		if nod == "default:chest" then
			fill_chest(pos, items)
		end

	-- place entity
	elseif action == "spw" then
		local pos2 = {}
		local num = lucky_list[luck][3]
		local tame = lucky_list[luck][4]
		local own = lucky_list[luck][5]
		for i = 1, num do
			pos2.x = pos.x + math.random(-5, 5)
			pos2.y = pos.y + 1
			pos2.z = pos.z + math.random(-5, 5)
			local nod = minetest.get_node_or_nil(pos2)
			if nod and nod.name == "air" then
				local entity = lucky_list[luck][2]
				-- coloured sheep
				if entity == "mobs:sheep" then
					local colour = "_" .. all_colours[math.random(#all_colours)]
					--if colour == "_white" then colour = "" end
					entity = "mobs:sheep" .. colour
				end

				local mob = minetest.add_entity(pos2, entity)
				local ent = mob:get_luaentity()
				if tame then
					ent.tamed = true
				end
				if own then
					ent.owner = digger:get_player_name()
				end
			end
		end

	-- explosion
	elseif action == "exp" then
		explosion(pos, 2)
		entity_physics(pos, 2)

	-- teleport
	elseif action == "tel" then
		--pos = digger:getpos()
		pos.x = pos.x + math.random(-10, 10)
		pos.x = pos.y + math.random(-5, 20)
		pos.x = pos.z + math.random(-10, 10)
		digger:moveto(pos, false)

	-- drop items
	elseif action == "dro" then
		local num = lucky_list[luck][3]
		local colours = lucky_list[luck][4]
		local items = #lucky_list[luck][2]
		for i = 1, num do
			local item = lucky_list[luck][2][math.random(1, items)]
			if colours then
				item = item .. all_colours[math.random(#all_colours)]
			end
			local obj = core.add_item(pos, item)
			if obj then
				obj:setvelocity({
					x = math.random(-1.5, 1.5),
					y = 6,
					z = math.random(-1.5, 1.5)
				})
			end
		end

	-- lightning strike
	elseif action == "lig" then
		pos = digger:getpos()
		minetest.set_node(pos, {name = "fire:basic_flame"})
		minetest.add_particlespawner({
			amount = 1,
			time = 1,
			minpos = {x = pos.x, y = pos.y , z = pos.z},
			maxpos = {x = pos.x, y = pos.y, z = pos.z},
			minvel = {x = 0, y = 0, z = 0},
			maxvel = {x = 0, y = 0, z = 0},
			minacc = {x = 0, y = 0, z = 0},
			maxacc = {x = 0, y = 0, z = 0},
			minexptime = 1,
			maxexptime = 3,
			minsize = 100,
			maxsize = 150,
			texture = "lucky_lightning.png",
		})
		entity_physics(pos, 2)
		minetest.sound_play("lightning", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 25
		})
	
	-- falling nodes
	elseif action == "fal" then
		local nods = lucky_list[luck][2]
		local switch = lucky_list[luck][3]
		if switch == 1 then
			pos = digger:getpos()
		end
		pos.y = pos.y + #nods
		for s = 1, #nods do
			minetest.after(0.5 * s, function()
				local n = minetest.registered_nodes[nods[s]]
				core.remove_node(pos)
				local obj = core.add_entity(pos, "__builtin:falling_node")
				obj:get_luaentity():set_node(n)
			end)
		end

	-- troll block, disappears or explodes after 2 seconds
	elseif action == "tro" then
		local nod = lucky_list[luck][2]
		local snd = lucky_list[luck][3]
		local exp = lucky_list[luck][4]
		minetest.set_node(pos, {name = nod})
		if snd then
			minetest.sound_play(snd, {
				pos = pos,
				gain = 1.0,
				max_hear_distance = 10
			})
		end
		minetest.after(2.0, function()
			if exp then
				explosion(pos, 2)
				entity_physics(pos, 2)
			else
				minetest.set_node(pos, {name = "air"})
				minetest.sound_play("default_hard_footstep", {
					pos = pos,
					gain = 1.0,
					max_hear_distance = 10
				})
			end
		end)

	end
end

-- lucky block itself
minetest.register_node("lb_api:lucky_block", {
	description = "Lucky Block",
	drawtype = "nodebox",
	tiles = {"lucky_block.png"},
	inventory_image = minetest.inventorycube("lucky_block.png"),
	sunlight_propagates = false,
	is_ground_content = false,
	paramtype = 'light',
	light_source = 3,
	groups = {oddly_breakable_by_hand = 3},
	sounds = default.node_sound_wood_defaults(),
	on_dig = function(pos, node, digger)
		minetest.set_node(pos, {name = "air"})
		lucky_block(pos, digger)
	end,
})

minetest.register_craft({
	output = "lb_api:lucky_block",
	recipe = {
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"},
		{"default:gold_ingot", "default:chest", "default:gold_ingot"},
		{"default:gold_ingot", "default:gold_ingot", "default:gold_ingot"}
	}
})

-- super lucky block
minetest.register_node("lb_api:super_lucky_block", {
	description = "Super Lucky Block (use Pick)",
	drawtype = "nodebox",
	tiles = {"lucky_block_super.png"},
	inventory_image = minetest.inventorycube("lucky_block_super.png"),
	sunlight_propagates = false,
	is_ground_content = false,
	paramtype = 'light',
	groups = {cracky = 1, level = 2},
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", "Super Lucky Block")
	end,
	on_dig = function(pos)
		minetest.set_node(pos, {name = "air"})
		effect(pos, 25, "tnt_smoke.png", 8)
		minetest.sound_play("fart1", {
			pos = pos,
			gain = 1.0,
			max_hear_distance = 10
		})
	end,
})

-- FOR THE WELL
minetest.register_node("lb_api:well_water_b", {
	description = "Well Water",
	inventory_image = minetest.inventorycube("default_water.png"),
	drawtype = "liquid",
	tiles = {
		{
			name = "default_water_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	alpha = 180,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	is_ground_content = false,
	groups = {not_in_creative_inventory=1},
})
minetest.register_node("lb_api:well_water_t", {
	description = "Well Water",
	inventory_image = minetest.inventorycube("default_water.png"),
	drawtype = "liquid",
	tiles = {
		{
			name = "default_water_source_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 2.0,
			},
		},
	},
	alpha = 180,
	paramtype = "light",
	walkable = false,
	pointable = false,
	diggable = false,
	is_ground_content = false,
	groups = {not_in_creative_inventory=1},
})


print ("[MOD] Lucky Blocks loaded ("..#lucky_list.." in total)")
