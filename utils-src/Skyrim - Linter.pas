{

	------------------------
	Hotkey: Ctrl+l
}

unit linter;

uses SkyrimUtils;

const
	// =Settings
	tryToCorrect = false;

  msgHr = '---------->';
	msgReallyBad = '---BAD!---';
	msgBad = '---Silent erorr---';
	msgNote = '--notice: ';
	msgCorrection = '-FIXING ATTEMPT--';

  skipRecords = 'NAVM ACHR PGRE PHZD';

procedure lint(recordToCheck: IInterface);
begin
	if GetIsDeleted(recordToCheck) then begin
		AddMessage(msgReallyBad + ' RECORD MARKED AS DELETED ' + msgHr + ' ' + Name(recordToCheck));
		Exit;
	end;

  // linter ignoring records
	if (Pos(Signature(recordToCheck), skipRecords) <> 0) then
		Exit;

end;

function Process(selectedRecord: IInterface): integer;
begin

end;

function Finalize: integer;
begin
	FinalizeUtils();
end;

end.
