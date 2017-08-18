{
	WARNING: it can, and probably will, hurt your feelings. You were warned.
	Linter checks selected records for bad patterns and not proper ways of using Skyrim mechanics.
		Few examples of behavior:
			xEdit won't shout an error if you are using more than 33 letters for FULL in record, but Creation Kit does, so Linter does that too.
			xEdit is more flexible and generic tool, so it won't check you are using right keywords in your mod, CK lacks that too... Linter will tell you that, and even will try to fix that

	------------------------

	This Linter is not following exact definition part of linters, because it can automatically fix some reporting "errors", but won't do that by default.
	For this feature, change tryToCorrect setting to true. It's experimental, so, please, as always you should, make a backup just in case, it won't save changes automatically, but it is a good practice to always have a backup.

	------------------------
	Hotkey: Ctrl+l
}

unit linter;

uses SkyrimUtils;

const
	// =Settings
	tryToCorrect = false;
	skipRecords = 'NAVM ACHR PGRE PHZD';

	msgHr = '---------->';

	// messages prefixes
	msgReallyBad = 'BAD!-->';
	msgNote = 'notice: ';
	msgCorrection = 'FIXING ATTEMPT:';

	// logical definitions
	EDITOR_ID_MAY_BE_REQUIRED = 'WEAP ARMO AMMO BOOK MISC LVLI CELL NPC_';
	FULL_NAME_MAY_BE_REQUIRED = 'WEAP ARMO AMMO BOOK MISC NPC_';
	PRICE_CONSIDERED_EXPENSIVE = 1000;

