-- Overwrite ts_doors function to add model argument

local function register_alias(name, convert_to)
	minetest.register_alias(name, convert_to)
	minetest.register_alias(name .. "_a", convert_to .. "_a")
	minetest.register_alias(name .. "_b", convert_to .. "_b")
end

function ts_doors.register_door(item, model, description, texture, sounds, recipe)
	if not minetest.registered_nodes[item] then
		minetest.log("[ts_doors] bug found: "..item.." is not a registered node. Cannot create doors")
		return
	end
	if not sounds then
		sounds = {}
	end
	recipe = recipe or item
	ts_doors.registered_doors[item:gsub(":", "_")] = recipe
	register_alias("doors:ts_door_" .. item:gsub(":", "_"), "ts_doors:door_" .. item:gsub(":", "_"))
	register_alias("doors:ts_door_full_" .. item:gsub(":", "_"), "ts_doors:door_full_" .. item:gsub(":", "_"))
	register_alias("doors:ts_door_locked_" .. item:gsub(":", "_"), "ts_doors:door_locked_" .. item:gsub(":", "_"))
	register_alias("doors:ts_door_full_locked_" .. item:gsub(":", "_"), "ts_doors:door_full_locked_" .. item:gsub(":", "_"))

	local groups = minetest.registered_nodes[item].groups
	local door_groups = {door=1}
	for k, v in pairs(groups) do
		if k ~= "wood" then
			door_groups[k] = v
		end
	end

	doors.register("ts_doors:door_" .. item:gsub(":", "_"), {
		tiles = { { name = "[combine:32x38:0,0=" .. texture .. ":0,16=" .. texture .. ":0,32=" .. texture .. ":16,0=" .. texture .. ":16,16=" .. texture .. ":16,32=" .. texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base.png^[noalpha^[makealpha:0,255,0", backface_culling = true } },
		description = description .. " Windowed Door",
		model = "door_cross",
		inventory_image = "[combine:32x32:0,8=" .. texture .. ":16,8=" .. texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_inv.png^[noalpha^[makealpha:0,255,0",
		groups = table.copy(door_groups),
		sounds = sounds.sounds or nil,
		sound_open = sounds.sound_open or nil,
		sound_close = sounds.sound_close or nil,
	})

	doors.register("ts_doors:door_full_" .. item:gsub(":", "_"), {
		tiles = { { name = "[combine:32x38:0,0=" .. texture .. ":0,16=" .. texture .. ":0,32=" .. texture .. ":16,0=" .. texture .. ":16,16=" .. texture .. ":16,32=" .. texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_full.png^[noalpha", backface_culling = true } },
		description = "Solid " .. description .. " Door",
		inventory_image = "[combine:32x32:0,8=" .. texture .. ":16,8=" .. texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_full_inv.png^[noalpha^[makealpha:0,255,0",
		groups = table.copy(door_groups),
		sounds = sounds.sounds or nil,
		sound_open = sounds.sound_open or nil,
		sound_close = sounds.sound_close or nil,
	})

	doors.register_trapdoor("ts_doors:trapdoor_" .. item:gsub(":", "_"), {
		description = "Windowed " .. description .. " Trapdoor",
		model = "trapdoor_new",
		inventory_image = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor.png^[noalpha^[makealpha:0,255,0",
		wield_image = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor.png^[noalpha^[makealpha:0,255,0",
		tile_front = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor.png^[noalpha^[makealpha:0,255,0",
		tile_side = texture .. "^[colorize:#fff:30",
		groups = table.copy(door_groups),
		sounds = sounds.sounds or nil,
		sound_open = sounds.sound_open or nil,
		sound_close = sounds.sound_close or nil,
	})

	doors.register_trapdoor("ts_doors:trapdoor_full_" .. item:gsub(":", "_"), {
		description = "Solid " .. description .. " Trapdoor",
		inventory_image = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor_full.png^[noalpha",
		wield_image = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor_full.png^[noalpha",
		tile_front = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor_full.png^[noalpha",
		tile_side = texture .. "^[colorize:#fff:30",
		groups = table.copy(door_groups),
		sounds = sounds.sounds or nil,
		sound_open = sounds.sound_open or nil,
		sound_close = sounds.sound_close or nil,
	})

	door_groups.level = 2

	doors.register("ts_doors:door_locked_" .. item:gsub(":", "_"), {
		tiles = { { name = "[combine:32x38:0,0=" .. texture .. ":0,16=" .. texture .. ":0,32=" .. texture .. ":16,0=" .. texture .. ":16,16=" .. texture .. ":16,32=" .. texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_locked.png^[noalpha^[makealpha:0,255,0", backface_culling = true } },
		description = "Windowed Locked " .. description .. " Door",
		model = "door_cross",
		inventory_image = "[combine:32x32:0,8=" .. texture .. ":16,8=" .. texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_locked_inv.png^[noalpha^[makealpha:0,255,0",
		protected = true,
		groups = table.copy(door_groups),
		sound_open = "doors_steel_door_open",
		sound_close = "doors_steel_door_close",
		sounds = sounds.sounds or nil,
		sound_open = sounds.sound_open or nil,
		sound_close = sounds.sound_close or nil,
	})

	doors.register("ts_doors:door_full_locked_" .. item:gsub(":", "_"), {
		tiles = { { name = "[combine:32x38:0,0=" .. texture .. ":0,16=" .. texture .. ":0,32=" .. texture .. ":16,0=" .. texture .. ":16,16=" .. texture .. ":16,32=" .. texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_full_locked.png^[noalpha", backface_culling = true } },
		description = "Solid Locked " .. description .. " Door",
		inventory_image = "[combine:32x32:0,8=" .. texture .. ":16,8=" .. texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_full_locked_inv.png^[noalpha^[makealpha:0,255,0",
		protected = true,
		groups = table.copy(door_groups),
		sound_open = "doors_steel_door_open",
		sound_close = "doors_steel_door_close",
		sounds = sounds.sounds or nil,
		sound_open = sounds.sound_open or nil,
		sound_close = sounds.sound_close or nil,
	})

	doors.register_trapdoor("ts_doors:trapdoor_locked_" .. item:gsub(":", "_"), {
		description = "Windowed Locked " .. description .. " Trapdoor",
		model = "trapdoor_new",
		inventory_image = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor_locked.png^[noalpha^[makealpha:0,255,0",
		wield_image = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor_locked.png^[noalpha^[makealpha:0,255,0",
		tile_front = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor_locked.png^[noalpha^[makealpha:0,255,0",
		tile_side = texture .. "^[colorize:#fff:30",
		protected = true,
		groups = table.copy(door_groups),
		sounds = sounds.sounds or nil,
		sound_open = sounds.sound_open or nil,
		sound_close = sounds.sound_close or nil,
	})

	doors.register_trapdoor("ts_doors:trapdoor_full_locked_" .. item:gsub(":", "_"), {
		description = "Solid Locked " .. description .. " Trapdoor",
		inventory_image = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor_full_locked.png^[noalpha",
		wield_image = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor_full_locked.png^[noalpha",
		tile_front = texture .. "^[transformR90^[colorize:#fff:30^ts_doors_base_trapdoor_full_locked.png^[noalpha",
		tile_side = texture .. "^[colorize:#fff:30",
		protected = true,
		groups = table.copy(door_groups),
		sounds = sounds.sounds or nil,
		sound_open = sounds.sound_open or nil,
		sound_close = sounds.sound_close or nil,
	})
end

ts_doors.register_door("default:aspen_wood", "door_", "Aspen", "default_aspen_wood.png", ts_doors.sounds.wood)
ts_doors.register_door("default:pine_wood", "door_", "Pine", "default_pine_wood.png", ts_doors.sounds.wood)
ts_doors.register_door("default:acacia_wood", "door_", "Acacia", "default_acacia_wood.png", ts_doors.sounds.wood)
ts_doors.register_door("default:wood", "door_", "Wooden", "default_wood.png", ts_doors.sounds.wood)
ts_doors.register_door("default:junglewood", "door_", "Jungle Wood", "default_junglewood.png", ts_doors.sounds.wood)

if minetest.get_modpath("moretrees") then
	ts_doors.register_door("moretrees:apple_tree_planks", "door_", "Apple Tree", "moretrees_apple_tree_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:beech_planks", "door_", "Beech", "moretrees_beech_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:birch_planks", "door_", "Birch", "moretrees_birch_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:fir_planks", "door_", "Fir", "moretrees_fir_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:oak_planks", "door_", "Oak", "moretrees_oak_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:palm_planks", "door_", "Palm", "moretrees_palm_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:rubber_tree_planks", "door_", "Rubber Tree", "moretrees_rubber_tree_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:sequoia_planks", "door_", "Sequoia", "moretrees_sequoia_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:spruce_planks", "door_", "Spruce", "moretrees_spruce_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("moretrees:willow_planks", "door_", "Willow", "moretrees_willow_wood.png", ts_doors.sounds.wood)
end

if minetest.get_modpath("ethereal") then
	ts_doors.register_door("ethereal:banana_wood", "door_", "Banana", "banana_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("ethereal:birch_wood", "door_", "Birch", "moretrees_birch_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("ethereal:frost_wood", "door_", "Frost", "frost_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("ethereal:mushroom_trunk", "door_", "Mushroom", "mushroom_trunk.png", ts_doors.sounds.wood)
	ts_doors.register_door("ethereal:palm_wood", "door_", "Palm", "moretrees_palm_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("ethereal:redwood_wood", "door_", "Redwood", "redwood_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("ethereal:sakura_wood", "door_", "Sakura", "ethereal_sakura_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("ethereal:scorched_tree", "door_", "Scorched", "scorched_tree.png", ts_doors.sounds.wood)
	ts_doors.register_door("ethereal:willow_wood", "door_", "Willow", "willow_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("ethereal:yellow_wood", "door_", "Healing Tree", "yellow_wood.png", ts_doors.sounds.wood)
	ts_doors.register_door("ethereal:crystal_block", "door_", "Crystal", "crystal_block.png", ts_doors.sounds.metal, "ethereal:crystal_ingot")
end


ts_doors.register_door("default:bronzeblock", "door_", "Bronze", "default_bronze_block.png", ts_doors.sounds.metal, "default:bronze_ingot")
ts_doors.register_door("default:copperblock", "door_", "Copper", "default_copper_block.png", ts_doors.sounds.metal, "default:copper_ingot")
ts_doors.register_door("default:diamondblock", "door_", "Diamond", "default_diamond_block.png", ts_doors.sounds.metal, "default:diamond")
ts_doors.register_door("default:goldblock", "door_", "Gold", "default_gold_block.png", ts_doors.sounds.metal, "default:gold_ingot")
ts_doors.register_door("default:steelblock", "door_", "Steel", minetest.registered_nodes["default:steelblock"].tiles[1], ts_doors.sounds.metal, "default:steel_ingot")

if minetest.get_modpath("moreores") then
	ts_doors.register_door("moreores:mithril_block", "door_", "Mithril", "moreores_mithril_block.png", ts_doors.sounds.metal, "moreores:mithril_ingot")
	ts_doors.register_door("moreores:silver_block", "door_", "Silver", "moreores_silver_block.png", ts_doors.sounds.metal, "moreores:silver_ingot")
	ts_doors.register_door("moreores:tin_block", "door_", "Tin", "moreores_tin_block.png", ts_doors.sounds.metal, "moreores:tin_ingot")
end

if minetest.get_modpath("technic") then
	ts_doors.register_door("technic:brass_block", "door_", "Brass", "technic_brass_block.png", ts_doors.sounds.metal, "technic:brass_ingot")
	ts_doors.register_door("technic:carbon_steel_block", "door_", "Carbon Steel", "technic_carbon_steel_block.png", ts_doors.sounds.metal, "technic:carbon_steel_ingot")
	ts_doors.register_door("technic:cast_iron_block", "door_", "Cast Iron", "technic_cast_iron_block.png", ts_doors.sounds.metal, "technic:cast_iron_ingot")
	ts_doors.register_door("technic:chromium_block", "door_", "Chromium", "technic_chromium_block.png", ts_doors.sounds.metal, "technic:chromium_ingot")
	ts_doors.register_door("technic:lead_block", "door_", "Lead", "technic_lead_block.png", ts_doors.sounds.metal, "technic:lead_ingot")
	ts_doors.register_door("technic:stainless_steel_block", "door_", "Stainless Steel", "technic_stainless_steel_block.png", ts_doors.sounds.metal, "technic:stainless_steel_ingot")
	ts_doors.register_door("technic:zinc_block", "door_", "Zinc", "technic_zinc_block.png", ts_doors.sounds.metal, "technic:zinc_ingot")

	ts_doors.register_door("technic:concrete", "door_", "Concrete", "technic_concrete_block.png", ts_doors.sounds.metal)
	ts_doors.register_door("technic:blast_resistant_concrete", "door_", "Blast Resistant Concrete", "technic_blast_resistant_concrete_block.png", ts_doors.sounds.metal)
end

minetest.override_item("doors:door_steel", {
	description = "Windowed Locked Plain Steel Door",
})

minetest.override_item("doors:door_wood", {
	description = "Windowed Mixed Wood Door",
})

minetest.override_item("doors:trapdoor", {
	description = "Windowed Mixed Wood Trapdoor",
})

minetest.override_item("doors:trapdoor_steel", {
	description = "Windowed Locked Plain Steel Trapdoor",
})
