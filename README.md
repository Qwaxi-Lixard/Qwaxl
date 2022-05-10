# Qwaxl [kʷɑzʟ]
A lightweight and flexible framework for boostrapping narrative driven games in [Godot](https://godotengine.org/).

## Status
Qwaxl is currently a Personal Set of Tools I Made Open Source™. Some stuff is probably missing and/or broken. This library is additionally, not designed to be a low-code frame work. Knowledge of coding and the Godot Engine is required to fully utilize Qwaxl.

# Addons, Autoloads, and Scripts

## Addons
> *Things not written by me but are core to Qwaxl. Each license is included in the addon's root directory. Only MIT compatable addons will be used.*
### Godot Dialogue Manager (GDM)
A stateless branching dialogue manager created by [Nathan Hoad](https://github.com/nathanhoad/godot_dialogue_manager).

## Autoload Singletons
### Sleeper
Sleeper is a depedency free coroutine management system for Godot. While Godot has thread management through mutexes and semiphores, it lacks any equivalent for corroutines. Thus, sleeper was built to manage and coordinate coroutines. Sleeper offers three different events to wait on: notification events, timer events, and input events. Additionally, notification events are capable of passing additional information into the coroutine.

### Msg
Msg is a message passing system for Godot. It enables remote objects to send and recieve data without the need to mantain any reference or connection to each other. It allows for broadcasting to all possible actors, casting to a specific actor, and randomcasting to any possible actor. Additionally, it's possible to suspend an actor's state until a specific signal is recieved. 

Msg depends on `Sleeper` to implement the `await_for` method.

### Noizy
Noizy is a simple sfx and ambient music manager. It can crossfade background tracks as well as play multiple layers of sound effects.

If *Msg* is detected, it will automatically enable support for it. However, Noizy can be used without *Msg*.

### Simple State
Simple State is an extremely minimal centeral state store. It was designed to enable immutable updates to game state without needing the boiler plate found in Redux inspired systems. Additionally, it comes with a way to mutate the state object directly while still broadcasting changes to all actors.

Simple State will automatic enable *Msg* support when it's detected. However, Simple State can be used without *Msg* and emits the `state_changed` signal.

### Resource Loaders

The following autoload scripts implement resource loaders that will load images and audio clips into a globally accessable data store. Each asset will be named `path/to/resource`. The source directory is not included in the name.

#### assets/Audio.gd

Loads any audio files found in `res://assets/audio/*`. These audio clips can then be accessed from the `Audio` global signleton.

#### assets/Props.gd

Loads any Godot scene files found in `res://scenes/props/*`. These scenes can then be accessed from the `Props` global singleton.

## Dialogue Scene Scripts

Each script provides a layout agnostic way to control the visuals presented to the player during dialogue segments.

### `BackgroundPresenter.gd`
Controls adding and removing visual nodes from a target node. `BackgroundPresenter.gd` can take any abatrary set of names found in `Props` and present them to the screen.

Changing background is currently by calling broadcast within 
```lua
do broadcast("set-bg", { "bg": ["story/Outro1"] })
```


### `DialoguePresenter.gd`
`DialoguePresent.gd` present dialogue to a `RichTextLabel`. It implements text scrolling, dialogue pauses, and dialogue skipping.

### `OptionPresenter.gd`
`OptionPresenter.gd` present choices to the player. These choices are taken from `GDM`. `OptionPresenter.gd` adds each button to the provided target node. When a button is clicked, `Playback.gd` a choice had been made.

### `Playback`
The core system that coordinates `DialoguePresenter.gd` and `OptionPresenter.gd` with `GDM`.