procedure report(recordToReport: IInterface);
begin
	if Assigned(logMessage) then begin
		AddMessage(Name(recordToReport) + ' ' + msgHr + #13#10 + logMessage);
		logMessage := nil;
	end;
end;

procedure lint(recordToCheck: IInterface);
var
	recordSignature: string;
begin
	if GetIsDeleted(recordToCheck) then begin
		log(msgReallyBad + ' RECORD MARKED AS DELETED');
		report(recordToCheck);
		Exit;
	end;

	recordSignature := Signature(recordToCheck);

	// linter ignoring records
	if (Pos(recordSignature, skipRecords) <> 0) then
		Exit;

	lintStrings(recordToCheck, recordSignature);

	if (recordSignature = 'NPC_') then begin
		lintNPC(recordToCheck, recordSignature);
	end else if (Pos(recordSignature, 'WEAP ARMO') <> 0) then begin
		lintEquipmentType(recordToCheck, recordSignature);
	end;

	lintKeywords(recordToCheck, recordSignature);
	lintAnimationType(recordToCheck, recordSignature);

	report(recordToCheck);
end;

procedure lintStrings(recordToCheck: IInterface; recordSignature: string);
var
	tmp: string;
begin
	if (Pos(recordSignature, EDITOR_ID_MAY_BE_REQUIRED) <> 0) then begin
		tmp := GetElementEditValues(recordToCheck, 'EDID');

		if not Assigned(tmp) then begin
			log(msgReallyBad + ' EditorID is missing');
		end else if ((tmp = '') or (Length(tmp) = 0)) then begin
			log(msgReallyBad + ' EditorID is empty string');
		end else if (Length(tmp) < 5) then begin
			warn('EditorID is too short to not become duplicate');
		end;
	end;

	if (Pos(recordSignature, FULL_NAME_MAY_BE_REQUIRED) <> 0) then begin
		tmp := GetElementEditValues(recordToCheck, 'FULL');

		if not Assigned(tmp) then begin
			log(msgNote + ' FULL Name is missing');

		end else if ((tmp = '') or (Length(tmp) = 0)) then begin
			log(msgNote + ' FULL Name is an empty string, it is recommended to be deleted it if not needed');

		end else if ((tmp[1] = ' ') or (tmp[Length(tmp)] = ' ')) then begin
			warn('FULL NAME have trailing space, CK does not like that');
			if tryToCorrect then begin
				log(msgCorrection + ' removing trailing spaces');
				SetElementEditValues(recordToCheck, 'FULL', Trim(tmp));
			end;
		end;

		tmp := GetElementEditValues(recordToCheck, 'FULL');
		if Assigned(tmp) then begin
			if (Length(tmp) > 33) then begin
				warn('FULL NAME length is more than 33 characters, CK does not like that');
			end;

			if (recordSignature = 'NPC_') then begin
				tmp := GetElementEditValues(recordToCheck, 'SHRT');
				if not Assigned(tmp) then begin
					log(msgNote + ' Short Name is missing for NPC, but FULL was provided');
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
			log(msgNote + ' NPC does not have a Class');
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
			log(msgReallyBad + ' NPC has more than 1 vendor faction' + #13#10'Vendor Factions:'#13#10 + sl.Text);
		end;

		vendorFactionsList.Free;

	end;
end;

procedure lintEquipmentType(recordToCheck: IInterface; recordSignature: string);
var
	tmp: IInterface;
begin
	if ((recordSignature = 'WEAP') or ((recordSignature = 'ARMO') and isShield(recordToCheck) )) then begin
		tmp := GetElementEditValues(recordToCheck, 'ETYP');

		if not Assigned(tmp) then begin
			log(msgReallyBad + ' ETYP (Equipment Type) is missing');
		end;

	end;
end;

procedure lintAnimationType(recordToCheck: IInterface; recordSignature: string);
var
	tmp: IInterface;
begin
	if (recordSignature = 'WEAP') then begin
		tmp := GetElementEditValues(recordToCheck, 'DNAM\Animation Type');

		if Assigned(tmp) then begin
			if isStaff(recordToCheck) then begin
				if not (tmp = 'Staff') then begin
					log(msgNote + ' item was recognized as Staff but Animation Type is not Staff');
				end;
			end;
		end;

	end;
end;

procedure lintKeywords(recordToCheck: IInterface; recordSignature: string);
var
	tmp: IInterface;
begin
	if (isStaff(recordToCheck) and (recordSignature = 'WEAP')) then begin
		if not hasKeyword(recordToCheck, 'WeapTypeStaff') then begin // WeapTypeStaff [KYWD:0001E716]
			warn('item was recognized as Staff but WeapTypeStaff keyword is missing');
			if tryToCorrect then begin
				log(msgCorrection + ' adding WeapTypeStaff keyword');
				addKeyword(recordToCheck, 'WeapTypeStaff [KYWD:0001E716]');
			end;
		end else if not hasKeyword(recordToCheck, 'VendorItemStaff') then begin // VendorItemStaff [KYWD:000937A4]
			warn('item was recognized as Staff but VendorItemStaff keyword is missing');
			if tryToCorrect then begin
				log(msgCorrection + ' adding VendorItemStaff keyword');
				addKeyword(recordToCheck, 'VendorItemStaff [KYWD:000937A4]');
			end;
		end;
	end;

	if (((recordSignature = 'WEAP') or (recordSignature = 'ARMO') or (recordSignature = 'AMMO')) and not isStaff(recordToCheck)) then begin
		// WEAP/ARMO/AMMO item records should have Material keyword
		tmp := getMainMaterial(recordToCheck);
		if not Assigned(tmp) then begin
			log(msgReallyBad + ' keyword for Material definition is missing or invalid');
		end;

		// sellable item records should have right VendorItem keyword
		if (recordSignature = 'WEAP') then begin
			if not hasKeyword(recordToCheck, 'VendorItemWeapon') then begin
				log(msgReallyBad + ' VendorItem keyword is missed or invalid');
				if tryToCorrect then begin
					log(msgCorrection + ' adding VendorItemWeapon keyword');
					addKeyword(recordToCheck, 'VendorItem [KYWD:0008F958]');
				end;
			end;
		end;

		// sellable item records should have right VendorItem keyword
		if (recordSignature = 'AMMO') then begin
			if not hasKeyword(recordToCheck, 'VendorItemArrow') then begin // VendorItemArrow [KYWD:000917E7]
				log(msgReallyBad + ' VendorItem keyword is missed or invalid');
				if tryToCorrect then begin
					log(msgCorrection + ' adding VendorItem keyword');
					addKeyword(recordToCheck, 'VendorItemArrow [KYWD:000917E7]');
				end;
			end;
		end;

		if (recordSignature = 'ARMO') then begin

			if isJewelry(recordToCheck) then begin

				if not hasKeyword(recordToCheck, 'ArmorJewelry') then begin // ArmorJewelry [KYWD:0006BBE9]
					warn('item was recognized as Jewelry but ArmorJewelry keyword is missing');
					if tryToCorrect then begin
						log(msgCorrection + ' adding ArmorJewelry keyword');
						addKeyword(recordToCheck, 'ArmorJewelry [KYWD:0006BBE9]');
					end;
				// sellable item records should have right VendorItem keyword
				end else if not hasKeyword(recordToCheck, 'VendorItemJewelry') then begin // VendorItemJewelry [KYWD:0008F95A]
					warn('item was recognized as Jewelry but VendorItemJewelry keyword is missing');
					if tryToCorrect then begin
						log(msgCorrection + ' adding VendorItemJewelry keyword');
						addKeyword(recordToCheck, 'VendorItemJewelry [KYWD:0008F95A]');
					end;
				end;

				tmp := GetElementEditValues(recordToCheck, 'BOD2\Armor Type');
				if not Assigned(tmp) then begin
					log(msgReallyBad + ' item was recognized as Jewelry but BOD2\Armor Type property is missing');
				end else begin

					if not (tmp = 'Clothing') then begin
						log(msgNote + ' item was recognized as Jewelry but BOD2\Armor Type property is not Clothing');
					end;

				end;

				tmp := GetElementEditValues(recordToCheck, 'BOD2\First Person Flags');
				if Assigned(tmp) then begin
					if tmp = 000001 then begin // Amulet only

						if not hasKeyword(recordToCheck, 'ClothingNecklace') then begin
							warn('item is Amulet, but ClothingNecklace keyword is missing');

							if tryToCorrect then begin
								log(msgCorrection + ' adding ClothingNecklace keyword');
								addKeyword(recordToCheck, 'ClothingNecklace [KYWD:0010CD0A]');
							end;

						end;

					end;
				end;

				if (getPrice(recordToCheck) > PRICE_CONSIDERED_EXPENSIVE) then begin
					if not hasKeyword(recordToCheck, 'JewelryExpensive') then begin // JewelryExpensive [KYWD:000A8664]
						log(msgNote + ' item was recognized as Jewelry, and it costs more than ' + PRICE_CONSIDERED_EXPENSIVE + ' septims, it may need JewelryExpensive keyword');

						if tryToCorrect then begin
							log(msgCorrection + ' adding JewelryExpensive keyword');
							addKeyword(recordToCheck, 'JewelryExpensive [KYWD:000A8664]');
						end;
					end;
				end;

			// /isJewelry
			end else begin
				// ArmorHelmet [KYWD:0006C0EE]
				// ArmorHeavy [KYWD:0006BBD2]
				// ArmorLight [KYWD:0006BBD3]
				// ArmorCuirass [KYWD:0006C0EC]
				// ArmorClothing [KYWD:0006BBE8]
				// ArmorBoots [KYWD:0006C0ED]

				// sellable item records should have right VendorItem keyword
				if not (hasKeyword(recordToCheck, 'VendorItemArmor') or hasKeyword(recordToCheck, 'VendorItemClothing')) then begin
					log(msgReallyBad + ' VendorItem keyword is missed or invalid');

					if tryToCorrect then begin
						log(msgCorrection + ' adding VendorItemArmor keyword');
						addKeyword(recordToCheck, 'VendorItemArmor [KYWD:0008F959]');
					end;

				end;

				if isShield(recordToCheck) then begin
					if not hasKeyword(recordToCheck, 'ArmorShield') then begin // ArmorShield [KYWD:000965B2]
						warn('item was recognized as Shield, but ArmorShield keyword is missing');
						if tryToCorrect then begin
							log(msgCorrection + ' adding ArmorShield keyword');
							addKeyword(recordToCheck, 'ArmorShield [KYWD:000965B2]');
						end;
					end;
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
