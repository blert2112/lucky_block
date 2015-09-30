
-- Generate default schematics

local a = "air"
local l = "default:lava_source"
local s = "default:sand"
local d = "default:dirt"
local w = "farming:soil_wet"
local v = "default:water_source"
local c = "farming:cotton_8"
local h = "farming:wheat_8"
local o = "default:obsidian_glass"

local insta_farm = {
	size = {x = 5, y = 3, z = 3},
	data = {
		-- left slice, middle slice, right slice (bottom to top)
		{name=d, param1=255}, {name=d, param1=255}, {name=d, param1=255}, {name=d, param1=255}, {name=d, param1=255},
		{name=w, param1=255}, {name=w, param1=255}, {name=w, param1=255}, {name=w, param1=255}, {name=w, param1=255},
		{name=c, param1=255}, {name=c, param1=255}, {name=c, param1=255}, {name=c, param1=255}, {name=c, param1=255},

		{name=w, param1=255}, {name=d, param1=255}, {name=d, param1=255}, {name=d, param1=255}, {name=w, param1=255},
		{name=w, param1=255}, {name=v, param1=255}, {name=v, param1=255}, {name=v, param1=255}, {name=w, param1=255},
		{name=c, param1=255}, {name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255}, {name=h, param1=255},

		{name=d, param1=255}, {name=d, param1=255}, {name=d, param1=255}, {name=d, param1=255}, {name=s, param1=255},
		{name=w, param1=255}, {name=w, param1=255}, {name=w, param1=255}, {name=w, param1=255}, {name=w, param1=255},
		{name=h, param1=255}, {name=h, param1=255}, {name=h, param1=255}, {name=h, param1=255}, {name=h, param1=255},

	},
}

local lava_trap = {
	size = {x = 3, y = 6, z = 3},
	data = {
		-- left slice, middle slice, right slice (bottom to top)
		{name=l, param1=255}, {name=l, param1=255}, {name=l, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},

		{name=l, param1=255}, {name=l, param1=255}, {name=l, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},

		{name=l, param1=255}, {name=l, param1=255}, {name=l, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},
		{name=a, param1=255}, {name=a, param1=255}, {name=a, param1=255},

	},
}

local sand_trap = {
	size = {x = 3, y = 3, z = 3},
	data = {
		-- left slice, middle slice, right slice (bottom to top)
		{name=s, param1=255}, {name=s, param1=255}, {name=s, param1=255},
		{name=s, param1=255}, {name=s, param1=255}, {name=s, param1=255},
		{name=s, param1=255}, {name=s, param1=255}, {name=s, param1=255},

		{name=s, param1=255}, {name=s, param1=255}, {name=s, param1=255},
		{name=s, param1=255}, {name=s, param1=255}, {name=s, param1=255},
		{name=s, param1=255}, {name=s, param1=255}, {name=s, param1=255},

		{name=s, param1=255}, {name=s, param1=255}, {name=s, param1=255},
		{name=s, param1=255}, {name=s, param1=255}, {name=s, param1=255},
		{name=s, param1=255}, {name=s, param1=255}, {name=s, param1=255},

	},
}

local water_trap = {
	size = {x = 3, y = 3, z = 3},
	data = {
		-- left slice, middle slice, right slice (bottom to top)
		{name=o, param1=255}, {name=o, param1=255}, {name=o, param1=255},
		{name=o, param1=255}, {name=o, param1=255}, {name=o, param1=255},
		{name=o, param1=255}, {name=o, param1=255}, {name=o, param1=255},

		{name=o, param1=255}, {name=o, param1=255}, {name=o, param1=255},
		{name=o, param1=255}, {name=v, param1=255}, {name=o, param1=255},
		{name=o, param1=255}, {name=o, param1=255}, {name=o, param1=255},

		{name=o, param1=255}, {name=o, param1=255}, {name=o, param1=255},
		{name=o, param1=255}, {name=o, param1=255}, {name=o, param1=255},
		{name=o, param1=255}, {name=o, param1=255}, {name=o, param1=255},

	},
}

lb_api:add_blocks({
	{"sch", water_trap, 1, {x = 1, y = 0, z = 1}, true},
	{"sch", sand_trap, 1, {x = 1, y = 0, z = 1}, true},
	{"sch", lava_trap, 1, {x = 1, y = 5, z = 1}, true}
})

if minetest.get_modpath("farming") then
	lb_api:add_blocks({
		{"sch", insta_farm, 0, {x = 2, y = 2, z = 1}, true}
	})
end

-- THE WELL
local air = "air"
local sto = "default:stone"
local ste = "default:steelblock"
local bra = "brazier:brazier"
local fir = "brazier:brazier_flame"
local top = "lb_api:well_water_t"
local bot = "lb_api:well_water_b"

local well  = {
	size = {x = 3, y = 5, z = 3},
	data = {
		{name=ste, param1=255}, {name=ste, param1=255}, {name=ste, param1=255},
		{name=sto, param1=255}, {name=sto, param1=255}, {name=sto, param1=255},
		{name=sto, param1=255}, {name=sto, param1=255}, {name=sto, param1=255},
		{name=bra, param1=255}, {name=air, param1=255}, {name=bra, param1=255},
		{name=fir, param1=255}, {name=air, param1=255}, {name=fir, param1=255},
		
		{name=ste, param1=255}, {name=sto, param1=255}, {name=ste, param1=255},
		{name=sto, param1=255}, {name=bot, param1=255}, {name=sto, param1=255},
		{name=sto, param1=255}, {name=top, param1=255}, {name=sto, param1=255},
		{name=air, param1=255}, {name=air, param1=255}, {name=air, param1=255},
		{name=air, param1=255}, {name=air, param1=255}, {name=air, param1=255},
		
		{name=ste, param1=255}, {name=ste, param1=255}, {name=ste, param1=255},
		{name=sto, param1=255}, {name=sto, param1=255}, {name=sto, param1=255},
		{name=sto, param1=255}, {name=sto, param1=255}, {name=sto, param1=255},
		{name=bra, param1=255}, {name=air, param1=255}, {name=bra, param1=255},
		{name=fir, param1=255}, {name=air, param1=255}, {name=fir, param1=255},
	}
}

lb_api:add_blocks({
	{"sch", well, 0, {x = 1, y = 2, z = 1}, true}
})

minetest.register_abm({
	nodenames = {"lb_api:well_water_b"},
	neighbors = nil,
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local all_objects = minetest.get_objects_inside_radius(pos, 1)
		local _,obj
		local do_action = false
		for _,obj in ipairs(all_objects) do
			if obj:is_player() then
				do_action = true
				break
			end
		end
		if active_object_count >= 1 and do_action == false then
			do_action = true
		end
		if do_action == true then
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
				texture = "lucky_lightning.png",
			})
			minetest.sound_play("lightning", {
				pos = pos,
				gain = 1.0,
				max_hear_distance = 25
			})
			minetest.set_node(pos, {name = "default:cobble"})
			minetest.set_node({x=pos.x, y=pos.y+1, z=pos.z}, {name = "air"})
		end
	end
})
