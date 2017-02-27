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
var
	itemSignature: string;
begin
	if GetIsDeleted(recordToCheck) then begin
		AddMessage(msgReallyBad + ' RECORD MARKED AS DELETED ' + msgHr + ' ' + Name(recordToCheck));
		Exit;
	end;

	itemSignature := Signature(recordToCheck);

  // linter ignoring records
	if (Pos(itemSignature, skipRecords) <> 0) then
		Exit;

	lintStrings(recordToCheck, itemSignature);
end;

procedure lintStrings(recordToCheck: IInterface; itemType: string);
var
	tmp: string;
begin
	
end;

function Process(selectedRecord: IInterface): integer;
begin
  lint(selectedRecord);
end;

function Finalize: integer;
begin
	FinalizeUtils();
end;

end.
