{
  New script template, only shows processed records
  Assigning any nonzero value to Result will terminate script
}
unit userscript;

// include SkyrimUtils functions
uses SkyrimUtils;

// Called before processing
// You can remove it if script doesn't require initialization code
function Initialize: integer;
begin
  Result := 0;
end;

// called for every record selected in xEdit
function Process(e: IInterface): integer;
begin
  Result := 0;

  // comment this out if you don't want those messages
  AddMessage('Processing: ' + FullPath(e));
  // same as above line, but using SkyrimUtils
  // log('Processing: ' + FullPath(e));

  // processing code goes here

end;

// Called after processing
function Finalize: integer;
begin
  Result := 0;

  // it will check if SkyrimUtils data variables were used and will clean them from memory
  // also finishes any needed internal processes like log()
  FinalizeUtils();

end;

end.
