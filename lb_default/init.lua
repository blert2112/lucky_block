
lb_lib:register_lucky_block({
	tiles = {"lb_mk1.png"},
	light_emitted = 3,
	in_creative = true,
	particle_textures = {
		place_node = "lb_mk1_place_node.png",
		teleport = "lb_mk1_teleport.png",
	},
	sounds = {
		block = default.node_sound_wood_defaults(),
		troll_remove = "lb_mk1_remove_troll",
		teleport = "lb_mk1_teleport",
	},
	craft_recipe = {
		{"default:gold_ingot",	"default:gold_ingot",	"default:gold_ingot"},
		{"default:gold_ingot",	"default:chest",		"default:gold_ingot"},
		{"default:gold_ingot",	"default:gold_ingot",	"default:gold_ingot"}
	},
	up_luck_items = {
		{name = "default:steel_ingot", value = 2},
		{name = "default:gold_ingot", value = 5},
		{name = "default:diamond", value = 10}
	},
	down_luck_items = {
		{name = "default:dirt", value = -5},
		{name = "default:sand", value = -10}
	},
	chest_items = {
		{name = "default:apple", max = 3},
		{name = "default:wood", max = 3},
		{name = "bucket:bucket_water", max = 1},
		{name = "default:steel_ingot", max = 2}
	},

	fire_node = "fire:basic_flame"
})

local sheep = {
	"mobs:sheep_grey", "mobs:sheep_black", "mobs:sheep_red", "mobs:sheep_yellow", "mobs:sheep_green",
	"mobs:sheep_cyan", "mobs:sheep_blue", "mobs:sheep_magenta", "mobs:sheep_white", "mobs:sheep_orange",
	"mobs:sheep_violet", "mobs:sheep_brown", "mobs:sheep_pink", "mobs:sheep_dark_grey", "mobs:sheep_dark_green"
}

local sandtower = {"default:sand", "default:sand", "default:sand", "default:sand", "default:sand", "default:sand", "default:goldblock"}

local chest_dpick = {
	{name = "default:pick_diamond", max = 1},
	{name = "default:coal_lump", max = 3}
}

lb_lib:add_actions({

--	("nod", luck, node_name, {options})				-- options: troll, explode
	{"nod", 1, "default:diamondblock"},
	{"nod", 1, "default:steelblock"},
	{"nod", 0, "default:wood"},
	{"nod", -1, "default:dirt"},
	{"nod", -1, "default:gravel"},
	{"nod", -1, "default:diamondblock", {explode=true}},
	{"nod", 1, "default:steelblock", {troll=true}},
	{"nod", -1, "tnt:tnt_burning"},

--	("tel", luck, {options})						-- options: xz_radius, y_radius
	{"tel", -1},
	{"tel", -1, {xz_radius=0, y_radius=150}},

--	("lig", luck)
	{"lig", -1},

--	("dro", luck, {list}, {options})				-- options: ammount
	{"dro", 0, {"default:apple"}, {ammount=10}},
	{"dro", 0, {"default:snow"}, {ammount=5}},
	{"dro", 1, {"default:mese_crystal_fragment", "default:mese_crystal"}, {ammount=10}},
	{"dro", 1, {"default:sword_steel", "default:sword_bronze"}},
	{"dro", 1, {"default:pick_steel", "default:shovel_steel", "default:axe_steel"}},
	{"dro", 0, {"default:coal_lump"}, {ammount=3}},
	{"dro", 0, {"default:pick_bronze", "default:shovel_bronze", "default:axe_bronze"}},

--	("cst", luck, chest_node, {options})			-- options: contents, empty
	{"cst", 1, "default:chest", {contents=chest_dpick}},
	{"cst", -1, "default:chest", {empty=true}},
	{"cst", 0, "default:chest"},

--	("sch", luck, schematic, {options})				-- options: at_digger_pos, force
	{"sch", -1, "watertrap", {at_digger_pos=true}},
	{"sch", -1, "sandtrap", {at_digger_pos=true}},
	{"sch", -1, "lavatrap", {at_digger_pos=true}},
	{"sch", 0, "instafarm"},
	{"sch", 1, "wishingwell"},
	{"sch", 1, "platform"},

--	("spn", luck, {list}, {options})				-- options: ammount, radius, tame, own
	{"spn", 0, {"mobs:rat"}, {ammount=5}},
	{"spn", -1, {"mobs:sand_monster", "mobs:stone_monster", "mobs:dirt_monster", "mobs:tree_monster"}, {ammount=3}},
	{"spn", -1, {"mobs:dungeon_master"}},
	{"spn", -1, {"mobs:oerkki"}, {ammount=3}},
	{"spn", 1, sheep, {ammount=6, radius=6}},
	{"spn", 0, {"mobs:sheep_white"}, {ammount=3, tame=true, own=true}},

--	{"fal", luck, {list}, {options}}				-- options: at_digger_pos, scatter, radius
	{"fal", 1, sandtower},
	{"fal", 1, {"default:diamondblock", "default:steelblock", "default:goldblock", "mobs:cheeseblock"}, {scatter=true}},
	{"fal", -1, {"default:obsidian", "default:obsidian"}, {at_digger_pos=true}},
	{"fal", -1, {"tnt:tnt_burning", "tnt:tnt_burning", "tnt:tnt_burning", "tnt:tnt_burning", "tnt:tnt_burning"}, {scatter=true}},

--	{"exp", luck, {options})						-- options: disable_drops, radius, damage_radius_modifier
	{"exp", -1},
	{"exp", -1, {radius=6, damage_radius_modifier=4}},
})
