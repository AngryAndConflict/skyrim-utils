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

	EDITOR_ID_MAY_BE_REQUIRED = 'WEAP ARMO AMMO BOOK MISC LVLI CELL NPC_';
	FULL_NAME_MAY_BE_REQUIRED = 'WEAP ARMO AMMO BOOK MISC NPC_';

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

	if (itemType = 'NPC_') then begin
		lintNPC(recordToCheck, recordSignature);
	end;
end;

procedure lintStrings(recordToCheck: IInterface; recordSignature: string);
var
	tmp: string;
begin
	if (Pos(recordSignature, EDITOR_ID_MAY_BE_REQUIRED) <> 0) then begin
		tmp := GetElementEditValues(recordToCheck, 'EDID');

		if not Assigned(tmp) then begin
			AddMessage(msgReallyBad + ' EditorID is missing ' + msgHr + ' ' + Name(recordToCheck));
		end else if ((tmp = '') or (Length(tmp) = 0)) then begin
			AddMessage(msgReallyBad + ' EditorID is empty string ' + msgHr + ' ' + Name(recordToCheck));
		end else if (Length(tmp) < 5) then begin
			AddMessage(msgBad + ' EditorID is too short to not become duplicate ' + msgHr + ' ' + Name(recordToCheck));
		end;
	end;

	if (Pos(recordSignature, FULL_NAME_MAY_BE_REQUIRED) <> 0) then begin
		tmp := GetElementEditValues(recordToCheck, 'FULL');

		if not Assigned(tmp) then begin
			AddMessage(msgNote + ' FULL Name is missing ' + msgHr + ' ' + Name(recordToCheck));

		end else if ((tmp = '') or (Length(tmp) = 0)) then begin
			AddMessage(msgNote + ' FULL Name is an empty string, it is recomanded to be deleted it if not using: ' + msgHr + ' ' + Name(recordToCheck));

		end else if ((tmp[1] = ' ') or (tmp[Length(tmp)] = ' ')) then begin
			AddMessage(msgBad + ' FULL NAME have trailing space, CK does not like that ' + msgHr + ' ' + Name(recordToCheck));
			if tryToCorrect then begin
				AddMessage(msgCorrection + ' removing trailing spaces: ' + msgHr + ' ' + Name(recordToCheck));
				SetElementEditValues(recordToCheck, 'FULL', Trim(tmp));
			end;
		end;

		tmp := GetElementEditValues(recordToCheck, 'FULL');
		if Assigned(tmp) then begin
			if (Length(tmp) > 33) then begin
				AddMessage(msgBad + ' FULL NAME length is more than 33 characters, CK does not like that ' + msgHr + ' ' + Name(recordToCheck));
			end;
		end;

		if (recordSignature = 'NPC_') then begin
			tmp := GetElementEditValues(recordToCheck, 'FULL');

			if Assigned(tmp) then begin
				tmp := GetElementEditValues(recordToCheck, 'SHRT');
				if not Assigned(tmp) then begin
					AddMessage(msgNote + ' Short Name is missing for NPC, but FULL was provided ' + msgHr + ' ' + Name(recordToCheck));
				end;
			end;

		end;
	end;

end;

procedure lintNPC(recordToCheck: IInterface; recordSignature: string);
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
