
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
