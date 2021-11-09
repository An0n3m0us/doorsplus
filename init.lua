-- doorsplus/init.lua


-- Load support for MT game translation.
local S = minetest.get_translator("doors")

local function replace_old_owner_information(pos)
	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("doors_owner")
	if owner and owner ~= "" then
		meta:set_string("owner", owner)
		meta:set_string("doors_owner", "")
	end
end

local function on_place_node(place_to, newnode,
	placer, oldnode, itemstack, pointed_thing)
	-- Run script hook
	for _, callback in ipairs(minetest.registered_on_placenodes) do
		-- Deepcopy pos, node and pointed_thing because callback can modify them
		local place_to_copy = {x = place_to.x, y = place_to.y, z = place_to.z}
		local newnode_copy =
			{name = newnode.name, param1 = newnode.param1, param2 = newnode.param2}
		local oldnode_copy =
			{name = oldnode.name, param1 = oldnode.param1, param2 = oldnode.param2}
		local pointed_thing_copy = {
			type  = pointed_thing.type,
			above = vector.new(pointed_thing.above),
			under = vector.new(pointed_thing.under),
			ref   = pointed_thing.ref,
		}
		callback(place_to_copy, newnode_copy, placer,
			oldnode_copy, itemstack, pointed_thing_copy)
	end
end

local function can_dig_door(pos, digger)
	replace_old_owner_information(pos)
	return default.can_interact_with_node(digger, pos)
end

