/**
 * Example: giving a server's own attribute a behaviour.
 *
 * A server can add attributes in scripts/items/items_game_server.txt. The game
 * does nothing with them: a plugin reads the attribute's class and acts on it.
 * This plugin does that for the attribute of the example file that comes with
 * the game:
 *
 *     "50000"
 *     {
 *         "name"                  "example server attribute"
 *         "attribute_class"       "example_server_attribute"
 *         "description_string"    "On Hit: move 25% faster for %s1 seconds"
 *         ...
 *     }
 *
 * The description is the line players see on the weapon, with the value in
 * the place of %s1. The game only shows it: this plugin is what makes it
 * true. A weapon gets the attribute like any other:
 *
 *     "attributes"
 *     {
 *         "example server attribute"
 *         {
 *             "attribute_class"    "example_server_attribute"
 *             "value"    "3"
 *         }
 *     }
 */

#include <sourcemod>
#include <sdkhooks>
#include <tf2r_attributes>

#pragma semicolon 1
#pragma newdecls required

#define ATTRIBUTE_CLASS	"example_server_attribute"

#define SPEED_ATTRIBUTE	"move speed bonus"
#define SPEED_FACTOR	1.25

public Plugin myinfo =
{
	name = "TF2R Attribute Example",
	author = "TF2 Rebalanced",
	description = "On Hit: move faster for a few seconds",
	version = "1.0",
	url = ""
};

public void OnPluginStart()
{
	if (!TF2R_AttributesAvailable())
	{
		SetFailState("This game does not provide attributes to plugins");
	}

	// Players who are already here when the plugin is loaded late
	for (int client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			OnClientPutInServer(client);
		}
	}
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_OnTakeDamageAlivePost, OnTakeDamageAlivePost);
}

void OnTakeDamageAlivePost(int victim, int attacker, int inflictor, float damage, int damagetype, int weapon,
	const float damageForce[3], const float damagePosition[3], int damagecustom)
{
	if (attacker < 1 || attacker > MaxClients || attacker == victim || damage <= 0.0)
	{
		return;
	}

	// The weapon the damage came from, which is not always the one the
	// attacker holds now (a rocket lands after a weapon switch)
	if (weapon <= MaxClients || !IsValidEntity(weapon) || !TF2R_HasAttributes(weapon))
	{
		return;
	}

	// Ask by class, the way the game does: 0.0 comes back unchanged if the
	// weapon does not have the attribute. Asking the weapon instead of the
	// player leaves out the attacker's other weapons.
	float duration = TF2R_HookValueFloat(weapon, ATTRIBUTE_CLASS, 0.0);
	if (duration <= 0.0)
	{
		return;
	}

	// The behaviour itself: a timed attribute the game removes on its own,
	// also when the player dies. Another hit starts the time again.
	TF2R_AddCustomPlayerAttribute(attacker, SPEED_ATTRIBUTE, SPEED_FACTOR, duration);
}
