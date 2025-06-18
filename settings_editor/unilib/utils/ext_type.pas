{*******************************************************}
{                                                       }
{       Turbo Pascal Version 7.0                        }
{       Extended types                                  }
{                                                       }
{       Copyright (c) 1995-98 by Alexs                  }
{                                                       }
{*******************************************************}

{$I Define.inc}

unit Ext_Type;

interface

uses Objects, Dos;

type
  TNumericType = (itShortint, itInteger, itLongint, itByte, itWord,
                  itChar, itDate, itTime, itDouble, itReal, itInt16);
type
{$IFDEF PASCAL16}
  Int16         = Integer;
  Int32         = Longint;
  Cardinal      = Longint;  { :-( }
  DWord         = Cardinal;
  ShortString   = string;
{$ENDIF}
{$IFDEF PASCAL32}
  Int32         = integer;
  Int16         = ShortInt;
{$ENDIF}
type
{$IFDEF VIRTUALPASCAL}
   TrueWord = SmallWord;
{$ELSE}
   TrueWord = word;
{$ENDIF}

type
  TDateTime     = Double;
{$IFDEF VER70}
  Currency      = Double;
{$ENDIF}
  PCurrency     = ^Currency;
  PWord = ^Word;
  PByte = ^Byte;
  PInteger = ^Integer;
  PInt16   = ^Int16;
  PDouble = ^Double;
  PLongInt = ^LongInt;
  PShortint = ^Shortint;
  PBoolean = ^Boolean;
  PDateTime = ^TDateTime;
  PByteSet = ^TByteSet;
  PExtended = ^Extended;
  PReal     = ^Real;
  TByteSet = set of byte;
  TLongSet = set of 0..31;
  TDosFName = string[12];
  PIntegerArray = ^TIntegerArray;
  TIntegerArray = array [0..65520 div SizeOf(Integer)] of Integer;
  PRealArray = ^TRealArray;
  TRealArray = array [0..65520 div SizeOf(Real)] of Real;
  PSingleArray = ^TSingleArray;
  TSingleArray = array [0..65520 div SizeOf(Single)] of Single;
  PDoubleArray = ^TDoubleArray;
  TDoubleArray = array [0..65520 div SizeOf(Double)] of Double;
  PExtendedArray = ^TExtendedArray;
  TExtendedArray = array [0..65520 div SizeOf(Extended)] of Extended;
  PCompArray = ^TCompArray;
  TCompArray= array [0..65520 div SizeOf(Comp)] of Comp;
  PCharArray = ^TCharArray;
  TCharArray = array [0..65520 div SizeOf(Char)] of Char;
  PLongArray = ^TLongArray;
  TLongArray = array [0..65520 div SizeOf(Longint)] of Longint;
{IFDEF PASCAL16}
  WideChar      = word;
  PWideChar     = ^WideChar;
  PWideCharArray = ^TWideCharArray;
  TWideCharArray = array [0..65520 div SizeOf(WideChar)] of WideChar;
{ENDIF}
type
  TAlign = (alNone, alTop, alBottom, alLeft, alRight, alClient, alCenter);

type
  TNotifyEvent = procedure(Sender:PObject);
  TProgresEvent = procedure(All,Pos:Longint; Info:PString);

{$IFNDEF OWL}
type
  PPoint = ^TPoint;
{$ENDIF}

type
  TListBoxRec = record
    List:Pointer;
    Selection:word;
  end;

type
{  TEmptyArray = array  of char;}
  PMemoRec = ^TMemoRec;
  TMemoRec = record
    Length:word;
    Text:TCharArray;
  end;

type
  TLargePoint = record
    X,Y:Longint;
  end;

type
  TPersentRec = record
    MaxValue: Longint;
    CurValue: Longint;
  end;

const
{ Seconds and milliseconds per day }
  SecsPerDay = 24 * 60 * 60;
  MSecsPerDay = SecsPerDay * 1000; {86400000}

{ Days between 1/1/0001 and 12/31/1899 }
  DateDelta = 693594{+366};

implementation
end.
