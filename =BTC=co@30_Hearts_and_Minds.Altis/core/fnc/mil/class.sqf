
private _factions = _this select 0;
private _en_AA = _this select 1;
private _en_tank = _this select 2;
private _hq = [];
private _enemy_side = [];
private _type_units = [];
private _type_divers = [];
private _divers = [];
private _type_crewmen = "";
private _type_boats = [];
private _type_motorized = [];
private _type_motorized_armed = [];
private _type_mg = [];
private _type_gl = [];

//Get all vehicles
private _allclasse = ("(configName _x) isKindOf 'AllVehicles'" configClasses (configFile >> "CfgVehicles")) apply {configName _x};

//Check if faction existe
_factions = _factions apply {if !isClass(configFile >> "CfgFactionClasses" >> _x) then {"IND_G_F"} else {_x};};

_enemy_side		= [east,west,independent,civilian] select getNumber(configfile >> "CfgFactionClasses" >> (_factions select 0) >> "side");
_hq				= [btc_hq_red,btc_hq_blu,btc_hq_green] select getNumber(configfile >> "CfgFactionClasses" >> (_factions select 0) >> "side");



//Select only faction from the same side
_factions = _factions select {([east,west,independent,civilian] select getNumber(configfile >> "CfgFactionClasses" >> _x >> "side")) isEqualTo _enemy_side};
//Prevent selecting same side as player side
if (_enemy_side isEqualTo btc_player_side) exitWith {
	[["IND_G_F"], _en_AA, _en_tank] call btc_fnc_mil_class;
};

{
	private _faction = _x;

	//Get all vehicles of the _faction selected
	private _allclasse_f = _allclasse select {(toUpper getText(configFile >> "cfgvehicles" >> _x >> "faction")) isEqualTo _faction};

	//Units
	_divers	= _allclasse_f select {!((_x find "diver") isEqualTo -1)};
	if (_divers isEqualTo []) then {_divers = if (_hq isEqualTo btc_hq_red) then {["O_diver_F","O_diver_exp_F","O_diver_TL_F"]} else {["I_diver_F","I_diver_exp_F","I_diver_TL_F"]};};
	_type_divers	append _divers;
	_type_units		append ((_allclasse_f select {_x isKindOf "Man"}) - _divers);

	//Vehicles
	_type_boats		append _allclasse_f select {_x isKindOf "Ship"};
	if (_type_boats isEqualTo []) then {_type_boats append ["I_Boat_Armed_01_minigun_F","I_Boat_Transport_01_F","I_SDV_01_F","I_G_Boat_Transport_01_F"];};
	_type_motorized	append (if (_en_tank) then {
			_allclasse_f select {(_x isKindOf "Tank") || (_x isKindOf "Car") || (_x isKindOf "Truck") || (_x isKindOf "Truck_F")}
		} else {
			_allclasse_f select {(_x isKindOf "Car") || (_x isKindOf "Truck") || (_x isKindOf "Truck_F")}
		});
	_type_motorized_armed append (_allclasse_f select {((_x isKindOf "Air") || (_x isKindOf "Helicopter") || (_x isKindOf "Tank") || (_x isKindOf "Car"))}); //need call btc_fnc_find_veh_with_turret

	//Static
	_type_mg		append _allclasse_f select {_x isKindOf "StaticGrenadeLauncher"};
	if (_type_mg isEqualTo []) then {_type_mg = ["O_HMG_01_F","O_HMG_01_high_F"];};
	_type_gl		append _allclasse_f select {_x isKindOf "StaticMGWeapon"};
	if (_type_gl isEqualTo []) then {_type_mg = ["O_GMG_01_F","O_GMG_01_high_F"];};
} forEach _factions;

//Final filter unwanted units type
if !(_en_AA) then {
	//Remove Anti-Air Units
	_type_units		= _type_units select {(_x find "AA") isEqualTo -1};
};
_type_units		= _type_units select {((_x find "_base") isEqualTo -1) && ((_x find "_unarmed_") isEqualTo -1) && ((_x find "_VR_") isEqualTo -1)};
_type_crewmen	= _type_units select 0;
_type_motorized = (_type_motorized select {(_x find "UAV") isEqualTo -1}) select {(_x find "UGV")  isEqualTo -1};
_type_motorized_armed = (_type_motorized_armed select {(_x find "UAV") isEqualTo -1}) select {(_x find "UGV")  isEqualTo -1};

[_hq,_enemy_side,_type_units,_type_divers,_type_crewmen,_type_boats,_type_motorized,_type_mg,_type_gl,_type_motorized_armed]