#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_weapons;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#namespace zm_pap_util;

function init_parameters()
{
	if ( !isdefined( level.pack_a_punch ) )
	{
		level.pack_a_punch = SpawnStruct();
		level.pack_a_punch.timeout = 15;
		level.pack_a_punch.interaction_height = 35;
		level.pack_a_punch.move_in_func = &pap_weapon_move_in;
		level.pack_a_punch.move_out_func = &pap_weapon_move_out;
		level.pack_a_punch.grabbable_by_anyone = false;
		level.pack_a_punch.swap_attachments_on_reuse = false;
		level.pack_a_punch.triggers = [];
	}
}

function set_timeout( n_timeout_s )
{
	init_parameters();
	level.pack_a_punch.timeout = n_timeout_s;
}

function set_interaction_height( n_height )
{
	init_parameters();
	level.pack_a_punch.interaction_height = n_height;
}

function set_interaction_trigger_radius( n_radius )
{
	init_parameters();
	level.pack_a_punch.interaction_trigger_radius = n_radius;
}

function set_interaction_trigger_height( n_height )
{
	init_parameters();
	level.pack_a_punch.set_interaction_trigger_height = n_height;
}

function set_move_in_func( fn_move_weapon_in )
{
	init_parameters();
	level.pack_a_punch.move_in_func = fn_move_weapon_in;
}

function set_move_out_func( fn_move_weapon_out )
{
	init_parameters();
	level.pack_a_punch.move_out_func = fn_move_weapon_out;
}

function set_grabbable_by_anyone()
{
	init_parameters();
	level.pack_a_punch.grabbable_by_anyone = true;
}

function get_triggers()
{
	init_parameters();
	return level.pack_a_punch.triggers;
}

function is_pap_trigger()
{
	return isdefined( self.script_noteworthy ) && self.script_noteworthy == "pack_a_punch";
}

function enable_swap_attachments()
{
	init_parameters();
	level.pack_a_punch.swap_attachments_on_reuse = true;
}

function can_swap_attachments()
{
	if( !isdefined(level.pack_a_punch) )
		return false;
	return level.pack_a_punch.swap_attachments_on_reuse;
}

// If player is holding an upgraded weapon, display AAT reroll
// self == PaP trigger
function update_hint_string( player )
{
	// if PaP machine is offering a gun, set to weapon grab string
	if ( self flag::get( "pap_offering_gun" ) )
	{
		self SetHintString( &"ZOMBIE_GET_UPGRADED_FILL" );
		return;
	}
	
	// Checks to see if player is holding an upgraded weapon
	w_curr_player_weapon = player GetCurrentWeapon();
	
	if ( zm_weapons::is_weapon_upgraded( w_curr_player_weapon ) )
	{
		self SetHintString( &"ZOMBIE_PERK_PACKAPUNCH_AAT", self.aat_cost );
	}
	// If not, display string to pack non-upgraded weapon
	else 
	{
		self SetHintString( &"ZOMBIE_PERK_PACKAPUNCH", self.cost );
	}
}

function private pap_weapon_move_in( player, trigger, origin_offset, angles_offset )
{
	level endon("Pack_A_Punch_off");
	trigger endon("pap_player_disconnected");
}

function private pap_weapon_move_out( player, trigger, origin_offset, interact_offset)
{
	level endon("Pack_A_Punch_off");
	trigger endon("pap_player_disconnected");
}