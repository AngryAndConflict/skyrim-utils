// generic wrapper for logging control, to produce more readable logs
procedure log(msg: string);
begin
  // if log string is not empty => separate it with full new line and propper tab indentation
  if Assigned(logMessage) then begin
    logMessage := logMessage + #13#10#9 + msg;

  // not empty => only preppend with tab
  end else begin
    logMessage := #9 + msg;
  end;
end;
