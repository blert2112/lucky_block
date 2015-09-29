
This is a fork of TenPlus1's Lucky Block mod for MineTest converted to a modpack.
_________________________________________________________________________________

lb_api ... All you need to build your own mod.

*lb_api:add_blocks({list})
- See api.txt for usage.

*lb_api:add_chest_items({list})
- Adds items to the chest list.
- Example
lb_api:add_chest_items({
	{name = "default:apple", max = 3},
	{name = "default:steel_ingot", max = 2},
	{name = "default:gold_ingot", max = 2},
	{name = "default:diamond", max = 1},
	{name = "default:pick_steel", max = 1}
})

*lb_api:use_default_schematics(mult)
- Use the lb_api default schematics that consist of:
	sand trap
	lava trap
	water trap
	insta farm
- 'mult' specifies how many times to add the four schematics to the list.

	
The following functions are for use when building upon an existing mod.

*lb_api:purge_block_list()
- Purge the lucky block list and start over fresh.
- Warning, purging the block list also purges the schematics.
- If you want to use the default schematics then you must call
  use_default_schematics() after this one.

*lb_api:purge_chest_items()
- Purge the chest items list and start over.


NOTE: When building upon an existing lucky block mod you should put the mod
in your 'depends' file.
Example: If you want to build upon the default mod your 'depends' file should,
at least, have 'lb_api' and 'lb_default' listed.
_________________________________________________________________________________

lb_default ... Default block and chest list as concocted by TenPlus1.
_________________________________________________________________________________

lb_mk1 ... The mod I am currently testing on my server.
_________________________________________________________________________________

Enjoy.
