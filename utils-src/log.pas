procedure log(msg: string);
begin
  if Assigned(logMessage) then begin
    logMessage := logMessage + #13#10#9 + msg;
  end else begin
    logMessage := #9 + msg;
  end;
end;
