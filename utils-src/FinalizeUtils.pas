// will free lists out of memory, if needed
procedure FinalizeUtils;
begin
  if Assigned(materialKeywordsMap) then
    materialKeywordsMap.Free;
  if Assigned(materialItemsMap) then
    materialItemsMap.Free;
end;
