{************************************************}
{                                                }
{   Extended string functions                    }
{                                                }
{   Turbo Pascal 7                               }
{   FreePacal                                    }
{   Delphi 2 - 5                                 }
{   Virtual Pascal 2.1                           }
{                                                }
{   Copyright (c) 1995-2000 by Alexs             }
{                                                }
{************************************************}

{$I Define.inc}
unit Ext_Str;

interface
uses Ext_Type, Objects, SysUtils;

const
  wtUnknow  = 0;
  wtInteger = 1;
  wtReal    = 2;
  wtString  = 3;

const
{$IFDEF LINUX}
  cEoL      = #10;
{$ELSE}
  cEoL      = #13#10;
{$ENDIF}

type
  TNumStr       = string[15];

function DupChar( AChar:Char; ACount:byte):string;
function CountChar(var Buf; Len:word; TestChar:char):word;
function FindChar(var Buf; Len:word; TestChar:char):word;

function chDosToWin(C:Char):Char;
function chWinToDos(C:Char):Char;
function stDosToWin(S:string):string;
function stWinToDos(S:string):string;
procedure bufDosToWin(var Buf; Count:word);
procedure bufWinToDos(var Buf; Count:word);

function ChLoCase(C: Char) : Char;
function ChUpCase(C: Char) : Char;

function StLoCase(const S : string) : string;
function StUpCase(const S : string) : string;
function AnsiUpperCase(const S : string) : string;
//{$IFDEF VER70}
//function chUniToDos(C:WideChar):Char;
//{$ENDIF}
procedure UniConvBuf(var Sours,Dest; Len:integer);

procedure FillSpace(var S:string; Count:byte);
function FillSpaceA(S:string; Count:byte):string;
//function TrimLeft(s:string):string;
//function TrimRight(s:string):string;
//function Trim(S:string):string;
function Compare(S1,S2:string):integer;
function ASCIICompare(S1,S2:string):integer;
function AnsiCompareText(S1,S2:string):integer;

//procedure AssignStr(var P:PString; const S:string);
function DinamicStr(P:PString):string;
//function IsHotKey(EvChar, HotChar: char): boolean;
function HotKey(const S: String): Char;
//{$IFDEF VER70}
//procedure SetLength(var S:string; Len:integer);
//{$ENDIF}

function NextWord(const S:string;var i:integer):string;
function ParseString(var S:String; Len:byte):string;
function CheckNum(const S:TNumStr):boolean;
function CheckIdentificator(const S:string):boolean;
function MakeAlign(Align:TAlign; S:string; Len:integer):string;
function WordType(S:String):byte;
function AddQuete(const S:string):string;
function DelQuete(const S:string):string;
function NameCase(S:string):string;

            {Quote}
//{$IFNDEF UseDrivers}
//procedure FormatStr(var Result: String; const Format: string; var Params);
//{$ENDIF}
const
  WordChars: set of Char = ['0'..'9', 'A'..'Z', '_', 'a'..'z'];
  Digit = ['0'..'9'];


implementation
uses Ext_Math;

function DinamicStr(P:PString):string;
begin
  if P<>nil then DinamicStr:=P^ else DinamicStr:='';
end;

function ChUpCase(C: Char) : Char;
begin
  ChUpCase := UpCase(C);
end;

function ChLoCase(C: Char) : Char;
begin
  ChLoCase := LowerCase(C);
end;

function StUpCase(const S : string) : string;
var i:integer;
begin
  StUpCase := '';
  for i:=1 to Length(S) do StUpCase := StUpCase + ChUpCase(S[i]);
end;

function StLoCase(const S : string) : string;
var i:integer;
begin
  StLoCase := '';
  for i:=1 to Length(S) do StLoCase := StLoCase + ChLoCase(S[i]);
end;

function DupChar( AChar:Char; ACount:byte):string;
var S:string;
    i:integer;
begin
  s:='';
  for i:=1 to ACount do S:=S+AChar;
  DupChar:=S;
end;

function CountChar(var Buf; Len:word; TestChar:char):word;
var i,C:integer;
    ABuf:TCharArray absolute Buf;
begin
  C:=0;
  for i:=0 to Len-1 do
    if ABuf[i]=TestChar then inc(C);
  CountChar:=C;
end;

function FindChar(var Buf; Len:word; TestChar:char):word;
var i:integer;
    ABuf:TCharArray absolute Buf;
begin
  FindChar:=0;
  for i:=0 to Len-1 do
    if ABuf[i]=TestChar then
    begin
      FindChar:=i;
      exit;
    end;
