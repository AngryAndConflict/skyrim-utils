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

	EDITOR_ID_MIGHT_BE_REQUIRED = 'WEAP ARMO AMMO BOOK MISC LVLI CELL NPC_';

procedure lint(recordToCheck: IInterface);
var
	recordSignature: string;
begin
	if GetIsDeleted(recordToCheck) then begin
		AddMessage(msgReallyBad + ' RECORD MARKED AS DELETED ' + msgHr + ' ' + Name(recordToCheck));
		Exit;
	end;

	recordSignature := Signature(recordToCheck);

  // linter ignoring records
	if (Pos(recordSignature, skipRecords) <> 0) then
		Exit;

	lintStrings(recordToCheck, recordSignature);
end;

procedure lintStrings(recordToCheck: IInterface; recordSignature: string);
var
	tmp: string;
begin
	if (Pos(recordSignature, EDITOR_ID_MIGHT_BE_REQUIRED) <> 0) then begin
		tmp := GetElementEditValues(recordToCheck, 'EDID');

		if not Assigned(tmp) then begin
			AddMessage(msgReallyBad + ' EditorID is missing ' + msgHr + ' ' + Name(recordToCheck));
		end else if ((tmp = '') or (Length(tmp) = 0)) then begin
			AddMessage(msgReallyBad + ' EditorID is empty string ' + msgHr + ' ' + Name(recordToCheck));
		end else if (Length(tmp) < 5) then begin
			AddMessage(msgBad + ' EditorID is too short to not become duplicate ' + msgHr + ' ' + Name(recordToCheck));
		end;
	end;

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
