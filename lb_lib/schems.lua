
-- Generate schematics

minetest.register_node(":lb_lib:well_water_b", {
	description = "Well Water",
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

minetest.register_node(":lb_lib:well_water_t", {
	description = "Well Water",
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

minetest.register_abm({
	nodenames = {"lb_lib:well_water_b"},
	neighbors = nil,
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local all_objects = minetest.get_objects_inside_radius(pos, 1)
		for _,obj in ipairs(all_objects) do
			if obj:is_player() then
				minetest.add_particlespawner({
					amount = 1,
					time = 1,
					minpos = {x = pos.x, y = pos.y+1 , z = pos.z},
					maxpos = {x = pos.x, y = pos.y+1, z = pos.z},
					minvel = {x = 0, y = 0, z = 0},
					maxvel = {x = 0, y = 0, z = 0},
					minacc = {x = 0, y = 0, z = 0},
					maxacc = {x = 0, y = 0, z = 0},
					minexptime = 1,
					maxexptime = 3,
					minsize = 100,
					maxsize = 150,
					texture = "lb_lib_lightning.png",
				})
				minetest.sound_play("lb_lib_thunder", {
					pos = pos,
					gain = 1.0,
					max_hear_distance = 25
				})
				obj:moveto({x=pos.x, y=pos.y+1, z=pos.z}, true)
				minetest.set_node(pos, {name = "default:cobble"})
				minetest.set_node({x=pos.x, y=pos.y+1, z=pos.z}, {name = "air"})
				minetest.dig_node({x=pos.x, y=pos.y-1, z=pos.z})
				break
			end
		end
	end
})

local air = {name="air"}
local lav = {name="default:lava_source"}
local san = {name="default:sand"}
local dir = {name="default:dirt"}
local soi = {name="farming:soil_wet"}
local wat = {name="default:water_source"}
local cot = {name="farming:cotton_8"}
local whe = {name="farming:wheat_8"}
local obg = {name="default:obsidian_glass"}
local fen = {name="default:fence_wood"}
local sto = {name="default:stone"}
local ste = {name="default:steelblock"}

local stl = {name="stairs:stair_stone", param2 = 1}
local str = {name="stairs:stair_stone", param2 = 3}
local stu = {name="stairs:stair_stone", param2 = 0}
local std = {name="stairs:stair_stone", param2 = 2}
local sca = {name="stairs:corner_stone", param2 = 1}
local scb = {name="stairs:corner_stone", param2 = 0}
local scc = {name="stairs:corner_stone", param2 = 2}
local scd = {name="stairs:corner_stone", param2 = 3}

local sns = {name="default:sandstone"}
local snb = {name="default:sandstonebrick"}

local lbl = {name="lb_lib:lucky_block"}
local wwt = {name="lb_lib:well_water_t"}
local wwb = {name="lb_lib:well_water_b"}

local platform = {
	size = {x = 5, y = 3, z = 5},
	data = {
		-- left slice, middle slice, right slice (bottom to top)
		sns, sns, sns, sns, sns,
		snb, snb, snb, snb, snb,
		snb, snb, snb, snb, snb,

		sns, sns, sns, sns, sns,
		snb, lbl, air, lbl, snb,
		snb, air, air, air, snb,

		sns, sns, sns, sns, sns,
		snb, air, air, air, snb,
		snb, air, air, air, snb,

		sns, sns, sns, sns, sns,
		snb, lbl, air, lbl, snb,
		snb, air, air, air, snb,

		sns, sns, sns, sns, sns,
		snb, snb, snb, snb, snb,
		snb, snb, snb, snb, snb
	}
}

local insta_farm = {
	size = {x = 5, y = 3, z = 3},
	data = {
		-- left slice, middle slice, right slice (bottom to top)
		dir, dir, dir, dir, dir,
		soi, soi, soi, soi, soi,
		cot, cot, cot, cot, cot,

		soi, dir, dir, dir, soi,
		soi, wat, wat, wat, soi,
		cot, air, air, air, whe,

		dir, dir, dir, dir, san,
		soi, soi, soi, soi, soi,
		whe, whe, whe, whe, whe
	}
}

local lava_trap = {
	size = {x = 3, y = 6, z = 3},
	data = {
		-- left slice, middle slice, right slice (bottom to top)
		lav, lav, lav,
		air, air, air,
		air, air, air,
		air, air, air,
		air, air, air,
		air, air, air,

		lav, lav, lav,
		air, air, air,
		air, air, air,
		air, air, air,
		air, air, air,
		air, air, air,

		lav, lav, lav,
		air, air, air,
		air, air, air,
		air, air, air,
		air, air, air,
		air, air, air
	}
}

local sand_trap = {
	size = {x = 3, y = 3, z = 3},
	data = {
		-- left slice, middle slice, right slice (bottom to top)
		san, san, san,
		san, san, san,
		san, san, san,

		san, san, san,
		san, san, san,
		san, san, san,

		san, san, san,
		san, san, san,
		san, san, san
	}
}

local water_trap = {
	size = {x = 3, y = 3, z = 3},
	data = {
		-- left slice, middle slice, right slice (bottom to top)
		obg, obg, obg,
		obg, obg, obg,
		obg, obg, obg,

		obg, obg, obg,
		obg, wat, obg,
		obg, obg, obg,

		obg, obg, obg,
		obg, obg, obg,
		obg, obg, obg
	}
}

local wishing_well = {
	size = {x = 3, y = 6, z = 3},
	data = {
		ste, ste, ste,
		sto, sto, sto,
		sto, sto, sto,
		fen, air, fen,
		fen, air, fen,
		sca, stu, scb,

		ste, lbl, ste,
		sto, wwb, sto,
		sto, wwt, sto,
		air, air, air,
		air, air, air,
		stl, air, str,

		ste, ste, ste,
		sto, sto, sto,
		sto, sto, sto,
		fen, air, fen,
		fen, air, fen,
		scc, std, scd
	}
}

lb_lib:add_schematics({
	{name="instafarm", sche=insta_farm, offset={x = 2, y = 2, z = 1}},
	{name="lavatrap", sche=lava_trap, offset={x = 1, y = 5, z = 1}},
	{name="sandtrap", sche=sand_trap, offset={x = 1, y = 0, z = 1}},
	{name="watertrap", sche=water_trap, offset={x = 1, y = 0, z = 1}},
	{name="wishingwell", sche=wishing_well, offset={x = 1, y = 2, z = 1}},
	{name="platform", sche=platform, offset={x = 2, y = 1, z = 2}}
})
