// 3arc - Core
#using scripts\codescripts\struct;

// 3arc - Shared
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\wardog\shared\wardog_shared.gsh; // This line is required so the below macro is valid
#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\shared\wardog_menu;
#using scripts\wardog\shared\wardog_shared_util;

#namespace wardog_menu;

function create_base(menu_name, hint)
{
	MAKE_ARRAY(level._wardog_menus)

	if(isdefined(level._wardog_menus[menu_name]))
		return;

	struct = SpawnStruct();
	struct.hint = hint;
	struct.buttons = [];

	level._wardog_menus[menu_name] = struct;
}

function is_menu(menu_name)
{
	if(isdefined(level._wardog_menus) && isdefined(level._wardog_menus[menu_name]))
		return true;
	return false;
}

function add_button(menu_name, button_name, hint, activate_func)
{
	if(!is_menu(menu_name))
		return;

	MAKE_ARRAY(level._wardog_menus[menu_name].buttons)

	if(isdefined(level._wardog_menus[menu_name].buttons[button_name]))
		return;

	struct = SpawnStruct();
	struct.hint = hint;
	struct.activate_func = activate_func;

	level._wardog_menus[menu_name].buttons[button_name] = struct;
}

function open_menu(menu_name, button_pressed = FALSE)
{
	if(!is_menu(menu_name))
		return;
	if(self is_menu_open(menu_name))
		return;
	if(self is_any_menu_open())
		self close_menu();

	self._wardog_current_menu = menu_name;

	MAKE_ARRAY(self._wardog_menu_huds)
	MAKE_ARRAY(self._wardog_menu_huds["buttons"])

	self._wardog_menu_huds["background"] = self create_hud();
	self._wardog_menu_huds["background"].horzAlign = "fullscreen";
	self._wardog_menu_huds["background"].vertAlign = "fullscreen";
	self._wardog_menu_huds["background"].alignX = "left";
	self._wardog_menu_huds["background"].alignY = "top";
	self._wardog_menu_huds["background"].sort = 101;
	self._wardog_menu_huds["background"] SetShader("black", 640, 480);

	if(isdefined(level._wardog_menus[menu_name].buttons))
	{
		foreach(key, button_name in GetArrayKeys(level._wardog_menus[menu_name].buttons))
		{
			hud = self create_hud();
			hud.y = (key * 10) + 20;
			hud.sort = 102;
			hud.fontscale = 1.8;
			hud SetText(level._wardog_menus[menu_name].buttons[button_name].hint);

			self._wardog_menu_huds["buttons"][button_name] = hud;
		}
	}

	if(isdefined(self._wardog_menu_huds))
	{
		foreach(button_name in GetArrayKeys(level._wardog_menus[menu_name].buttons))
		{
			self._wardog_menu_huds["buttons"][button_name] FadeOverTime(1);
			self._wardog_menu_huds["buttons"][button_name].alpha = 1;
		}

		self._wardog_menu_huds["background"] FadeOverTime(1);
		self._wardog_menu_huds["background"].alpha = .4;
	}

	self EnableInvulnerability();
	self DisableWeapons();
	self FreezeControls(true);

	self thread menu_think(menu_name, button_pressed);
	self thread close_menu_on_disconnect(menu_name);

	self notify("menu_open", menu_name);
	self notify("open_menu_" + menu_name);
}

function is_menu_open(menu_name)
{
	if(!is_menu(menu_name))
		return false;
	if(!isdefined(self._wardog_current_menu))
		return false;
	if(self._wardog_current_menu == menu_name)
		return true;
	return false;
}

function is_any_menu_open()
{
	if(!isdefined(self._wardog_current_menu))
		return false;
	if(!is_menu(self._wardog_current_menu))
		return false;
	return true;
}

function close_menu()
{
	if(!self is_any_menu_open())
		return;

	menu_name = self._wardog_current_menu;

	if(!is_menu(menu_name))
		return;

	self notify("menu_close", menu_name);
	self notify("close_menu_" + menu_name);

	self DisableInvulnerability();
	self EnableWeapons();
	self FreezeControls(false);

	if(isdefined(self._wardog_menu_huds))
	{
		foreach(button_name in GetArrayKeys(level._wardog_menus[menu_name].buttons))
		{
			self._wardog_menu_huds["buttons"][button_name] Destroy();
		}

		self._wardog_menu_huds["background"] Destroy();
	}

	self._wardog_current_menu = undefined;
}

function private create_hud()
{
	hud = NewClientHudElem(self);
	hud.alignX = "center";
	hud.alignY = "middle";
	hud.horzAlign = "center";
	hud.vertAlign = "middle";
	hud.foreground = true;
	hud.sort = 1;
	hud.hidewheninmenu = true;
	hud.x = 0;
	hud.y = 0;
	hud.alpha = 0;

	return hud;
}

function private menu_think(menu_name, button_pressed = FALSE)
{
	self endon("disconnect");
	self endon("close_menu_" + menu_name);

	pointer = 0;
	buttons = GetArrayKeys(level._wardog_menus[menu_name].buttons);
	self._wardog_menu_huds["buttons"][buttons[pointer]].color = YELLOW;

	if(IS_TRUE(button_pressed))
		flag = true;
	else
		flag = false;

	for(;;)
	{
		// waittill player stops the open menu process
		if(IS_TRUE(flag))
		{
			while(self UseButtonPressed() && self AdsButtonPressed())
			{
				WAIT_SERVER_FRAME
			}
			flag = false;
		}

		// Ads - Move up
		// Attack - Move down
		// Melee - Close
		// Use - Select

		WAIT_SERVER_FRAME

		if(self UseButtonPressed())
		{
			self activate_button(menu_name, buttons[pointer]);

			while(self UseButtonPressed())
			{
				WAIT_SERVER_FRAME
			}
		}

		if(self MeleeButtonPressed())
		{
			self thread close_menu();
			return;
		}

		if(self AdsButtonPressed())
		{
			while(self AdsButtonPressed())
			{
				self._wardog_menu_huds["buttons"][buttons[pointer]].color = WHITE;

				pointer--;

				if(pointer < 0)
					pointer = buttons.size - 1;

				self._wardog_menu_huds["buttons"][buttons[pointer]].color = YELLOW;

				wait 1;
			}
			continue;
		}

		if(self AttackButtonPressed())
		{
			while(self AttackButtonPressed())
			{
				self._wardog_menu_huds["buttons"][buttons[pointer]].color = WHITE;

				pointer++;

				if(pointer > buttons.size - 1)
					pointer = 0;

				self._wardog_menu_huds["buttons"][buttons[pointer]].color = YELLOW;

				wait 1;
			}
			continue;
		}
	}
}

function private close_menu_on_disconnect(menu_name)
{
	self endon("close_menu_" + menu_name);

	self waittill("disconnect");

	self thread close_menu();
}

function private activate_button(menu_name, button_name)
{
	if(isdefined(level._wardog_menus[menu_name].buttons[button_name].activate_func))
		util::single_thread(self, level._wardog_menus[menu_name].buttons[button_name].activate_func, menu_name, button_name);

	self notify("activate_menu_button", menu_name, button_name);
	self notify(menu_name + "_activate_" + button_name);
}

function thirdperson_on(menu_name, button_name)
{
	self SetClientThirdPerson(true);
}

function thirdperson_off(menu_name, button_name)
{
	self SetClientThirdPerson(false);
}
