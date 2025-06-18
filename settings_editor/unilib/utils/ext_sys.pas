{************************************************}
{                                                }
{   Extended system functions                    }
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

unit EXT_SYS;

interface

uses Ext_Type;

const
  LongMonthNames: array [1..12] of string[20] =
  ('Январь','Февраль','Март',    'Апрель', 'Май',   'Июнь',
   'Июль',  'Август', 'Сентябрь','Октябрь','Ноябрь','Декабрь');
const
  ShortMonthNames: array[1..12] of string[20] =
  ('января','февраля','марта',    'апреля', 'мая',   'июня',
   'июля',  'августа', 'сентября','октября','ноября','декабря');

const
  ShortDayNames: array [1..7] of string[6] =
  ('Пн','Вт','Ср','Чт','Пт','Сб','Вс');
const
  LongDayNames : array [1..7] of string[22] =
  ('Понедельник','Вторник','Среда','Четверг',
   'Пятница','Субота','Воскресенье');
const
  ShortNameDayOfW{:string[20]} = 'Пн Вт Ср Чт Пт Сб Вс';
const
   DaysInMonth: array[1..12] of Byte =
     (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

const
  DateSeparator:char = '/';
  TimeSeparator:char = ':';
  ExpandDate:boolean = true;
  CurrencyString:string[5] = 'р.';
  ThousandSeparator:Char = ' ';
  DecimalSeparator:char = '.';
  CurrencyDecimals:byte = 2;
  ShortTimeFormat:string[20] = 'hh:mm';
  LongTimeFormat :string[20] = 'hh:mm:ss';
  ShortDateFormat:string[20] = 'd/mm/yy';
  LongDateFormat :string[20] = 'dd mm yyyy';
  TwoDigitYearCenturyWindow: Word = 30;

const
  BooleanText:array [boolean] of string[10] = ('false','true');

implementation
end.