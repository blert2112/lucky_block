
--[[
	based on TNT mod from MineTest NeXt
	https://forum.minetest.net/viewtopic.php?f=15&t=13383
]]

tnt = {}

-- Default to enabled in singleplayer and disabled in multiplayer
local singleplayer = minetest.is_singleplayer()
local setting = minetest.setting_getbool("enable_tnt")
if (not singleplayer and setting ~= true) or
		(singleplayer and setting == false) then
	return
end

local radius = tonumber(minetest.setting_get("tnt_radius") or 3)

-- localize for speed
local boom = expl_lib.boom
local remove_node = minetest.remove_node
local set_node = minetest.set_node
local sound_play = minetest.sound_play
local get_node_timer = minetest.get_node_timer
local get_node = minetest.get_node
local get_item_group = minetest.get_item_group

local function burn(pos)
	local name = get_node(pos).name
	local group = get_item_group(name,"tnt")
	if group > 0 then
		sound_play("tnt_ignite", {pos = pos})
		set_node(pos, {name = name .. "_burning"})
		get_node_timer(pos):start(1)
	elseif name == "tnt:gunpowder" then
		sound_play("tnt_gunpowder_burning", {pos = pos, max_hear_distance = 8, gain = 2})
		set_node(pos, {name = "tnt:gunpowder_burning"})
		get_node_timer(pos):start(1)
	end
end

minetest.register_node("tnt:gunpowder", {
	description = "Gun Powder",
	drawtype = "raillike",
	paramtype = "light",
	is_ground_content = false,
	sunlight_propagates = true,
	walkable = false,
	tiles = {"tnt_gunpowder_straight.png", "tnt_gunpowder_curved.png", "tnt_gunpowder_t_junction.png", "tnt_gunpowder_crossing.png"},
	inventory_image = "tnt_gunpowder_inventory.png",
	wield_image = "tnt_gunpowder_inventory.png",
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2 + 1/16, 1/2},
	},
	groups = {dig_immediate = 2, attached_node = 1, connect_to_raillike = minetest.raillike_group("gunpowder")},
	sounds = default.node_sound_leaves_defaults(),
	on_punch = function(pos, node, puncher)
		if puncher:get_wielded_item():get_name() == "default:torch" then
			burn(pos)
		end
	end,
	on_blast = function(pos, intensity)
		burn(pos)
	end,
})

minetest.register_node("tnt:gunpowder_burning", {
	drawtype = "raillike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	light_source = 5,
	tiles = {
		{
			name = "tnt_gunpowder_burning_straight_animated.png",
			animation = {type = "vertical_frames", aspect_w = 16,	aspect_h = 16, length = 1}
		},
		{
			name = "tnt_gunpowder_burning_curved_animated.png",
			animation = {type = "vertical_frames", aspect_w = 16,	aspect_h = 16, length = 1}
		},
		{
			name = "tnt_gunpowder_burning_t_junction_animated.png",
			animation = {type = "vertical_frames", aspect_w = 16,	aspect_h = 16, length = 1}
		},
		{
			name = "tnt_gunpowder_burning_crossing_animated.png",
			animation = {type = "vertical_frames", aspect_w = 16,	aspect_h = 16, length = 1}
		}
	},
	selection_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/2, 1/2, -1/2+1/16, 1/2},
	},
	drop = "",
	groups = {dig_immediate = 2, attached_node = 1, connect_to_raillike = minetest.raillike_group("gunpowder")},
	sounds = default.node_sound_leaves_defaults(),
	on_timer = function(pos, elapsed)
		for dx = -1, 1 do
		for dz = -1, 1 do
		for dy = -1, 1 do
			if not (dx == 0 and dz == 0) then
				burn({x = pos.x + dx,	y = pos.y + dy,	z = pos.z + dz})
			end
		end
		end
		end
		remove_node(pos)
	end,
	-- unaffected by explosions
	on_blast = function() end,
})

minetest.register_abm({
	nodenames = {"group:tnt", "tnt:gunpowder"},
	neighbors = {"fire:basic_flame", "default:lava_source", "default:lava_flowing"},
	interval = 1,
	chance = 1,
	action = burn,
})

function tnt.register_tnt(name, def)
	if not def or not name then
		return false
	end

	if not def.tiles then
		def.tiles = {}
	end
	local tnt_top = def.tiles.top or "tnt_top.png"
	local tnt_bottom = def.tiles.bottom or "tnt_bottom.png"
	local tnt_side = def.tiles.side or "tnt_side.png"
	local tnt_burning = def.tiles.burning or "tnt_top_burning.png"

	if not def.damage_radius then
		def.damage_radius = def.radius * 2
	end

	minetest.register_node(":" .. name, {
		description = def.description,
		tiles = {tnt_top, tnt_bottom, tnt_side},
		is_ground_content = false,
		groups = {dig_immediate = 2, mesecon = 2, tnt = 1},
		sounds = default.node_sound_wood_defaults(),
		on_punch = function(pos, node, puncher)
			if puncher:get_wielded_item():get_name() == "default:torch" then
				sound_play("tnt_ignite", {pos=pos})
				set_node(pos, {name = name .. "_burning"})
			end
		end,
		on_blast = function(pos, intensity)
			burn(pos)
		end,
		mesecons = {effector = {action_on =
			function (pos)
				boom(pos, def.radius, def.damage_radius, def.disable_drops)
			end
			}
		},
	})
	
	minetest.register_node(":" .. name .. "_burning", {
		tiles = {
			{
				name = tnt_burning,
				animation = {type = "vertical_frames", aspect_w = 16,	aspect_h = 16, length = 1}
			},
			tnt_bottom,
			tnt_side
		},
		groups = {not_in_creative = 1},
		light_source = 5,
		drop = "",
		sounds = default.node_sound_wood_defaults(),
		on_construct = function(pos)
			get_node_timer(pos):start(4)
		end,
		on_timer = function (pos, elapsed)
			boom(pos, def.radius, def.damage_radius, def.disable_drops)
		end,
		-- unaffected by explosions
		on_blast = function() end,
	})

	minetest.register_craft({
		output = name,
		recipe = def.recipe
	})
end


tnt.register_tnt("tnt:tnt", {
	description = "TNT",
	radius = radius,
	tiles = {burning = "tnt_top_burning_animated.png"},
	recipe = {
		{"",           "group:wood",    ""},
		{"group:wood", "tnt:gunpowder", "group:wood"},
		{"",           "group:wood",    ""}
	}
})

minetest.register_craft({
	output = "tnt:gunpowder",
	type = "shapeless",
	recipe = {"default:coal_lump", "default:gravel"}
})
