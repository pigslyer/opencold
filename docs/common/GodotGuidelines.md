# Scene guidelines
The following are tips on how to organize a scene well. If you aren't following them, **I ain't merging your shit**.

### A scene can only presuppose its own hierarchy
In too many words, a scene should never make presuppositions as to what the scene tree contains outside of it (excluding [Autoloads](https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html)). This means you can't presuppose what the root's parent is, that a player exists etc. Generally speaking, if your scene can't be launched on its own without errors, you've messed up.

### Dependancies travel down, signals travel up.
A node should never need to be aware of its parents, or anything about their hierarchy. The parent should always tell the child what to do.
If a child does need to inform its parents of something, it should do so via an editor connected signal.

### A scene's root should be its public API.
Because other nodes/scripts should never need to be aware of the structure of a different scene, anything that *they* should need to access should be on the root of your scene. The root is the only thing that they can know for a fact exists.

### Use model scenes for any complex visuals
You never know when some complex animation state machine will be useful in an entirely different context, so setting up a logic-less model that can be dropped anywhere and does what you tell it to is a useful option to have.

### Signals should always be editor connected.
Unless the node you're connecting to/from was created programatically. This should be avoided however.


# GDScript coding
[The general conventions we will follow.](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)

Additionally, any resources to be exposed in the editor, common single script-node pairs and anything that could be
passed as a parameter should be declared with class_name (for e.g. the `Player`, an `InventoryItem`).

Whenever physically possible (so if you aren't returning a variant), you should type annotate all local variables, object fields and method parameters and return values as described in the styleguide listed above. (You can enable autocompletion for type hints in `Editor Settings/text_editor/completion/add_type_hints`)
