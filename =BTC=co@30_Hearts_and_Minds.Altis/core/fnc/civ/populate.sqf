params ["_city", "_area", "_n"];

private _pos = position _city;
private _houses = [];

for [{_i = 25}, {_i < _area}, {_i = _i + 50}] do {
    private _hs = [[(_pos select 0) + _i, (_pos select 1) + _i, 0], 50] call btc_fnc_getHouses;
    _houses append _hs;
    _hs = [[(_pos select 0) + _i, (_pos select 1) - _i, 0], 50] call btc_fnc_getHouses;
    _houses append _hs;
    _hs = [[(_pos select 0) - _i, (_pos select 1) - _i, 0], 50] call btc_fnc_getHouses;
    _houses append _hs;
    _hs = [[(_pos select 0) - _i, (_pos select 1) + _i, 0], 50] call btc_fnc_getHouses;
    _houses append _hs;
};

if (_houses isEqualTo []) exitWith {};

for "_i" from 0 to _n do {
    [{
        params [
            ["_houses", [], [[]]]
        ];

        if (_houses isEqualTo []) exitWith {};

        private _house = selectRandom _houses;
        private _unit_type = selectRandom btc_civ_type_units;

        _group = createGroup civilian;
        _group createUnit [_unit_type, _house buildingPos 0, [], 0, "NONE"];
        _group setVariable ["btc_data_inhouse", [_house buildingPos 0]];
        [_group] call btc_fnc_civ_addWP;
        {_x call btc_fnc_civ_unit_create} forEach units _group;
        _houses = _houses - [_house];

    }, [_houses], _i] call CBA_fnc_waitAndExecute;
};

_n
