
lb_lib = {}

local action_list = {}
local chest_items = {}
local up_luck_items = {}
local down_luck_items = {}
local particle_textures = {}
local sounds = {}
local schem_list = {}

local fire_node

-- localize for speed
local play_sound = minetest.sound_play
local set_node = minetest.set_node
local remove_node = minetest.remove_node
local add_particlespawner = minetest.add_particlespawner
local get_node_or_nil = minetest.get_node_or_nil

local get_random = expl_lib.get_random
local entity_physics = expl_lib.entity_physics
local spawn_drops = expl_lib.spawn_drops
local boom = expl_lib.boom


-------------------------------------------------------------------------------
--							Support functions
-------------------------------------------------------------------------------

-- particle effects
-------------------------------------------------------------------------------
local function particles(pos, texture, is_lightning)
	if is_lightning then
		add_particlespawner({
			amount = 1,
			time = 1,
			minpos = {x=pos.x, y=pos.y, z=pos.z},
			maxpos = {x=pos.x, y=pos.y, z=pos.z},
			minvel = {x=0, y=0, z=0},
			maxvel = {x=0, y=0, z=0},
			minacc = {x=0, y=0, z=0},
			maxacc = {x=0, y=0, z=0},
			minexptime = 1,
			maxexptime = 3,
			minsize = 100,
			maxsize = 150,
			texture = texture
		})
	else
		add_particlespawner({
			amount = 25,
			time = 0.5,
			minpos = {x=pos.x-1, y=pos.y-1, z=pos.z-1},
			maxpos = {x=pos.x+1, y=pos.y+1, z=pos.z+1},
			minvel = {x=-5, y=-5, z=-5},
			maxvel = {x=5, y=5, z=5},
			minacc = {x=-4, y=-4, z=-4},
			maxacc = {x=4, y=4, z=4},
			minexptime = 1,
			maxexptime = 3,
			minsize = 0.5,
			maxsize = 4,
		texture = texture
		})
	end
end


-------------------------------------------------------------------------------
--							Action functions
-------------------------------------------------------------------------------

-- place node
-------------------------------------------------------------------------------
local function place_node(pos, node_name, options)
	local troll = options.troll or false
	local explode = options.explode or false

	if particle_textures.place_node then
		particles(pos, particle_textures.place_node)
	end

	set_node(pos, {name = node_name})

	if (troll == true) or (explode == true) then
		minetest.after(1.0, function()
			if explode == true then
				boom(pos, 2, 3, false, {})
			else
				if sounds.troll_remove then
					play_sound(sounds.troll_remove, {pos=pos, gain=1.0, max_hear_distance=10})
				end
				remove_node(pos)
			end
		end)
	end
end

-- teleport
-------------------------------------------------------------------------------
local function teleport(pos, digger, options)
	local xz_radius = options.xz_radius or 10
	local y_radius = options.y_radius or math.floor(xz_radius/2)

	if sounds.teleport then
		play_sound(sounds.teleport, {pos=pos, gain=1.0, max_hear_distance=10})
	end

	if particle_textures.teleport then
		particles(pos, particle_textures.teleport)
	end

	pos.x = pos.x + get_random(-xz_radius, xz_radius)
	pos.y = pos.y + get_random(-y_radius, y_radius)
	pos.z = pos.z + get_random(-xz_radius, xz_radius)
	pos = vector.round(pos)

	digger:moveto(pos, false)

	if particle_textures.teleport then
		particles(pos, particle_textures.teleport)
	end
end

-- lightning strike
-------------------------------------------------------------------------------
local function lightning(pos)
	particles(pos, "lb_lib_lightning.png", true)
	play_sound("lb_lib_thunder", {pos=pos, gain=1.0, max_hear_distance=25})
	entity_physics(pos, 2)
	if fire_node then
		set_node(pos, {name=fire_node})
	end
end

-- drop items
-------------------------------------------------------------------------------
local function drop_items(pos, list, options)
	local ammount = options.ammount or 1

	spawn_drops(pos, list, ammount, 0.5, {x=1.5, y=6, z=1.5})
