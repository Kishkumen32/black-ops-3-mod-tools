#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_perk_widows_wine.gsh;

#using scripts\zm\_zm_powerup_ww_grenade;

#precache( "client_fx", WIDOWS_WINE_FX_FILE_WRAP );
#precache( "client_fx", WIDOWS_WINE_1P_EXPLOSION );
#precache( "client_fx", "zombie/fx_perk_juggernaut_factory_zmb" );

#namespace zm_perk_widows_wine;

REGISTER_SYSTEM( "zm_perk_widows_wine", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	level.script = GetDvarString( "mapname" );
	
	if ( level.script == "zm_factory"  || level.script == "zm_prototype" || level.script == "zm_asylum" || level.script == "zm_sumpf" || level.script == "zm_theater" || level.script == "zm_cosmodrome" || level.script == "zm_temple" || level.script == "zm_moon" )
		return;
		
	zm_perks::register_perk_clientfields( 	PERK_WIDOWS_WINE, &widows_wine_client_field_func, &widows_wine_code_callback_func );
	zm_perks::register_perk_effects( 		PERK_WIDOWS_WINE, WIDOWS_WINE_FX_MACHINE_LIGHT );
	zm_perks::register_perk_init_thread( 	PERK_WIDOWS_WINE, &init_widows_wine );
	
	clientfield::register( "toplayer", "widows_wine_1p_contact_explosion", VERSION_SHIP, 1, "counter", &widows_wine_1p_contact_explosion, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );
}


function init_widows_wine()
{
	level._effect[ WIDOWS_WINE_FX_MACHINE_LIGHT ]	= "zombie/fx_perk_juggernaut_factory_zmb";
	level._effect[ WIDOWS_WINE_FX_WRAP ]			= WIDOWS_WINE_FX_FILE_WRAP;
}

function widows_wine_client_field_func()
{
	clientfield::register( "actor", CF_WIDOWS_WINE_WRAP, VERSION_SHIP, 1, "int", &widows_wine_wrap_cb, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	clientfield::register( "vehicle", CF_WIDOWS_WINE_WRAP, VERSION_SHIP, 1, "int", &widows_wine_wrap_cb, !CF_HOST_ONLY, !CF_CALLBACK_ZERO_ON_NEW_ENT );	
}

function widows_wine_code_callback_func() {}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function widows_wine_wrap_cb( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	if( newVal )
	{
		if ( isDefined( self ) && isAlive( self ) )
		{
			if ( !isDefined( self.fx_widows_wine_wrap ) )
				self.fx_widows_wine_wrap = playFxOnTag( localClientNum, level._effect[WIDOWS_WINE_FX_WRAP], self, "j_spineupper" );
			
			if ( !isDefined( self.sndWidowsWine ) )
			{
				self playsound( 0, "wpn_wwgrenade_cocoon_imp" );
				self.sndWidowsWine = self playloopsound( "wpn_wwgrenade_cocoon_lp", .1 );
			}
		}
	}
	else
	{
		if ( isDefined( self.fx_widows_wine_wrap ) )
		{
			stopFX( localClientNum, self.fx_widows_wine_wrap );
			self.fx_widows_wine_wrap = undefined;
		}
		if( isDefined( self.sndWidowsWine ) )
		{
			self playSound( 0, "wpn_wwgrenade_cocoon_stop" );
			self stopLoopSound( self.sndWidowsWine, .1 );
		}
	}
}

function widows_wine_1p_contact_explosion( localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump )
{
	owner = self getOwner( localClientNum );
	if ( isDefined( owner ) && owner == getLocalPlayer( localClientNum ) )
		thread widows_wine_1p_contact_explosion_play( localClientNum );
	
}

function widows_wine_1p_contact_explosion_play( localClientNum )
{
	tag = "tag_flash";

	if ( !viewmodelHasTag( localClientNum, tag ) )
	{
		tag = "tag_weapon";
		if ( !viewmodelHasTag( localClientNum, tag ) )
			return;
		
	}

	fx_contact_explosion = playViewmodelFx( localClientNum, WIDOWS_WINE_1P_EXPLOSION, tag );
	wait 2;
	deleteFx( localClientNum, fx_contact_explosion, 1 );
}