function doors.register(name, def)
	if not name:find(":") then
		name = "doors:" .. name
	end

	-- replace old doors of this type automatically
	minetest.register_lbm({
		name = ":doors:replace_" .. name:gsub(":", "_"),
		nodenames = {name.."_b_1", name.."_b_2"},
		action = function(pos, node)
			local l = tonumber(node.name:sub(-1))
			local meta = minetest.get_meta(pos)
			local h = meta:get_int("right") + 1
			local p2 = node.param2
			local replace = {
				{{type = "a", state = 0}, {type = "a", state = 3}},
				{{type = "b", state = 1}, {type = "b", state = 2}}
			}
			local new = replace[l][h]
			-- retain infotext and doors_owner fields
			minetest.swap_node(pos, {name = name .. "_" .. new.type, param2 = p2})
			meta:set_int("state", new.state)
			-- properly place doors:hidden at the right spot
			local p3 = p2
			if new.state >= 2 then
				p3 = (p3 + 3) % 4
			end
			if new.state % 2 == 1 then
				if new.state >= 2 then
					p3 = (p3 + 1) % 4
				else
					p3 = (p3 + 3) % 4
				end
			end
			-- wipe meta on top node as it's unused
			minetest.set_node({x = pos.x, y = pos.y + 1, z = pos.z},
				{name = "doors:hidden", param2 = p3})
		end
	})

	minetest.register_craftitem(":" .. name, {
		description = def.description,
		inventory_image = def.inventory_image,
		groups = table.copy(def.groups),

		on_place = function(itemstack, placer, pointed_thing)
			local pos

			if not pointed_thing.type == "node" then
				return itemstack
			end

			local node = minetest.get_node(pointed_thing.under)
			local pdef = minetest.registered_nodes[node.name]
			if pdef and pdef.on_rightclick and
					not (placer and placer:is_player() and
					placer:get_player_control().sneak) then
				return pdef.on_rightclick(pointed_thing.under,
						node, placer, itemstack, pointed_thing)
			end

			if pdef and pdef.buildable_to then
				pos = pointed_thing.under
			else
				pos = pointed_thing.above
				node = minetest.get_node(pos)
				pdef = minetest.registered_nodes[node.name]
				if not pdef or not pdef.buildable_to then
					return itemstack
				end
			end

			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			local top_node = minetest.get_node_or_nil(above)
			local topdef = top_node and minetest.registered_nodes[top_node.name]

			if not topdef or not topdef.buildable_to then
				return itemstack
			end

			local pn = placer and placer:get_player_name() or ""
			if minetest.is_protected(pos, pn) or minetest.is_protected(above, pn) then
				return itemstack
			end

			local dir = placer and minetest.dir_to_facedir(placer:get_look_dir()) or 0

			local ref = {
				{x = -1, y = 0, z = 0},
				{x = 0, y = 0, z = 1},
				{x = 1, y = 0, z = 0},
				{x = 0, y = 0, z = -1},
			}

			local aside = {
				x = pos.x + ref[dir + 1].x,
				y = pos.y + ref[dir + 1].y,
				z = pos.z + ref[dir + 1].z,
			}

			local state = 0
			if minetest.get_item_group(minetest.get_node(aside).name, "door") == 1 then
				state = state + 2
				minetest.set_node(pos, {name = name .. "_b", param2 = dir})
				minetest.set_node(above, {name = "doors:hidden", param2 = (dir + 3) % 4})
			else
				minetest.set_node(pos, {name = name .. "_a", param2 = dir})
				minetest.set_node(above, {name = "doors:hidden", param2 = dir})
			end

			local meta = minetest.get_meta(pos)
			meta:set_int("state", state)

			if def.protected then
				meta:set_string("owner", pn)
				meta:set_string("infotext", def.description .. "\n" .. S("Owned by @1", pn))
			end

			if not minetest.is_creative_enabled(pn) then
				itemstack:take_item()
			end

			minetest.sound_play(def.sounds.place, {pos = pos}, true)

			on_place_node(pos, minetest.get_node(pos),
				placer, node, itemstack, pointed_thing)

			return itemstack
		end
	})
	def.inventory_image = nil

	if def.recipe then
		minetest.register_craft({
			output = name,
			recipe = def.recipe,
		})
	end
	def.recipe = nil

	if not def.sounds then
		def.sounds = default.node_sound_wood_defaults()
	end

	if not def.sound_open then
		def.sound_open = "doors_door_open"
	end

	if not def.sound_close then
		def.sound_close = "doors_door_close"
	end

	if not def.gain_open then
		def.gain_open = 0.3
	end

	if not def.gain_close then
		def.gain_close = 0.3
	end

	def.groups.not_in_creative_inventory = 1
	def.groups.door = 1
	def.drop = name
	def.door = {
		name = name,
		sounds = {def.sound_close, def.sound_open},
		gains = {def.gain_close, def.gain_open},
	}
	if not def.on_rightclick then
		def.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
			doors.door_toggle(pos, node, clicker)
			return itemstack
		end
	end
	def.after_dig_node = function(pos, node, meta, digger)
		minetest.remove_node({x = pos.x, y = pos.y + 1, z = pos.z})
		minetest.check_for_falling({x = pos.x, y = pos.y + 1, z = pos.z})
	end
	def.on_rotate = function(pos, node, user, mode, new_param2)
		return false
	end

	if def.protected then
		def.can_dig = can_dig_door
		def.on_blast = function() end
		def.on_key_use = function(pos, player)
			local door = doors.get(pos)
			door:toggle(player)
		end
		def.on_skeleton_key_use = function(pos, player, newsecret)
			replace_old_owner_information(pos)
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string("owner")
			local pname = player:get_player_name()

			-- verify placer is owner of lockable door
			if owner ~= pname then
				minetest.record_protection_violation(pos, pname)
				minetest.chat_send_player(pname, S("You do not own this locked door."))
				return nil
			end

			local secret = meta:get_string("key_lock_secret")
			if secret == "" then
				secret = newsecret
				meta:set_string("key_lock_secret", secret)
			end

			return secret, S("a locked door"), owner
		end
		def.node_dig_prediction = ""
	else
		def.on_blast = function(pos, intensity)
			minetest.remove_node(pos)
			-- hidden node doesn't get blasted away.
			minetest.remove_node({x = pos.x, y = pos.y + 1, z = pos.z})
			return {name}
		end
	end

	def.on_destruct = function(pos)
		minetest.remove_node({x = pos.x, y = pos.y + 1, z = pos.z})
	end

	def.drawtype = "mesh"
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.sunlight_propagates = true
	def.walkable = true
	def.is_ground_content = false
	def.buildable_to = false
	def.selection_box = {type = "fixed", fixed = {-1/2,-1/2,-1/2,1/2,3/2,-6/16}}
	def.collision_box = {type = "fixed", fixed = {-1/2,-1/2,-1/2,1/2,3/2,-6/16}}
	def.use_texture_alpha = "clip"

	if def.model == nil then
		def.model = "door"
	end

	def.mesh = def.model .. "_a.b3d"
	minetest.register_node(":" .. name .. "_a", def)

	def.mesh = def.model .. "_b.b3d"
	minetest.register_node(":" .. name .. "_b", def)

	def.mesh = def.model .. "_b.b3d"
	minetest.register_node(":" .. name .. "_c", def)

	def.mesh = def.model .. "_a.b3d"
	minetest.register_node(":" .. name .. "_d", def)

	doors.registered_doors[name .. "_a"] = true
	doors.registered_doors[name .. "_b"] = true
	doors.registered_doors[name .. "_c"] = true
	doors.registered_doors[name .. "_d"] = true
