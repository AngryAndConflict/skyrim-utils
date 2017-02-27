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
	EQUIPMENT_TYPE_IS_REQUIRED = 'WEAP ARMO';

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

	if (recordSignature = 'NPC_') then begin
		lintNPC(recordToCheck, recordSignature);
	end else if (Pos(recordSignature, EQUIPMENT_TYPE_IS_REQUIRED) <> 0) then begin
		lintEquipmentType(recordToCheck, recordSignature);
	end;

	lintKeywords(recordToCheck, recordSignature);
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
var
	factionsList, ent,
		faction, tmp: IInterface;

	i: integer;
	vendorFactionsList: TStringList;

begin
	if (recordSignature = 'NPC_') then begin
		tmp := GetElementEditValues(recordToCheck, 'CNAM');

		if not Assigned(tmp) then begin
			AddMessage(msgNote + ' NPC does not have a Class ' + msgHr + ' ' + Name(recordToCheck));
		end;

		// vendor NPCs should not have more than 1 Vendor Faction
		// based on 'Skyrim - List actors with more than one vendor faction'
		vendorFactionsList := TStringList.Create;

		factionsList := ElementByName(recordToCheck, 'Factions');

		for i := 0 to Pred(ElementCount(factionsList)) do begin
			ent := ElementByIndex(factionsList, i);
			faction := LinksTo(ElementByName(ent, 'Faction'));

			if GetElementNativeValues(faction, 'DATA\Flags') and $4000 > 0 then
				vendorFactionsList.Add(Name(faction));

		end;

		if vendorFactionsList.Count > 1 then begin
			AddMessage(msgReallyBad + ' NPC has more than 1 vendor faction ' + msgHr + Name(recordToCheck) + #13#10'Vendor Factions:'#13#10 + sl.Text);
		end;

		vendorFactionsList.Free;

	end;
end;

procedure lintEquipmentType(recordToCheck: IInterface; recordSignature: string);
var
	tmp: IInterface;
begin
	if (Pos(recordSignature, EQUIPMENT_TYPE_IS_REQUIRED) <> 0) then begin
		tmp := GetElementEditValues(recordToCheck, 'ETYP');

		if not Assigned(tmp) then begin
			AddMessage(msgReallyBad + ' ETYP (Equipment Type) is missing ' + msgHr + ' ' + Name(recordToCheck));
		end;

	end;
end;

procedure lintKeywords(recordToCheck: IInterface; recordSignature: string);
var
	tmp: IInterface;
begin
	if (isStaff(recordToCheck) and (recordSignature = 'WEAP')) then begin
		if not hasKeyword(recordToCheck, 'WeapTypeStaff') then begin // WeapTypeStaff [KYWD:0001E716]
			AddMessage(msgBad + ' item was recognized as Staff but WeapTypeStaff keyword is missing ' + msgHr + ' ' + Name(recordToCheck));
			if tryToCorrect then begin
				AddMessage(msgCorrection + ' adding WeapTypeStaff keyword : ' + msgHr + ' ' + Name(recordToCheck));
				addKeyword(recordToCheck, 'WeapTypeStaff [KYWD:0001E716]');
			end;
		end else if not hasKeyword(recordToCheck, 'VendorItemStaff') then begin // VendorItemStaff [KYWD:000937A4]
			AddMessage(msgBad + ' item was recognized as Staff but VendorItemStaff keyword is missing ' + msgHr + ' ' + Name(recordToCheck));
			if tryToCorrect then begin
				AddMessage(msgCorrection + ' adding VendorItemStaff keyword : ' + msgHr + ' ' + Name(recordToCheck));
				addKeyword(recordToCheck, 'VendorItemStaff [KYWD:000937A4]');
			end;
		end else begin
			tmp := GetElementEditValues(recordToCheck, 'DNAM\Animation Type');
			if Assigned(tmp) then begin
				if not (tmp = 'Staff') then begin
					AddMessage(msgNote + ' item was recognized as Staff but Animation Type is not Staff ' + msgHr + ' ' + Name(recordToCheck));
				end;
			end;
		end;
	end;

	if (((recordSignature = 'WEAP') or (recordSignature = 'ARMO') or (recordSignature = 'AMMO')) and not isStaff(recordToCheck)) then begin
		// WEAP/ARMO/AMMO item records should have Material keyword
		tmp := getMainMaterial(recordToCheck);
		if not Assigned(tmp) then begin
			AddMessage(msgReallyBad + ' keyword for Material definition is missing or not valid ' + msgHr + ' ' + Name(recordToCheck));
		end;

		// sellable item records should have right VendorItem keyword
		if (recordSignature = 'WEAP') then begin
			if not hasKeyword(recordToCheck, 'VendorItemWeapon') then begin
				AddMessage(msgReallyBad + ' VendorItem keyword is missed or not valid ' + msgHr + ' ' + Name(recordToCheck));
				if tryToCorrect then begin
					AddMessage(msgCorrection + ' adding VendorItemWeapon keyword : ' + msgHr + ' ' + Name(recordToCheck));
					addKeyword(recordToCheck, 'VendorItem [KYWD:0008F958]');
				end;
			end;
		end;

		// sellable item records should have right VendorItem keyword
		if (recordSignature = 'AMMO') then begin
			if not hasKeyword(recordToCheck, 'VendorItemArrow') then begin // VendorItemArrow [KYWD:000917E7]
				AddMessage(msgReallyBad + ' VendorItem keyword is missed or not valid ' + msgHr + ' ' + Name(recordToCheck));
				if tryToCorrect then begin
					AddMessage(msgCorrection + ' adding VendorItem keyword : ' + msgHr + ' ' + Name(recordToCheck));
					addKeyword(recordToCheck, 'VendorItemArrow [KYWD:000917E7]');
				end;
			end;
		end;

// ArmorHelmet [KYWD:0006C0EE]
// ArmorHeavy [KYWD:0006BBD2]
// ArmorJewelry [KYWD:0006BBE9]
// ArmorLight [KYWD:0006BBD3]
// ArmorCuirass [KYWD:0006C0EC]
// ArmorClothing [KYWD:0006BBE8]
// ArmorBoots [KYWD:0006C0ED]

		if (recordSignature = 'ARMO') then begin

			if isJewelry(recordToCheck) then begin

				if not hasKeyword(recordToCheck, 'ArmorJewelry') then begin // ArmorJewelry [KYWD:0006BBE9]
					AddMessage(msgBad + ' item was recognized as Jewelry but ArmorJewelry keyword is missing ' + msgHr + ' ' + Name(recordToCheck));
					if tryToCorrect then begin
						AddMessage(msgCorrection + ' adding ArmorJewelry keyword : ' + msgHr + ' ' + Name(recordToCheck));
						addKeyword(recordToCheck, 'ArmorJewelry [KYWD:0006BBE9]');
					end;
				// sellable item records should have right VendorItem keyword
				end else if not hasKeyword(recordToCheck, 'VendorItemJewelry') then begin // VendorItemJewelry [KYWD:0008F95A]
					AddMessage(msgBad + ' item was recognized as Jewelry but VendorItemJewelry keyword is missing ' + msgHr + ' ' + Name(recordToCheck));
					if tryToCorrect then begin
						AddMessage(msgCorrection + ' adding VendorItemJewelry keyword : ' + msgHr + ' ' + Name(recordToCheck));
						addKeyword(recordToCheck, 'VendorItemJewelry [KYWD:0008F95A]');
					end;
				end;

	//			tmp := GetElementEditValues(recordToCheck, 'BOD2');
	//			if not Assigned(tmp) then begin
	//				AddMessage(msgReallyBad + ' item was recognized as Jewelry but BOD2 property is missing ' + msgHr + ' ' + Name(recordToCheck));
	//			end else begin
					tmp := GetElementEditValues(recordToCheck, 'BOD2\Armor Type');
					if not Assigned(tmp) then begin
						AddMessage(msgReallyBad + ' item was recognized as Jewelry but BOD2\Armor Type property is missing ' + msgHr + ' ' + Name(recordToCheck));
					end else begin
						if not (tmp = 'Clothing') then begin
							AddMessage(msgNote + ' item was recognized as Jewelry but BOD2\Armor Type property is not Clothing ' + msgHr + ' ' + Name(recordToCheck));
						end;
					end;
		//		end;

				tmp := GetElementEditValues(recordToCheck, 'BOD2\First Person Flags');
				if Assigned(tmp) then begin
					if tmp = 000001 then begin // Amulet only
						if not hasKeyword(recordToCheck, 'ClothingNecklace') then begin
							AddMessage(msgBad + ' item is Amulet, but ClothingNecklace keyword is missing ' + msgHr + ' ' + Name(recordToCheck));
							if tryToCorrect then begin
								AddMessage(msgCorrection + ' adding ClothingNecklace keyword : ' + msgHr + ' ' + Name(recordToCheck));
								addKeyword(recordToCheck, 'ClothingNecklace [KYWD:0010CD0A]');
							end;
						end;
					end;
				end;

				if (getPrice(recordToCheck) > 1000) then begin
					if not hasKeyword(recordToCheck, 'JewelryExpensive') then begin // JewelryExpensive [KYWD:000A8664]
						AddMessage(msgNote + ' item was recognized as Jewelry, and it costs more than 1000 septims, it may need JewelryExpensive keyword ' + msgHr + ' ' + Name(recordToCheck));

						if tryToCorrect then begin
							AddMessage(msgCorrection + ' adding JewelryExpensive keyword : ' + msgHr + ' ' + Name(recordToCheck));
							addKeyword(recordToCheck, 'JewelryExpensive [KYWD:000A8664]');
						end;
					end;
				end;

			// /isJewelry
			end else begin
				// sellable item records should have right VendorItem keyword
				if not (hasKeyword(recordToCheck, 'VendorItemArmor') or hasKeyword(recordToCheck, 'VendorItemClothing')) then begin
					AddMessage(msgReallyBad + ' VendorItem keyword is missed or not valid ' + msgHr + ' ' + Name(recordToCheck));
			//		if tryToCorrect then begin
			//			AddMessage(msgCorrection + ' adding VendorItemArmor keyword : ' + msgHr + ' ' + Name(recordToCheck));
			//			addKeyword(recordToCheck, 'VendorItemArmor [KYWD:0008F959]');
			//		end;
				end;

			end; // /not isJewelry

		end; // /ARMO

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
