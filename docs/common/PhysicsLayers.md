[An introduction to physics layers.](https://docs.godotengine.org/en/stable/tutorials/physics/physics_introduction.html#collision-layers-and-masks)

When you need to programatically access a physics layer, always use `Layers.Physics2D` instead of hardcoding numbers!
If you need to add a new physics layer, ask me (Shiloh), if your usecase is fine we'll then flag it in the editor and add it to `Layers.gd`.

We have a max of 32 for these, so there's no need to be stingy with them.

### World
Refers to walls, objects etc. that physical things can be expected to collide with. Characters SHOULD occupy this layer, alongside any other layers applicable.

### Player
Refers to the player's collision, to be used for detecting if they are in an area, whether they are hit etc.

### Enemy
See above, but enemy.

### Interactive
Refers to things the player can interact with in the environment.
