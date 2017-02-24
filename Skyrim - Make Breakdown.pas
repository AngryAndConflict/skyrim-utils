{
  Script generates recipe COBJ record for selected WEAP/ARMO records, to allow breaking item to its original main material, with HasItem conditions and prefixes.

  NOTE: Should be applyed on records inside WEAPON/ARMOR (WEAP/ARMO) category of plugin you want to edit (script will not create new plugin)
}

unit GenerateBreakdowns;

uses SkyrimUtils;

// for every record selected in xEdit
function Process(selectedRecord: IInterface): integer;
begin
  makeBreakdown(selectedRecord);
  Result := 0;
end;

// runs in the end
function Finalize: integer;
begin
  FinalizeUtils();
  AddMessage('---Greenish Skyrim for everybody!---');
  Result := 0;
end;

end.
