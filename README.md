# skyrim-utils
SSEEdit scripts and utilities library to provide higher level of abstraction for everyday modding of Skyrim.

## individual scripts
### Skyrim - Make Craftable
Automaticaly generates Crafting recipe for selected WEAP/ARMO records. Adds all needed conditions and requirements. Required items will be selected according to items Keywords, if script can't do that - it will give a message in log with link on created recipe without required items.

### Skyrim - Make Temperable
Automaticaly generates Tempering recipe for selected WEAP/ARMO records. Adds all needed conditions and requirements. Required items will be selected according to items Keywords, if script can't do that - it will give a message in log with link on created recipe without required items.

### Skyrim - Generate Enchanted Versions
Automaticaly generates Enchanted Versions for selected WEAP/ARMO records.
Currently Script generates 31 enchanted copies of selected weapons per each, adds enchantment, alters new records value, and adds respected Suffixes for easy parsing and replace.
* For armors script will make only one enchanted copy per each, for now.
* All enchanted versions will have it's propper Temper COBJ records as well.
* For each selected record, will be created an individual Leveled List, with Base item + all it's enchanted versions. Each with count of 1, and based on enchantment level requirement
* Script works with Weapons/Shields/Bags/Bandanas/Armor/Clothing/Amulets/Wigs... every thing, but script won't find right item requirements for tempering wig or amulet... probably... However it will make a recipe, and it will log a message with link on that recipe.

## SkyrimUtils functions
#### isTemperable(recordToCheck: IInterface): boolean;
Determins if item have tempering recipe.
#### isCraftable(recordToCheck: IInterface): boolean;
Determins if item have crafting recipe.
#### isJewelry(item: IInterface): boolean;
Shalow way to recognize item as Jewelry.

#### addItem(list: IInterface; item: IInterface; amount: int) AddedListElement : IInterface;
Adds item to list/collection, like items/Leveled entries.

#### addToLeveledList(list: IInterface; entry: IInterface; level: int) AddedListElement : IInterface;
Adds item reference to the leveled list.

#### getRecordByFormID(id: str): IInterface;
Gets record by its HEX FormID ('00049BB7').
#### getPrice(item: IInterface): integer;
Gets item value, in invalid/not determined cases will return 0.
#### getMainMaterial(itemRecord: IInterface): IInterface;
Will try to figure out right material for provided item record.

#### hasKeyword(itemRecord: IInterface; keywordEditorID: str): bool;
Checks the provided keyword inside record.
#### addKeyword(itemRecord: IInterface; keyword: IInterface): int;
Adds keyword to the record, if it doesn't have one.
#### removeKeyword(itemRecord: IInterface; keywordEditorID: string): bool;
Removes keyword to the record, if it has one, returns true if was found and removed, false if not.

#### removeInvalidEntries(rec: IInterface);
Removes invalid entries from containers and recipe items, from Leveled lists, npcs and spells, based on 'Skyrim - Remove invalid entries'.

#### addPerkCondition(list: IInterface; perk: IInterface): IInterface;
Adds requirement 'HasPerk' to Conditions list.

#### createRecord(recordFile: IwbFile; recordSignature: str): IInterface;
Creates new record inside provided file. Will create record category in that file if needed.
#### createRecipe(itemRecord: IInterface): IInterface;
Creates COBJ record for item, with referencing on it in amount of 1.

#### makeTemperable(itemRecord: IInterface): IInterface;
Creates new COBJ record to make item Temperable.
#### makeCraftable(itemRecord: IInterface): IInterface;
Creates new COBJ record to make item Craftable at workbenches.
