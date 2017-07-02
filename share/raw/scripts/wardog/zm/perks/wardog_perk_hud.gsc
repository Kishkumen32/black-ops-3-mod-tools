// 3arc - Core
#using scripts\codescripts\struct;

// 3arc - Shared
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\lui_shared;
#using scripts\shared\math_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

// 3arc - Zombiemode
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_utility;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#insert scripts\wardog\shared\wardog_shared.gsh; // This line is required so the below macro is valid
#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\shared\wardog_menu;
#using scripts\wardog\shared\wardog_shared_util;

#using scripts\wardog\zm\perks\wardog_perk_hud;
#using scripts\wardog\zm\wardog_zm_load;
#using scripts\wardog\zm\wardog_zm_util;

#namespace wardog_perk_hud;

#precache("material", "scr_specialty_giant_fastreload_zombies");

function perk_hud_init()
{
	// No other way i know of
	// of overriding this callback so
	// we get a callback with perk as arg
	if(wardog_zm_util::is_perk(PERK_JUGGERNOG))
		level._custom_perks[PERK_JUGGERNOG].clientfield_set = &perk_hud_state_change_jugg;
	if(wardog_zm_util::is_perk(PERK_QUICK_REVIVE))
		level._custom_perks[PERK_QUICK_REVIVE].clientfield_set = &perk_hud_state_change_revive;
	if(wardog_zm_util::is_perk(PERK_SLEIGHT_OF_HAND))
		level._custom_perks[PERK_SLEIGHT_OF_HAND].clientfield_set = &perk_hud_state_change_speed;
	if(wardog_zm_util::is_perk(PERK_DOUBLETAP2))
		level._custom_perks[PERK_DOUBLETAP2].clientfield_set = &perk_hud_state_change_dtap;
	if(wardog_zm_util::is_perk(PERK_STAMINUP))
		level._custom_perks[PERK_STAMINUP].clientfield_set = &perk_hud_state_change_stamin;
	if(wardog_zm_util::is_perk(PERK_PHDFLOPPER))
		level._custom_perks[PERK_PHDFLOPPER].clientfield_set = &perk_hud_state_change_phd;
	if(wardog_zm_util::is_perk(PERK_DEAD_SHOT))
		level._custom_perks[PERK_DEAD_SHOT].clientfield_set = &perk_hud_state_change_deadshot;
	if(wardog_zm_util::is_perk(PERK_ADDITIONAL_PRIMARY_WEAPON))
		level._custom_perks[PERK_ADDITIONAL_PRIMARY_WEAPON].clientfield_set = &perk_hud_state_change_mule;
	if(wardog_zm_util::is_perk(PERK_ELECTRIC_CHERRY))
		level._custom_perks[PERK_ELECTRIC_CHERRY].clientfield_set = &perk_hud_state_change_cherry;
	if(wardog_zm_util::is_perk(PERK_WIDOWS_WINE))
		level._custom_perks[PERK_WIDOWS_WINE].clientfield_set = &perk_hud_state_change_widows;
}

/@
"Name: display_perk_shader(<perk>)"
"Module: WARDOGSK93 - Zombiemode: Perk HUD"
"Summary: Displays this perks shader to the players HUD."
"MandatoryArg: <perk>: The perks string engine name."
"CallOn: A Player"
"Example: display_perk_shader("specialty_vultureaid");"
"SPMP: multiplayer"
@/
function private display_perk_shader(perk)
{
	Assert(isdefined(perk), "perk is a required argument for display_perk_shader!");
	Assert(isdefined(self) && IsPlayer(self), "display_perk_shader must be called on a valid Player entity!");

	MAKE_ARRAY(self.perk_hud)

	if(isdefined(self.perk_hud[perk]))
	{
		if(self.perk_hud[perk].alpha != 1)
			self zm_perks::perk_hud_grey(perk, false);
		return;
	}

	hud = NewClientHudElem(self);
	hud.alignX = "left";
	hud.alignY = "bottom";
	hud.horzAlign = "left";
	hud.vertAlign = "bottom";
	hud.foreground = true;
	hud.sort = 1;
	hud.hidewheninmenu = true;
	hud.x = 64 + (self.perk_hud.size * 30);
	hud.y = -22;
	hud.alpha = 1;
	hud SetShader(get_perk_shader(perk), 25, 25);

	self.perk_hud[perk] = hud;
}

