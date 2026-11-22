# TF2R Attribute Example

An example SourceMod plugin for TF2 Rebalanced servers. It shows how a plugin
gives a behaviour to an attribute the server added itself.

A server can add its own attributes in `scripts/items/items_game_server.txt`.
The game does nothing with such an attribute. A plugin reads the attribute's
class and acts on it. This plugin does that for the attribute of the example
file that comes with the game (`items_game_server_example.txt`) and turns it
into:

> On Hit: move 25% faster for `<value>` seconds

## How it works

1. `TF2R_AttributesAvailable()` checks that the game provides attributes to
   plugins.
2. `SDKHook_OnTakeDamageAlivePost` on every player gives the weapon a hit came
   from.
3. `TF2R_HookValueFloat(weapon, "example_server_attribute", 0.0)` returns the
   attribute's value, or 0 if the weapon does not have it.
4. `TF2R_AddCustomPlayerAttribute` gives the attacker a timed
   "move speed bonus". The game removes it when the time is over.

The source is [scripting/tf2r-attribute-example.sp](scripting/tf2r-attribute-example.sp).

## The attribute

In the server's `scripts/items/items_game_server.txt`, define the attribute:

```
"attributes"
{
	"50000"
	{
		"name"	"example server attribute"
		"attribute_class"	"example_server_attribute"
		"description_format"	"value_is_additive"
		"hidden"	"1"
		"effect_type"	"neutral"
		"stored_as_integer"	"0"
	}
}
```

and put it on an item or prefab. The value is the time in seconds:

```
"attributes"
{
	"example server attribute"
	{
		"attribute_class"	"example_server_attribute"
		"value"	"3"
	}
}
```

An `"attributes"` block replaces the one the item had, so list the item's
other attributes too. The example file that comes with the game explains the
whole format.

## Requirements

- A TF2 Rebalanced server
- The SourceMod build for TF2 Rebalanced, which has the `TF2R_` attribute
  natives and `tf2r_attributes.inc`

## Building

Every release has the compiled plugin. To build it yourself, use the `spcomp64` from that SourceMod build, in `addons/sourcemod/scripting`:

```
./spcomp64 tf2r-attribute-example.sp
```

Put the resulting `tf2r-attribute-example.smx` in `addons/sourcemod/plugins`.

## Making your own

Copy the plugin, change `ATTRIBUTE_CLASS` to the class of your attribute, and
replace the last call in `OnTakeDamageAlivePost` with what the attribute should
do. For a behaviour that is not about hits, hook the moment it matters (a
kill, a spawn, a weapon switch) and ask for the value there in the same way.
