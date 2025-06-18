{************************************************}
{                                                }
{   Extended math functions                      }
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

unit Ext_Math;

interface

uses Ext_Type, Dos, SysUtils, Ext_Sys;

function Min(A, B: Longint):Longint;
function Max(I, J: Longint):Longint;

Function SwapLong(P:LongInt):Longint;

function CountParam(const s:string):integer;

function SystemTimeToStr(D:DateTime):string;
function SystemDateToStr(D:DateTime):string;
procedure StrToSystemDate(S:String; var D:DateTime);
procedure StrToSystemTime(S:String; var D:DateTime);

function IntToStr( Value:LongInt):String;
function StrToInt(const S:String):Longint;
function StrToIntDef(const S:String; Default:Longint):Longint;
function FloatToStr( R:Double):string;
function CurrencyToStr( R:Currency):string;
function StrToFloat( S:String):Double;
function IntToHex(Value:LongInt; Digits:byte):String;
function BooleanToStr(f:boolean):string;
function StrToBoolean(Value:string):Boolean;
function CompareDate(D1,D2:DateTime):integer;
function CompareTime(D1,D2:DateTime):integer;

function Pov(X,Y:Extended):Extended;
function DegToRad(Degrees: Extended): Extended;
function RadToDeg(Radians: Extended): Extended;

function ArcTan2(Y, X: Extended): Extended;
function Tan(X: Extended): Extended;
function CoTan(X: Extended): Extended;
function ArcCos(X: Extended): Extended;
function ArcSin(X: Extended): Extended;
function Log10(X: Extended): Extended;
function Log2(X: Extended): Extended;
function LogN(Base, X: Extended): Extended;
function Fact(I: Integer): Double;

implementation
uses Ext_Str, Objects;

function CountParam(const s:string):integer;
var
  j,i:integer;
begin
  j:=0;
  i:=0;
  while i<length(s) do
  begin
    inc(i);
    if (s[i]='%') and (s[i+1]<>'%') then
    begin
      j:=j+1;
      inc(i);
    end;
  end;
  CountParam:=j;
end;

function IntToStr( Value:LongInt):String;
var
  s:String;
begin
  Str( Value, S);
  IntToStr:=Trim(s);
end;

function StrToInt(const S:String):Longint;
var  {$IFNDEF VIRTUALPASCAL}
     I,Code: Integer;
     {$ELSE}
     i,Code:longint;
     {$ENDIF}
begin
  Val( s, I, Code);
  if code <> 0 then StrToInt:=0
  else  StrToInt:=I;
end;

function StrToIntDef(const S:String; Default:Longint):Longint;
var  {$IFNDEF VIRTUALPASCAL}
     I,Code: Integer;
     {$ELSE}
     i,Code:longint;
     {$ENDIF}
begin
  Val( s, I, Code);
  if code <> 0 then StrToIntDef:=Default
  else StrToIntDef:=I;
end;


function FloatToStr( R:Double):string;
var
  s:string;
  I: Integer;
begin
  Str( R:14:6,S);
  i:=Pos('.',S);
  if i<>0 then S[i]:=DecimalSeparator;
  I := Length(S);
  while (((S[I] <= ' ') or (S[i]='0')) and
           (s[i-1]<>DecimalSeparator)) and (i>1) do Dec(I);
  FloatToStr := TrimLeft(Copy(S, 1, I));
end;

function CurrencyToStr( R:Currency):string;
var
  s,s1:string[22];
  I,j: Integer;
begin
  {$IFNDEF FPC}
  Str( R:21:CurrencyDecimals,S);
  {$ELSE}
  Str( R,S);
  {$ENDIF}
  i:=20-CurrencyDecimals;
  j:=0;
  S1:=DecimalSeparator+copy(S,21-CurrencyDecimals+1,255);
{  S:=TrimLeft(S);}
  while (i>0) and (s[i]<>' ') do
  begin
    S1:=S[i]+S1;
    inc(j);
    if j=3 then
    begin
      j:=0;
      S1:=ThousandSeparator+S1;
    end;
    dec(i);
  end;
  if (S1<>'') and (S1[1]=ThousandSeparator) then Delete(S1,1,1);
  CurrencyToStr:=S1+CurrencyString;
end;

function StrToFloat( S:String):Double;
var  {$IFNDEF VIRTUALPASCAL}
     I,Code: Integer;
     {$ELSE}
     i,Code:longint;
     {$ENDIF}
    R:Double;
begin
  for i:=1 to Length(S) do if S[i]=DecimalSeparator then S[i]:='.';
  Val( S, R, Code);
  if code <> 0 then StrToFloat:=0
  else StrToFloat:=R;
end;

function IntToHex(Value:LongInt; Digits:byte):String;
var S:string;
    L:byte;
begin
  if Value=0 then S:='0'
  else
  begin
    S:='';
    while Value>0 do
    begin
      L:=Value and $0F;
      Value:=Value shr 4;
      if L>9 then S:=Char(Byte('A')-10+L)+S
      else S:=Char(byte('0')+L)+S;
    end;
  end;
  if Length(S)<Digits then S:=DupChar('0',Digits-Length(S))+S;
  IntToHex:=S;