end

doors.register("door_wood", {
	tiles = {{ name = "doors_door_wood.png", backface_culling = true }},
	description = S("Wooden Door"),
	model = "door_cross",
	inventory_image = "doors_item_wood.png",
	groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	gain_open = 0.06,
	gain_close = 0.13,
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"},
	}
})

doors.register("door_steel", {
	tiles = {{name = "doors_door_steel.png", backface_culling = true}},
	description = S("Steel Door"),
	model = "door_cross",
	inventory_image = "doors_item_steel.png",
	protected = true,
	groups = {node = 1, cracky = 1, level = 2},
	sounds = default.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",
	gain_open = 0.2,
	gain_close = 0.2,
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"},
	}
})

function doors.register_trapdoor(name, def)
	if not name:find(":") then
		name = "doors:" .. name
	end

	local name_closed = name
	local name_opened = name.."_open"

	def.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		doors.trapdoor_toggle(pos, node, clicker)
		return itemstack
	end

	-- Common trapdoor configuration
	def.drawtype = "nodebox"
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.is_ground_content = false
	def.use_texture_alpha = "clip"

	if def.protected then
		def.can_dig = can_dig_door
		def.after_place_node = function(pos, placer, itemstack, pointed_thing)
			local pn = placer:get_player_name()
			local meta = minetest.get_meta(pos)
			meta:set_string("owner", pn)
			meta:set_string("infotext", def.description .. "\n" .. S("Owned by @1", pn))

			return minetest.is_creative_enabled(pn)
		end

		def.on_blast = function() end
		def.on_key_use = function(pos, player)
			local door = doors.get(pos)
			door:toggle(player)
		end
		def.on_skeleton_key_use = function(pos, player, newsecret)
			replace_old_owner_information(pos)
			local meta = minetest.get_meta(pos)
			local owner = meta:get_string("owner")
			local pname = player:get_player_name()

			-- verify placer is owner of lockable door
			if owner ~= pname then
				minetest.record_protection_violation(pos, pname)
				minetest.chat_send_player(pname, S("You do not own this trapdoor."))
				return nil
			end

			local secret = meta:get_string("key_lock_secret")
			if secret == "" then
				secret = newsecret
				meta:set_string("key_lock_secret", secret)
			end

			return secret, S("a locked trapdoor"), owner
		end
		def.node_dig_prediction = ""
	else
		def.on_blast = function(pos, intensity)
			minetest.remove_node(pos)
			return {name}
		end
	end

	if not def.sounds then
		def.sounds = default.node_sound_wood_defaults()
	end

	if not def.sound_open then
		def.sound_open = "doors_door_open"
	end

	if not def.sound_close then
		def.sound_close = "doors_door_close"
	end

	if not def.gain_open then
		def.gain_open = 0.3
	end

	if not def.gain_close then
		def.gain_close = 0.3
	end

	if not def.tile_back then
		def.tile_back = def.tile_front
	end

	local def_opened = table.copy(def)
	local def_closed = table.copy(def)

	if def.model == "trapdoor_new" then
		def_closed.node_box = {
		    type = "fixed",
		    fixed = {
		                {-0.5, -0.5, -0.5, 0.5, -6/16, -5/16},
		                {-0.5, -0.5, 5/16, 0.5, -6/16, 0.5},
		                {-0.5, -0.5, -5/16, -5/16, -6/16, 5/16},
		                {5/16, -0.5, -5/16, 0.5, -6/16, 5/16},
		                {-5/16, -0.5, -2/16, 5/16, -6/16, 2/16},
		                {-2/16, -0.5, -5/16, 2/16, -6/16, 6/16}
		    }
		}
	elseif def.closed and def.opened then
	    def_closed.node_box = def.closed
	else
		def_closed.node_box = {
		    type = "fixed",
		    fixed = {-0.5, -0.5, -0.5, 0.5, -6/16, 0.5}
		}
	end
	def_closed.selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -6/16, 0.5}
	}

	def_closed.tiles = {
		def.tile_back,
		def.tile_front .. '^[transformFY',
		def.tile_side,
		def.tile_side,
		def.tile_side,
		def.tile_side
	}

	if def.model == "trapdoor_new" then
		def_opened.node_box = {
		    type = "fixed",
		    fixed = {
		                {-0.5, -0.5, 6/16, -5/16, 0.5, 0.5},
		                {5/16, -0.5, 6/16, 0.5, 0.5, 0.5},
		                {-5/16, 5/16, 6/16, 5/16, 0.5, 0.5},
		                {-5/16, -0.5, 6/16, 5/16, -5/16, 0.5},
		                {-2/16, -6/16, 6/16, 2/16, 5/16, 0.5},
		                {-5/16, -2/16, 6/16, 5/16, 2/16, 0.5}
		    }
		}
	elseif def.opened and def.closed then
	    def_opened.node_box = def.opened
	else
		def_opened.node_box = {
		    type = "fixed",
		    fixed = {-0.5, -0.5, 6/16, 0.5, 0.5, 0.5}
		}
	end
	def_opened.selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 6/16, 0.5, 0.5, 0.5}
	}

	def_opened.tiles = {
		def.tile_side,
		def.tile_side .. '^[transform2',
		def.tile_side .. '^[transform3',
		def.tile_side .. '^[transform1',
		def.tile_back .. '^[transform2',
		def.tile_front .. '^[transform6'
	}

	def_opened.drop = name_closed
	def_opened.groups.not_in_creative_inventory = 1

	minetest.register_node(":" .. name_opened, def_opened)
	minetest.register_node(":" .. name_closed, def_closed)

	doors.registered_trapdoors[name_opened] = true
	doors.registered_trapdoors[name_closed] = true
end

doors.register_trapdoor("trapdoor", {
	description = S("Wooden Trapdoor"),
	model = "trapdoor_new",
	inventory_image = "doors_trapdoor.png",
	wield_image = "doors_trapdoor.png",
	tile_front = "doors_trapdoor.png",
	tile_side = "doors_trapdoor_side.png",
	tile_back = "doors_trapdoor_back.png",
	gain_open = 0.06,
	gain_close = 0.13,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, door = 1},
})

doors.register_trapdoor("trapdoor_steel", {
	description = S("Steel Trapdoor"),
	model = "trapdoor_new",
	inventory_image = "doors_trapdoor_steel.png",
	wield_image = "doors_trapdoor_steel.png",
	tile_front = "doors_trapdoor_steel.png",
	tile_side = "doors_trapdoor_steel_side.png",
	tile_back = "doors_trapdoor_steel_back.png",
	protected = true,
	sounds = default.node_sound_metal_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",
	gain_open = 0.2,
	gain_close = 0.2,
	groups = {cracky = 1, level = 2, door = 1},
})

-- Load other doors mods

if minetest.get_modpath("ts_doors") then
	dofile(minetest.get_modpath("doorsplus").."/ts_doors.lua")
end
