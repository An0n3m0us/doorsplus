# Minetest DoorsPlus mod

![IMG](https://raw.githubusercontent.com/An0n3m0us/doorsplus/master/.doors.gif)

A Minetest mod that improves the default doors mod and other doors mods.

## Additions

### New door model

Default door and trapdoor models with a nicer model.

Doesn't work with some texturepacks that override doors and trapdoors.

Credit to [benrob0329](https://github.com/benrob0329) and [DS-Minetest](https://github.com/DS-Minetest) for optimizing the door model.

### Trapdoor front and back texture

The trapdoors can have a different back and front texture using:
```diff
doors.register_trapdoor("trapdoor", {
	...
+	tile_front = "doors_trapdoor.png",
	tile_side = "doors_trapdoor_side.png",
+	tile_back = "doors_trapdoor_back.png"
	...
}
```

## Installation

Download it here: https://github.com/An0n3m0us/doorsplus/archive/master.zip

Extract it into a folder called "doorsplus" then follow the guide below to install it:

https://dev.minetest.net/Installing_Mods

## Custom models

### Door

For the doorsplus model, use "door_new". To add a custom model, use the filename but without the a or b prefix at the end.

```diff
doors.register("door_wood", {
	description = S("Wooden Door"),
+	model = "door_new",
	tiles = {"doors_door_wood.png"},
	inventory_image = "doors_item_wood.png",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"},
	}
})
```

### Trapdoor

For the doorsplus model, use "trapdoor_new".

```diff
doors.register_trapdoor("trapdoor", {
	description = S("Wooden Trapdoor"),
+	model = "trapdoor_new",
	inventory_image = "doors_trapdoor.png",
	wield_image = "doors_trapdoor.png",
	tile_front = "doors_trapdoor.png",
	tile_side = "doors_trapdoor_side.png",
	tile_back = "doors_trapdoor_back.png",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, door = 1},
})
```

To create a custom model, follow the template below:

```diff
doors.register_trapdoor("trapdoor", {
	description = S("Wooden Trapdoor"),
	inventory_image = "doors_trapdoor.png",
	wield_image = "doors_trapdoor.png",
	tile_front = "doors_trapdoor.png",
	tile_side = "doors_trapdoor_side.png",
	tile_back = "doors_trapdoor_back.png",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, door = 1},
+	closed = {
+	    type = "fixed",
+	    fixed = {
+               {-0.5, -0.5, -0.5, 0.5, -6/16, -5/16},
+               {-0.5, -0.5, 5/16, 0.5, -6/16, 0.5},
+               {-0.5, -0.5, -5/16, -5/16, -6/16, 5/16},
+               {5/16, -0.5, -5/16, 0.5, -6/16, 5/16},
+               {-5/16, -0.5, -2/16, 5/16, -6/16, 2/16},
+               {-2/16, -0.5, -5/16, 2/16, -6/16, 6/16}
+	    }
+	},
+	opened = {
+	    type = "fixed",
+	    fixed = {
+               {-0.5, -0.5, 6/16, -5/16, 0.5, 0.5},
+               {5/16, -0.5, 6/16, 0.5, 0.5, 0.5},
+               {-5/16, 5/16, 6/16, 5/16, 0.5, 0.5},
+               {-5/16, -0.5, 6/16, 5/16, -5/16, 0.5},
+               {-2/16, -6/16, 6/16, 2/16, 5/16, 0.5},
+               {-5/16, -2/16, 6/16, 5/16, 2/16, 0.5}
+	    }
+	}
})
```