end;

function SwapLong(P:LongInt):Longint;
begin
  SwapLong:=
  Swap(LongRec(P).Lo) shl 16 + Swap(LongRec(P).Hi);
end;


function SystemTimeToStr(D:DateTime):string;
var
  S1,S2,S3:string[2];
begin
  Str(D.Hour:2,S1);
  Str(D.Min:2, S2);
  if D.Min<10 then s2[1]:='0';
  Str(D.Sec:2, S3);
  if D.Sec<10 then S3[1]:='0';
  SystemTimeToStr:=S1+':'+S2+':'+S3;
end;

function SystemDateToStr(D:DateTime):string;
begin
  SystemDateToStr:=IntToStr(D.Year);
end;

procedure StrToSystemDate(S:String; var D:DateTime);
var
  i:integer;
begin
  FillChar(D,SizeOf(DateTime),0);
  i:=Pos(DateSeparator,S);
  D.Day:=StrToInt(Copy(S,1,i-1));
  Delete(S,1,i);
  i:=Pos(DateSeparator,S);
  D.Month:=StrToInt(Copy(S,1,i-1));
  Delete(S,1,i);
  D.Year:=StrToInt(S);
  if ExpandDate and (D.Year<100) then D.Year:=D.Year+1900;
end;

procedure StrToSystemTime(S:String; var D:DateTime);
var
  i:integer;
begin
  FillChar(D,SizeOf(DateTime),0);
  i:=Pos(TimeSeparator,S);
  D.Hour:=StrToInt(Copy(S,1,i-1));
  Delete(S,1,i);
  i:=Pos(TimeSeparator,S);
  D.Min:=StrToInt(Copy(S,1,i-1));
  Delete(S,1,i);
  D.Sec:=StrToInt(S);
end;


function BooleanToStr(f:boolean):string;
begin
  BooleanToStr:=BooleanText[f];
end;

function StrToBoolean(Value:string):Boolean;
begin
  StrToBoolean:=(Value=BooleanText[true]);
end;

function Pov(X,Y:Extended):Extended;
begin
  Pov:=Exp(y*ln(x));
end;

function Min(A,B:Longint):Longint;
begin
  if A>B then Min:=B else Min:=A;
end;

function Max(I, J: Longint): Longint;
begin
  if I > J then Max := I else Max := J;
end;

function DegToRad(Degrees: Extended): Extended;  { Radians := Degrees * PI / 180 }
begin
  DegToRad := Degrees * (PI / 180);
end;

function RadToDeg(Radians: Extended): Extended;  { Degrees := Radians * 180 / PI }
begin
  RadToDeg := Radians * (180 / PI);
end;

function ArcCos(X: Extended): Extended;
begin
  ArcCos := ArcTan2(Sqrt(1 - X*X), X);
end;

function ArcSin(X: Extended): Extended;
begin
  ArcSin := ArcTan2(X, Sqrt(1 - X*X))
end;

function ArcTan2(Y, X: Extended): Extended;
begin
  x:=0;
  y:=x;
  ArcTan2:=y;
end;

function Tan(X: Extended): Extended;
begin
  Tan:=X;
end;

function CoTan(X: Extended): Extended;
begin
 CoTan := Cos(X) / Sin(X);
end;


function Log10(X: Extended): Extended;
begin
  Log10 := X;
{ Log10 := Lg(X) * Log(2);}
end;

function Log2(X: Extended): Extended;
begin
  Log2:=X;
end;

function LogN(Base, X: Extended): Extended;
begin
 LogN := {Log2(X) / Log2(N)}Base*X;
end;

function Fact(I: Integer): Double;
begin
  if I > 0 then Fact:=I*Fact(I-1)
  else Fact:=1;
end;


{if D1>D2 then CompareDate:=1 }
{if D1=D2 then CompareDate:=0 }
{if D1<D2 then CompareDate:=-1}
function CompareDate(D1,D2:DateTime):integer;
begin
  if D1.Year>D2.Year then CompareDate:=1
  else if D1.Year<D2.Year then CompareDate:=-1
  else if D1.Month>D2.Month then CompareDate:=1
  else if D1.Month<D2.Month then CompareDate:=-1
  else if D1.Day>D2.Day then CompareDate:=1
  else if D1.Day<D2.Day then CompareDate:=-1
  else CompareDate:=0;
end;

{if D1>D2 then CompareTime:=1 }
{if D1=D2 then CompareTime:=0 }
{if D1<D2 then CompareTime:=-1}
function CompareTime(D1,D2:DateTime):integer;
begin
  if D1.Hour>D2.Hour then CompareTime:=1
  else if D1.Hour<D2.Hour then CompareTime:=-1
  else if D1.Min>D2.Min then CompareTime:=1
  else if D1.Min<D2.Min then CompareTime:=-1
  else if D1.Sec>D2.Sec then CompareTime:=1
  else if D1.Sec<D2.Sec then CompareTime:=-1
  else CompareTime:=0;
end;

end.