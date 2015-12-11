
This repo consists of the following folders:

lb_lib
lb_default
expl_lib
tnt
unified_inventory (one single file from this mod)

Let's take each one in turn...
_________________________________________________________________________________

lb_default ... A Lucky Block definition and actions list.

	Here you can see an example definition and some example actions.
	
	Notes on 'fire_node':
		If you supply a fire node it will be used only for the lightning strike,
		explosions do not cause fire.

	depends on:	lb_lib, default, mobs(redo), farming, stairs(redo),
				tnt(my version, see below), fire
_________________________________________________________________________________

expl_lib ... The Explosions Library based on the TNT mod from NeXt.

	I have found that I may want other things to explode, not just TNT. I took the
	explosive bits out of the TNT mod and made it a library for exploding just about
	anything you want. It fully respects On_Blast().

	expl_lib.boom(pos, radius, damage_radius, disable_drops, fire_node)
		Make something go boom! Pass 'fire_node' as 'nil' if you do not want the
		explosion to start fires.

	expl_lib.register_drop_loss(name, probability)
		Register a node drop loss probability for explosions.
		1 in 'probability' will be lost to explosive damage.

	expl_lib.entity_physics(pos, radius)
		Cause damage and physics.

	expl_lib.spawn_drops(pos, list, count, radius, velocity)
		Spawn drops out of the blue if you like.

	depends on: nothing
_________________________________________________________________________________

tnt ... Defines TNT and Gun Powder. Based on the TNT mod mod from NeXt.

	tnt.register_tnt(name, def)
		Register your own TNT nodes.

	depends on: expl_lib, default, fire?
_________________________________________________________________________________

unified_inventory ... One modifided file from the Unified Inventory mod.

	Copy it over to your 'unified_inventory' folder if you use it. See below
	for further explanation.
_________________________________________________________________________________

lb_lib ... This is the Lucky Block Library.

	Many things done here. All changes arose from wanting to add in Luck values.
	Yes, there are now happy blocks and blocks that will make you cry.

	First, yes, I kept it a library and define the block and action list in a
	separate mod. The reason for this is so the library itself has no dependencies.
	Any subgame can use the library, without needing to modify it, regardless of
	modifications the subgame creator may have done to other mods. For example, I
	have removed all diamond and mese tools and armor from the subgame I use on my
	personal server. I don't have to change the lucky block library to remove
	references to these items.

	Second, I changed the lucky_list actions definition up a bit. There is now a
	specifier for bad (-1), mundane (0) and good (1) lucky actions.

	Next, lucky blocks now have a luck value assigned to them and you can raise
	or lower that value in the crafting grid. The value ranges from 1 to 100. All
	block start at 50. When you break a block you have a chance to get a bad,
	mundane or good action. For example, if I break a lucky block with a value of 60
	there is a 60% chance I will get a good or mundane action and a 40% chance I
	will get a bad or mundane action. Mundane actions are always in the mix so you
	can get one of those at any time.

	You can see the luck value of the block after you have placed it in the world
	by hovering over it. You can also see the value in your hotbar hud if you have
	copied the file from above into the unified_inventory folder. I hacked in
	formspec support for the default inventory, unified_inventory (and lite),
	inventory_plus and inventory_enhanced so you can see the luck values as you
	raise or lower them in the crafting grid. It's not pretty but it works. There
	is nothing I can do to show the value in the tooltip of the player inventory.
	It's a shortcoming of the engine that does not allow you to modify the
	description tooltip. There is another way to do it but it requires registering
	100 blocks and possibly hundreds (or thousands) of crafting recipes.

	Luck List Actions:
		place a node
			("nod", luck, node_name, {options})
				options: 
					- troll, default false
					- explode, default false

		teleport
			("tel", luck, {options})
				options:
					- xz_radius, default 10
					- y_radius, default xz_radius/2

		lightning
			("lig", luck)
				options:
					none

		drop item(s)
			("dro", luck, {list}, {options})
				options:
					- ammount, default 1

		place chest
			("cst", luck, chest_node, {options})
				options:
					- contents, default {}
					- empty, default false

		place schematic
			("sch", luck, schematic, {options})
				options:
					- at_digger_pos, default false
					- force, default true

		spawn entity
			("spn", luck, {list}, {options})
				options:
					- ammount, default 1
					- radius, default 5
					- tame, default false
					- own, default false

		falling nodes
			{"fal", luck, {list}, {options}}
				options:
					- at_digger_pos, default false
					- scatter, default false
					- radius, defalut 5

		explosion
			{"exp", luck, {options})
				options:
					- disable_drops, default false
					- radius, default 5
					- damage_radius_modifier, default 3

	See lb_default for examples.
	Notice I removed checking for sheep and made it more generalized. Coding for
	specific items opens the door for others to request "special treatment". Multi-
	colored sheep are now handled in a more general way which allows for mutli-
	colored alpacas if you have them available.
	
	Any mod can add actions, chest items and schematics using:
		lb_lib:add_actions(list)
		lb_lib:add_chest_items(list)
		lb_lib:add_schematics(list)

	Notes on schematics:
		See schems.lua for examples on how to add schematics.
		The schematics are loaded by the library BUT... you cannot use them unless
		your definition mod depends on: default, farming and stairs(redo). If
		these mods are missing it will still place the schematics but there may be
		missing nodes.
_________________________________________________________________________________

I hope you find some of this useful.
Enjoy.