end;


//procedure AssignStr(var P: PString; const S: string);
//begin
//  if P <> nil then 
//    DisposeStr(P);
//  P := NewStr(S);
//end;

function ChDosToWin(C: Char): Char;
begin
  ChDosToWin := C;
end;

function ChWinToDos(C: Char): Char;
begin
  if (C > #192) and (C < #240) then ChWinToDos := Char(Byte(C) - 16 - 48)
  else
  if (C >= #240) then ChWinToDos := Char(Byte(C) - 16)
  else ChWinToDos := C;
end;

procedure bufDosToWin(var Buf; Count:word);
var ABuf:TCharArray absolute Buf;
    I:integer;
begin
  for i:=0 to Count-1 do
    ABuf[i]:=chDosToWin(ABuf[i]);
end;

procedure bufWinToDos(var Buf; Count:word);
var ABuf:TCharArray absolute Buf;
    I:integer;
begin
  for i:=0 to Count-1 do
    ABuf[i]:=chWinToDos(ABuf[i]);
end;

function stDosToWin(S:string):string;
var I:integer;
begin
  for i:=1 to length(S) do
      S[i]:=chDosToWin(S[i]);
  stDosToWin:=S;
end;

function stWinToDos(S:string):string;
var I:integer;
begin
  for i:=1 to length(S) do
      S[i]:=chWinToDos(S[i]);
  stWinToDos:=S;
end;

//function IsHotKey(EvChar, HotChar: char): boolean;
//{var
//  IsHot: boolean;}
//const
//  Cyr: array ['A'..'Z'] of char = 'ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ';
//begin
//  EvChar:=chUpCase(EvChar);
//  HotChar:=chUpCase(HotChar);
//  IsHotKey:=(EvChar = HotChar) or
//    ((EvChar in ['A'..'Z']) and (Cyr[EvChar] = HotChar)) or
//    (HotChar = 'Х') and (EvChar = '[') or
//    (HotChar = 'Ъ') and (EvChar = ']') or
//    (HotChar = 'Ж') and (EvChar = ';') or
//    (HotChar = 'Э') and (EvChar = '''') or
//    (HotChar = 'Б') and (EvChar = ',') or
//    (HotChar = 'Ю') and (EvChar = '.') or
//    (HotChar = 'Ё') and ((EvChar = '`') or (EvChar = '/'))
//end;

procedure FillSpace(var S:string; Count:byte);
begin
  S:=FillSpaceA(S,Count);
end;

function FillSpaceA(S:string; Count:byte):string;
begin
  if Length(S)>=Count then FillSpaceA:=Copy(S,1,Count)
  else FillSpaceA:=S+DupChar(' ',Count-Length(S))
end;

function ParseString(var S:String; Len:byte):string;
var i:byte;
begin
  if Length(S)<len then
  begin
    ParseString:=S;
    S:='';
    exit;
  end;
  for i:=len+1 downto 1 do
      if not (s[i] in WordChars) then break;
  if i=1 then i:=Len;
  ParseString:=Copy(S, 1, i);
  Delete(S,1,i);
end;

function NextWord(const S:string;var i:integer):string;
begin
  while (i<length(s)) and not (s[i] in WordChars) do inc(i);
  while (i<length(s)) and (s[i] in WordChars) do inc(i);
{  if i>0 then dec(i);}
  NextWord:=Copy(S,1,i-1);
end;

function HotKey(const S: String): Char;
var
  P: Word;
begin
  P := Pos('~',S);
  if P <> 0 then HotKey := chUpCase(S[P+1])
  else HotKey := #0;
end;

function CheckNum(const S: TNumStr): boolean;
//{$IFNDEF VER70}
//var i,Code: Longint;
//{$ELSE}
var 
  i, Code: integer;
//{$ENDIF}
begin
  Val(TrimRight(S), i, Code);
  CheckNum := Code = 0;
end;


function Compare(S1,S2:string):integer;
begin
  if S1>S2 then Compare:=1
  else
  if S1<S2 then Compare:=-1
  else Compare:=0
end;

function ASCIICompare(S1,S2:string):integer;
begin
  ASCIICompare:=Compare(S1,S2);
end;

function chUniToDos(C:WideChar):Char;
begin
//  chUniToDos:=Char(Lo(C));
end;

procedure UniConvBuf(var Sours,Dest; Len:integer);
var Sourse:TWideCharArray absolute Sours;
    D:TCharArray absolute Dest;
    i: integer;
begin
//  for i:=0 to Len do D[i]:=chUniToDos(Sourse[i]);
end;

function AnsiCompareText(S1, S2: string): integer;
begin
  AnsiCompareText := ASCIICompare(S1, S2);
end;

function AnsiUpperCase(const S: string): string;
begin
  AnsiUpperCase := stUpCase(S);
end;


function CheckIdentificator(const S:string):boolean;
var i:integer;
begin
  CheckIdentificator:=false;
  if chUpCase(S[1]) in ['_','A'..'Z'] then
  begin
     for i:=2 to Length(s) do
         if not (chUpCase(S[1]) in ['_','A'..'Z','0'..'9']) then
         exit;
     CheckIdentificator:=true;
  end;
end;

function MakeAlign(Align:TAlign; S:string; Len:integer):string;
begin
  case Align of
{     alLeft:MakeAlign:=Copy(TrimLeft(S),1,Len);}
     alLeft:MakeAlign:=Copy(S,1,Len);
     alCenter:
       if Length(s)<Len then MakeAlign:=DupChar(' ',(Len-Length(S)) div 2)+S
       else MakeAlign:=Copy( S, 1,Len);
     alRight:begin
             if Length(S)<Len then
                MakeAlign:=DupChar(' ',Len-Length(S))+S
             else MakeAlign:=Copy(S, 1, Len);
           end;
  else
     MakeAlign:=Copy(S, 1, Len);
  end;
end;

function WordType(S:String):byte;
var i:integer;
begin
  WordType:=wtUnknow;
  if S='' then exit;
  i:=1;
  while (s[i] in ['0'..'9']) and (i>=Length(s)) do
        inc(i);
  if i>=Length(s) then
  begin
    WordType:=wtInteger;
    exit;
  end;
  if s[i]='.' then
  begin
    inc(i);
    while (s[i] in ['0'..'9']) and (i=Length(s)) do
          inc(i);
    if i=Length(s) then
    begin
      WordType:=wtReal;
      exit;
    end;
  end;
  WordType:=wtString;
end;

function AddQuete(const S:string):string;
var R:string;
    i:integer;
    LoChars:boolean;
begin
  i:=1;
  R:='';
  LoChars:=false;
  while I<=Length(S) do
  begin
    if S[i]<' ' then
    begin
      if not LoChars then
      begin
        R:=R+'''';
        LoChars:=true;
      end;
      R:=R+'#'+IntToStr(ord(S[i]));
    end
    else
    begin
      if LoChars then
      begin
        R:=R+'''';
        LoChars:=false;
      end;
      if S[i]='''' then R:=R+'''';
      R:=R+S[i];
    end;
    inc(i);
  end;
  AddQuete:=''''+R+'''';
end;

function DelQuete(const S:string):string;
var R:string;
    i,j:integer;
    InString:boolean;
begin
  i:=1;
  R:='';
  InString:=false;
  while I<=Length(S) do
  begin
    if S[i]='''' then
      if InString then
        if i<Length(S) then
          if S[i+1]='''' then
          begin
            R:=R+S[i];
            inc(i);
          end
          else InString:=false
        else InString:=false
      else InString:=true
    else
    begin
      if (S[i]='#') and not InString then
      begin
        inc(i);
        j:=I;
        while (j<Length(S)) and (j<I+4) and (S[j] in Digit) do inc(j);
        if (J<>i) or (j>=Length(S)) or (S[j] in Digit) then
          R:=R+Char(StrToInt(Copy(S,i,j-i)) mod 256);
        i:=J-1;
      end
      else R:=R+S[i];
    end;
    inc(i);
  end;
  DelQuete:=R;
end;

function NameCase(S:string):string;
var I:integer;
procedure SkipBlank;
begin
  while (i<=Length(S)) and not (S[i] in WordChars) do inc(i);
end;
procedure SkipWord;
begin
  while (i<=Length(S)) and (S[i] in WordChars) do
  begin
    S[i]:=chLoCase(S[i]);
    inc(i);
  end;
end;
begin
  i:=1;
  while i<=Length(S) do
  begin
    SkipBlank;
    S[i]:=chUpCase(S[i]);
    inc(i);
    SkipWord;
  end;
  NameCase:=S;
end;


//procedure MyCopyright;
//const
//  UniLib='UniLib (c) 1995,2001 by Alexs';
//var aa:ShortString;
//begin
//  aa:=UniLib;
//end;

begin
  // MyCopyright;
end.
