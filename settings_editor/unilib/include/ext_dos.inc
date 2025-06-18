{$IFDEF WIN32}
{$I WIN32.INC}

Function FileExists(FileName : String) : Boolean;
var
  Handle: THandle;
  FindData: TWin32FindData;
  P : Pchar;
begin
  Filename:=Filename+#0;
  P:=Pchar(@Filename[1]);
  Handle := FindFirstFile(P, {$IFDEF FPC} @FindData {$ELSE} FindData {$ENDIF});
  Result:=Handle <> integer(INVALID_HANDLE_VALUE);
  If Result then
    Windows.FindClose(Handle);
end;

function GetLocaleStr(LID, LT: Longint; const Def: string): ShortString;
var
  L: Integer;
  Buf: array[0..255] of Char;
begin
  L := GetLocaleInfo(LID, LT, Buf, SizeOf(Buf));
  if L > 0 then SetString(Result, {$IFDEF FPC}@Buf[0]{$ELSE}Buf{$ENDIF}, L - 1)
  else Result := Def;
end;

function GetLocaleChar(LID, LT: Longint; Def: Char): Char;

var
  Buf: array[0..1] of Char;
begin
  if GetLocaleInfo(LID, LT, Buf, 2) > 0 then
    Result := Buf[0]
  else
    Result := Def;
end;
Function GetLocaleInt(LID,TP,Def: LongInt): LongInt;

Var
  S: String;
  C: Integer;

Begin
  S:=GetLocaleStr(LID,TP,'0');
  Val(S,Result,C);
  If C<>0 Then
    Result:=Def;
End;

procedure GetFormatSettings;
var
  HF  : Shortstring;
  LID : LCID;
  I,Day,DateOrder : longint;

begin
  LID := GetThreadLocale;
  { Date stuff }
  for I := 1 to 12 do
  begin
    ShortMonthNames[I]:=stWinToDos(GetLocaleStr(LID,LOCALE_SABBREVMONTHNAME1+I-1,ShortMonthNames[i]));
    LongMonthNames[I]:=stWinToDos(GetLocaleStr(LID,LOCALE_SMONTHNAME1+I-1,LongMonthNames[i]));
  end;
  for I := 1 to 7 do
  begin
    Day := (I + 5) mod 7;
    ShortDayNames[I]:=stWinToDos(GetLocaleStr(LID,LOCALE_SABBREVDAYNAME1+Day,ShortDayNames[i]));
    LongDayNames[I]:=stWinToDos(GetLocaleStr(LID,LOCALE_SDAYNAME1+Day,LongDayNames[i]));
  end;
  DateSeparator := GetLocaleChar(LID, LOCALE_SDATE, '/');
  DateOrder := GetLocaleInt(LID, LOCALE_IDate, 0);
  Case DateOrder Of
     1: Begin
        ShortDateFormat := 'dd/mm/yyyy';
        LongDateFormat := 'dddd, d. mmmm yyyy';
        End;
     2: Begin
        ShortDateFormat := 'yyyy/mm/dd';
        LongDateFormat := 'dddd, yyyy mmmm d.';
        End;
  else
    // Default american settings...
    ShortDateFormat := 'mm/dd/yyyy';
    LongDateFormat := 'dddd, mmmm d. yyyy';
  End;
  { Time stuff }
  TimeSeparator := GetLocaleChar(LID, LOCALE_STIME, ':');
  if StrToIntDef(GetLocaleStr(LID, LOCALE_ITLZERO, '0'), 0) = 0 then
    HF:='h'
  else
    HF:='hh';
  // No support for 12 hour stuff at the moment...
  ShortTimeFormat := HF+':mm';
  LongTimeFormat := HF + ':mm:ss';
  { Currency stuff }


  CurrencyString:=stWinToDos(GetLocaleStr(LID, LOCALE_SCURRENCY, ''));
  { Number stuff }
  ThousandSeparator:=GetLocaleChar(LID, LOCALE_STHOUSAND, ',');
  DecimalSeparator:=GetLocaleChar(LID, LOCALE_SDECIMAL, '.');
  CurrencyDecimals:=StrToIntDef(GetLocaleStr(LID, LOCALE_ICURRDIGITS, '0'), 0);
end;

procedure InitCountryEnvironment;
begin
{ InitAnsi;}
 GetFormatSettings;
end;

{$ENDIF}

{$IFDEF OS_DOS}
type
   TCountryInfoRec = record
     wDateFormat:word; { 0=USA (m d y), 1=Europe (d m y), 2=Japan (y m d)}
     szCrncySymb:array[0..4] of char;{currency symbol (ASCIIZ)}
     szThouSep  :array[0..1] of char;{thousands separator (ASCIIZ)}
     szDecSep   :array[0..1] of char;{decimal separator (ASCIIZ)}
     szDateSep  :array[0..1] of char;{date separator (ASCIIZ)}
     szTimeSep  :array[0..1] of char;{time separator (ASCIIZ)}
     bCrncyFlags:byte;{currency format flags}
     bCrncyDigits:byte;{decimals digits in currency}
     bTimeFormat:byte;  {time format}
     pfCasemap:Pointer;{Casemap FAR call address}
     szDataSep:array[0..1] of char;{data list separator (ASCIIZ)}
     res:array[0..9] of byte;{reserved zeros}
  end;

procedure GetCountryInfo(var Rec:TCountryInfoRec);
var R:Registers;
begin
  R.AX:=$3800;
  R.DS:=Seg(Rec);
  R.DX:=Ofs(Rec);
  MsDos(R);
end;

procedure InitCountryEnvironment;
var Rec:TCountryInfoRec;
begin
  GetCountryInfo(Rec);
  CurrencyString:=StrPas(Rec.szCrncySymb);

  DateSeparator:=Rec.szDateSep[0];{date separator}
  TimeSeparator:=Rec.szTimeSep[0];
  DecimalSeparator:=Rec.szDecSep[0];
  ThousandSeparator:=Rec.szThouSep[0];{thousands separator}
  CurrencyDecimals:=Rec.bCrncyDigits;{decimals digits in currency}
end;
{$ENDIF}
