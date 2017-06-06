#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

#namespace zm_harrybo21_utility;

//*****************************************************************************
// MAIN
//*****************************************************************************

function ignoreme_failsafe()
{
	self endon( "kill_ignoreme" );
	self endon( "death" );
	self endon( "fake_death" );
	self endon( "player_downed" );
	while( 1 )
	{
		if ( !isDefined( self.ignoreme ) || !self.ignoreme )
			self.ignoreme = 1;
		
		wait .05;
	}
}

function clear_ignoreme()
{
	if ( isDefined( self.zombie_blood ) && self.zombie_blood )
		return;
	
	if ( isDefined( self.vulture_level ) && self.vulture_level > 0 )
		return;
	
	hud = undefined;
	if ( isDefined( self.perk_hud ) && self.perk_hud.size > 0 )
	{
		for ( i = 0; i < self.perk_hud.size; i++ )
		{
			if ( self.perk_hud[ i ].perk == "specialty_vultureaid" )
			{
				hud = self.perk_hud[ i ];
				break;
			}
		}
	}
	
	if ( isDefined( hud ) && isDefined( hud.mist_hud ) && isDefined( hud.glow_hud ) )
	{
		hud.mist_hud.alpha = 0;
		hud.glow_hud.alpha = 0;
	}
	
	self.ignoreme = 0;
	self notify( "kill_ignoreme" );
}