end

-- place and fill chests
-------------------------------------------------------------------------------
local function place_chest(pos, chest, options)
	local empty = options.empty or false
	local contents = options.contents or {}
	
	if particle_textures.place_node then
		particles(pos, particle_textures.place_node)
	end

	set_node(pos, {name = chest})

	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("main", 8 * 4)

	if empty == true then
		return
	end

	for i = 0,2 do
		local item = chest_items[get_random(1, #chest_items)]
		table.insert(contents, {name = item.name, count = get_random(1, item.max)})
	end

	for i = 1, #contents do
		if not inv:contains_item("main", contents[i]) then
			inv:set_stack("main", get_random(1, 32), contents[i])
		end
	end
end

-- place schematic
-------------------------------------------------------------------------------
local function place_schematic(pos, digger, schematic, options)
	if #schem_list == 0 then return end

	local at_digger_pos = options.at_digger_pos or false
	local force = options.force or true

	if at_digger_pos == true then
		pos = digger:getpos()
	end

	for i = 1,#schem_list do
		if schematic == schem_list[i].name then
			local p1 = vector.subtract(pos, schem_list[i].offset) 
			minetest.place_schematic(p1, schem_list[i].sche, "", {}, force)
			break
		end
	end
end

-- place entity
-------------------------------------------------------------------------------
local function place_entity(pos, digger, entity_list, options)
	local tame = options.tame or false
	local own = options.own or false
	local ammount = options.ammount or 1
	local radius = options.radius or 5

	local p1 = {}
	for i = 1, ammount do
		p1.x = pos.x + get_random(-radius, radius)
		p1.y = pos.y + 1
		p1.z = pos.z + get_random(-radius, radius)

		if get_node_or_nil(p1).name == "air" then
			local entity = entity_list[get_random(#entity_list)]
			local mob = minetest.add_entity(p1, entity)
			local ent = mob:get_luaentity()

			if tame == true then
				ent.tamed = true
			end
			if own == true then
				ent.owner = digger:get_player_name()
			end
		end
	end
end

-- falling nodes
-------------------------------------------------------------------------------
local function falling(pos, digger, nodes, options)
	local scatter = options.scatter or false
	local at_digger_pos = options.at_digger_pos or false
	local radius = options.radius or 6

	if at_digger_pos == true then
		pos = digger:getpos()
	end

	pos.y = pos.y + 10 + #nodes

	for i = 1, #nodes do
		minetest.after(0.5 * i, function()
			local node = minetest.registered_nodes[nodes[i]]
			local p = pos
			if scatter == true then
				p.x = pos.x + get_random(-radius,radius)
				p.z = pos.z + get_random(-radius,radius)
			end
			local obj = minetest.add_entity(p, "__builtin:falling_node")
			obj:get_luaentity():set_node(node)
		end)
	end
end

-- explosion
-------------------------------------------------------------------------------
local function explosion(pos, options)
	local disable_drops = options.disable_drops or false
	local radius = options.radius or 5
	local damage_radius_modifier = options.damage_radius_modifier or 3

	boom(pos, radius, radius+damage_radius_modifier, disable_drops, nil)
end


-------------------------------------------------------------------------------
--							Select and execute actions
-------------------------------------------------------------------------------

-- execute selected action
-------------------------------------------------------------------------------
local function do_action(pos, digger, action)
	print(action[1])
	if action[1] == "nod" then			-- place node
		local node_name = action[3]
		local options = action[4] or {}
		place_node(pos, node_name, options)
	elseif action[1] == "tel" then		-- teleport
		local pos = digger:getpos()
		local options = action[3] or {}
		teleport(pos, digger, options)
	elseif action[1] == "lig" then		-- lightning strike
		local pos = digger:getpos()
		lightning(pos)	
	elseif action[1] == "dro" then		-- drop items
		local list = action[3]
		local options = action[4] or {}
		drop_items(pos, list, options)
	elseif action[1] == "cst" then		-- place chest
		local chest = action[3]
		local options = action[4] or {}
		place_chest(pos, chest, options)
	elseif action[1] == "sch" then		-- place schematic
		local schematic = action[3]
		local options = action[4] or {}
		place_schematic(pos, digger, schematic, options)
	elseif action[1] == "spn" then		-- place entity
		local entity_list = action[3]
		local options = action[4] or {}
		place_entity(pos, digger, entity_list, options)
	elseif action[1] == "fal" then		-- falling nodes
		local nodes = action[3]
		local options = action[4] or {}
		falling(pos, digger, nodes, options)
	elseif action[1] == "exp" then		-- explosion
		local options = action[3] or {}
		explosion(pos, options)
	end
end

-- select an action
-------------------------------------------------------------------------------
local function get_action(luck)
	local action = {}
	local choice
	local ac_one, ac_two, ac_three
	local luck_check = get_random(100)
	if luck_check <= luck then
		ac_one = 1
	else
		ac_one = -1
	end
	repeat
		choice = get_random(1, #action_list)
		action = action_list[choice]
		ac_two = action[2]
		if (ac_two == 0) or (ac_two == ac_one) then
			ac_three = 100
		end
	until ac_three == 100
	return action
end


-------------------------------------------------------------------------------
--							Luck up/down
-------------------------------------------------------------------------------

-- calculate luck up/down
-------------------------------------------------------------------------------
local function get_luck_meta(old_craft_grid)
	local name
	local meta_in = 0
	local meta_out = 0
	for i = 1,9 do
		name = old_craft_grid[i]:get_name()
		if name == "lb_lib:lucky_block" then
			meta_in = tonumber(old_craft_grid[i]:get_metadata()) or 50
			meta_out = meta_in
			break
		end
	end
	if meta_in > 0 then
		local addmeta
		-- raise luck
		for i = 1,9 do
			name = old_craft_grid[i]:get_name()
			for j = 1,#up_luck_items do
				if name == up_luck_items[j].name then
					addmeta = up_luck_items[j].value
					break
				else
					addmeta = 0
				end
			end
			meta_out = meta_out + addmeta
		end
		-- lower luck
		if meta_out == meta_in then
			for i = 1,9 do
				name = old_craft_grid[i]:get_name()
				for j = 1,#down_luck_items do
					if name == down_luck_items[j].name then
						addmeta = down_luck_items[j].value
						break
					else
						addmeta = 0
					end
				end
				meta_out = meta_out + addmeta
			end
		end
	else
		meta_out = 50
	end
	if meta_out > 100 then meta_out = 100 end
	if meta_out < 1 then meta_out = 1 end
	return meta_in, meta_out
end

-- which formspec
-------------------------------------------------------------------------------
local formspec_add
local col,row

if minetest.get_modpath("unified_inventory") then
	col = 5
	if minetest.setting_getbool("unified_inventory_lite") then
		row = 2
	else
		row = 2.5
	end
elseif minetest.get_modpath("inventory_plus") or minetest.get_modpath("inventory_enhanced") then
		col = 11
		row = 2
else
	if minetest.get_modpath("3d_armor") then
		col = 7
		row = 3
	else
		col = 11
		row = 2
	end
end
formspec_add = "label["..(col)..","..(row)..";Luck...]"
formspec_add = formspec_add.."label["..(col)..","..(row+0.5)..";IN: ---]"
formspec_add = formspec_add.."label["..(col)..","..(row+1)..";OUT: ---]"

-- handle formspec
-------------------------------------------------------------------------------
minetest.register_craft_predict(function(itemstack, player, old_craft_grid, craft_inv)
	local formspec = player:get_inventory_formspec()
	formspec = formspec..formspec_add
	if itemstack:get_name() == "lb_lib:lucky_block" then
		local meta_in, meta_out = get_luck_meta(old_craft_grid)
		formspec = formspec:gsub("IN:(.-)%]", "IN: "..tostring(meta_in).."]")
		formspec = formspec:gsub("OUT:(.-)%]", "OUT: "..tostring(meta_out).."]")
	else
		formspec = formspec:gsub("IN:(.-)%]", "IN: ---]")
		formspec = formspec:gsub("OUT:(.-)%]", "OUT: ---]")
	end
	player:set_inventory_formspec(formspec)
end)

-- set meta
-------------------------------------------------------------------------------
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name() == "lb_lib:lucky_block" then
		local meta_in, meta_out = get_luck_meta(old_craft_grid)
		itemstack:set_metadata(tostring(meta_out))
		return itemstack
	end
	return nil
end)


-------------------------------------------------------------------------------
--							External functions
-------------------------------------------------------------------------------

-- register lucky block
-------------------------------------------------------------------------------
function lb_lib:register_lucky_block(def)
	local nic = 1
	local in_creative = def.in_creative or false
	if def.in_creative == true then
		nic = 0
	end

	minetest.register_node(":lb_lib:lucky_block", {
		description = "Lucky Block",
		drawtype = "nodebox",
		tiles = def.tiles or {"lb_lib_node.png"},
		sunlight_propagates = false,
		is_ground_content = false,
		paramtype = 'light',
		light_source = def.light_emitted or 3,
		groups = {oddly_breakable_by_hand=3, not_in_creative_inventory=nic},
		stack_max = 1,
		sounds = def.sounds.block or nil,
		after_place_node = function(pos, placer, itemstack, pointed_thing)
			local invmeta = tonumber(itemstack:get_metadata()) or 50
			local meta = minetest.get_meta(pos)
			meta:set_string("infotext", "Luck: "..invmeta)
		end,
		after_dig_node = function(pos, oldnode, oldmetadata, digger)
			local luck = 0
			local infotext = oldmetadata["fields"]["infotext"]
			if infotext then
				luck = tonumber(string.trim(string.sub(infotext, -3)))
			else
				luck = get_random(100)
			end
			print("Luck: "..luck)
			local action = get_action(luck)
			do_action(pos, digger, action)
		end,
		on_blast = function(pos, intensity)
			remove_node(pos)
		end
	})

	minetest.register_craft({
		output = "lb_lib:lucky_block",
		recipe = def.craft_recipe
	})

	local recipe = {}
	
	up_luck_items = def.up_luck_items
	for i = 1,#up_luck_items do
		recipe = {"lb_lib:lucky_block"}
		for j = 1,8 do
			table.insert(recipe, up_luck_items[i].name)
			minetest.register_craft({
				output = "lb_lib:lucky_block",
				type = "shapeless",
				recipe = recipe
			})
		end
	end

	down_luck_items = def.down_luck_items
	for i = 1,#down_luck_items do
		recipe = {"lb_lib:lucky_block"}
		for j = 1,8 do
			table.insert(recipe, down_luck_items[i].name)
			minetest.register_craft({
				output = "lb_lib:lucky_block",
				type = "shapeless",
				recipe = recipe
			})
		end
	end

	particle_textures.place_node = def.particle_textures.place_node or nil
	particle_textures.teleport = def.particle_textures.teleport or nil

	sounds.troll_remove = def.sounds.troll_remove or nil
	sounds.teleport = def.sounds.teleport or nil

	fire_node = def.fire_node or nil
	if fire_node then
		if not minetest.registered_nodes[fire_node] then
            fire_node = nil
        end
	end
end

-- add actions
-------------------------------------------------------------------------------
function lb_lib:add_actions(list)
	for s = 1, #list do
		table.insert(action_list, list[s])
	end
end

-- add items to chest list
-------------------------------------------------------------------------------
function lb_lib:add_chest_items(list)
	for s = 1, #list do
		table.insert(chest_items, list[s])
	end
end

-- add schematics
-------------------------------------------------------------------------------
function lb_lib:add_schematics(list)
	for s = 1, #list do
		table.insert(schem_list, {
			name = list[s].name,
			sche = minetest.register_schematic(list[s].sche),
			offset = list[s].offset
		})
	end
end
dofile(minetest.get_modpath("lb_lib").."/schems.lua")