/@
"Name: register_perk_shader(<perk>, <shader>)"
"Module: WARDOGSK93 - Zombiemode: Perk HUD"
"Summary: Registers a valid shader to be displayed when player obtains this perk."
"MandatoryArg: <perk>: The perks string engine name."
"MandatoryArg: <shader>: The shaders string material name."
"Example: register_perk_shader("specialty_vultureaid", "wardog_t7_hud_perk_vulture");"
"SPMP: multiplayer"
@/
function register_perk_shader(perk, shader = "scr_specialty_giant_fastreload_zombies")
{
	Assert(isdefined(perk), "perk is a required argument for register_perk_shader!");
	Assert(isdefined(shader), "shader is a required argument for register_perk_shader!");

	zm_perks::_register_undefined_perk(perk);

	if(!isdefined(level._custom_perks[perk].wardog_shader))
		level._custom_perks[perk].wardog_shader = shader;
}

/@
"Name: get_perk_shader(<perk>)"
"Module: WARDOGSK93 - Zombiemode: Perk HUD"
"Summary: Returns the shader this perk should use."
"MandatoryArg: <perk>: The perks string engine name."
"Example: get_perk_shader("specialty_vultureaid");"
"SPMP: multiplayer"
@/
function get_perk_shader(perk)
{
	Assert(isdefined(perk), "perk is a required argument for get_perk_shader!");

	if(wardog_zm_util::is_perk(perk) && isdefined(level._custom_perks[perk].wardog_shader))
		return level._custom_perks[perk].wardog_shader;
	return "scr_specialty_giant_fastreload_zombies";
}

/@
"Name: update_perk_hud()"
"Module: WARDOGSK93 - Zombiemode: Perk HUD"
"Summary: Updates a players perk hud."
"Example: player update_perk_hud();"
"CallOn: A Player"
"SPMP: multiplayer"
@/
function update_perk_hud()
{
	if(isdefined(self.perk_hud))
	{
		keys = GetArrayKeys(self.perk_hud);

		for(i = 0; i < keys.size; i++)
		{
			self.perk_hud[keys[i]].x = 64 + (i * 30);
		}
	}
}

function private update_perk_hud_nextframe()
{
	self notify("kill_update_perk_hud_thread");
	self endon("kill_update_perk_hud_thread");

	util::wait_network_frame();
	waittillframeend;

	if(isdefined(self.perk_hud) && self.perk_hud.size != 0)
		self thread update_perk_hud();
}

// ------------------------

function private perk_hud_state_change(perk, state)
{
	switch(state)
	{
		case PERK_STATE_NOT_OWNED: // 0
			self zm_perks::perk_hud_destroy(perk);
			self thread update_perk_hud_nextframe();
			break;

		case PERK_STATE_OWNED: // 1
			if(isdefined(self.perk_hud) && isdefined(self.perk_hud[perk]))
				self zm_perks::perk_hud_grey(perk, false);
			else
				self display_perk_shader(perk);
			break;

		case PERK_STATE_PAUSED: // 2
			self zm_perks::perk_hud_grey(perk, true);
			break;

		case PERK_STATE_DEACTIVATED: // 3
			self zm_perks::perk_hud_destroy(perk);
			self thread update_perk_hud_nextframe();
			break;

		default: break;
	}
}

function perk_hud_state_change_jugg(state)
{
	self perk_hud_state_change(PERK_JUGGERNOG, state);
}

function perk_hud_state_change_revive(state)
{
	self perk_hud_state_change(PERK_QUICK_REVIVE, state);
}

function perk_hud_state_change_speed(state)
{
	self perk_hud_state_change(PERK_SLEIGHT_OF_HAND, state);
}

function perk_hud_state_change_dtap(state)
{
	self perk_hud_state_change(PERK_DOUBLETAP2, state);
}

function perk_hud_state_change_stamin(state)
{
	self perk_hud_state_change(PERK_STAMINUP, state);
}

function perk_hud_state_change_phd(state)
{
	self perk_hud_state_change(PERK_PHDFLOPPER, state);
}

function perk_hud_state_change_deadshot(state)
{
	self perk_hud_state_change(PERK_DEAD_SHOT, state);
}

function perk_hud_state_change_mule(state)
{
	self perk_hud_state_change(PERK_ADDITIONAL_PRIMARY_WEAPON, state);
}

function perk_hud_state_change_cherry(state)
{
	self perk_hud_state_change(PERK_ELECTRIC_CHERRY, state);
}

function perk_hud_state_change_widows(state)
{
	self perk_hud_state_change(PERK_WIDOWS_WINE, state);
}
