{}
{Define this symbols for use drivers unit}
{.$Define UseDrivers}
{$IFDEF VER70}
{$Define UseDrivers}
{$ENDIF}

{Global options}

{$IFNDEF FPC}
  {$F-} { Force far calls }
  {$A+} { Word Align Data }
  {$B-} { Allow short circuit boolean evaluations }
  {$G+} { 286 Code optimization - if you're on an 8088 get a real computer }
  {$N+} { 80x87 code generation }
  {$E-} { Emulation is off }
  {$X+} { Extended syntax is ok }
{$IFNDEF VIRTUALPASCAL}
{$D+}
{$L+}
{$ENDIF}
{$P-}
{$Y+}
{$ENDIF}

{$R-} { Disable range checking }
{$S-} { Disable Stack Checking }
{$I-} { Disable IO Checking }
{$Q-} { Disable Overflow Checking }
{$V-} { Turn off strict VAR strings }
{$T-}

{$IFNDEF VER70}
{$H-}
{$ENDIF}

{$DEFINE OS_DOS}
{$DEFINE EAM} {Enable abstarct metods}

{$IFDEF WIN32}
  {$IFNDEF WINDOWS}
    {$DEFINE WINDOWS}
  {$ENDIF}
  {$UNDEF BIT_16}
  {$DEFINE BIT_32}
  {.$DEFINE OEM_FILE_API}
{$ENDIF}

{$IFDEF WINDOWS}
  {$UNDEF OS_DOS}
  {$DEFINE OS_WINDOWS}
{$ENDIF}

{$IFDEF Single}
 {$DEFINE COMPACT_EXE}
{$ENDIF}

{$IFNDEF VER70}
 {DEFINE FV20}
{$ELSE}
  {$UNDEF EAM} {Disable abstarct metods}
{$ENDIF}

{$IFDEF VER120}
  {$DEFINE DELPHI32}
  {$DEFINE PASCAL32}
{$ENDIF}
{$IFDEF VER10}
  {$DEFINE DELPHI32}
  {$DEFINE PASCAL32}
{$ENDIF}
{$IFDEF VER90}
  {$DEFINE DELPHI32}
  {$DEFINE PASCAL32}
{$ENDIF}
{$IFDEF VER80}
  {$DEFINE DELPHI16}
  {$DEFINE PASCAL16}
{$ENDIF}
{$IFDEF VER70}
  {$DEFINE PASCAL16}
{$ENDIF}
{$IFDEF FPC}
  {$DEFINE PASCAL32}
  {IFNDEF WIN32}
  {DEFINE DOS}
  {ENDIF}
{$ENDIF}
{$IFDEF VIRTUALPASCAL}
  {$DEFINE PASCAL32}
  {$UNDEF EAM} {Disable abstarct metods}
  {.$DEFINE TARGET_DOS}
{$ENDIF}


{---------------------------------------------------------------------------}
{  Initial assume BORLAND 16 BIT DOS COMPILER - Updated 27Aug98 LdB         }
{---------------------------------------------------------------------------}
{$DEFINE OS_DOS}
{$DEFINE PROC_Real}
{$DEFINE BIT_16}
{$DEFINE PPC_BP}
{$DEFINE ASM_BP}
{$DEFINE BP_VMTLink}

{---------------------------------------------------------------------------}
{  BORLAND 16 BIT DPMI changes protected mode - Updated 27Aug98 LdB         }
{---------------------------------------------------------------------------}
{$IFDEF DPMI}
  {$UNDEF PROC_Real}
  {$DEFINE PROC_Protected}
{$ENDIF}

{---------------------------------------------------------------------------}
{  FPC 32 BIT COMPILER changes ASM, 32 bits etc - Updated 27Aug98 LdB       }
{---------------------------------------------------------------------------}
{$IFDEF FPC}
  {$UNDEF PROC_Real}
  {$DEFINE PROC_Protected}
  {$UNDEF BIT_16}
  {$DEFINE BIT_32}
  {$UNDEF PPC_BP}
  {$DEFINE PPC_FPC}
  {$UNDEF ASM_BP}
  {$DEFINE ASM_FPC}
  {$UNDEF BP_VMTLink}
{$ENDIF}

{---------------------------------------------------------------------------}
{  FPC LINUX COMPILER changes operating system - Updated 27Aug98 LdB        }
{  Note: Other linux compilers would need to change other details           }
{---------------------------------------------------------------------------}
{$IFDEF LINUX}
  {$UNDEF OS_DOS}
  {$DEFINE OS_LINUX}
{$ENDIF}

{---------------------------------------------------------------------------}
{  32 BIT WINDOWS COMPILERS changes bit size - Updated 27Aug98 LdB          }
{---------------------------------------------------------------------------}
{$IFDEF WIN32}
  {$IFNDEF WINDOWS}
    {$DEFINE WINDOWS}
  {$ENDIF}
  {$UNDEF BIT_16}
  {$DEFINE BIT_32}
{$ENDIF}

{---------------------------------------------------------------------------}
{  WINDOWS COMPILERS change op system and proc mode - Updated 27Aug98 LdB   }
{---------------------------------------------------------------------------}
{$IFDEF WINDOWS}
  {$UNDEF OS_DOS}
  {$DEFINE OS_WINDOWS}
  {$UNDEF PROC_Real}
  {$DEFINE PROC_Protected}
{$ENDIF}

{---------------------------------------------------------------------------}
{  DELPHI1 COMPILER changes compiler type - Updated 27Aug98 LdB             }
{---------------------------------------------------------------------------}
{$IFDEF VER80}
  {$UNDEF PPC_BP}
  {$DEFINE PPC_DELPHI}
{$ENDIF}

{---------------------------------------------------------------------------}
{  DELPHI2 COMPILER changes compiler type - Updated 27Aug98 LdB             }
{---------------------------------------------------------------------------}
{$IFDEF VER90}
  {$UNDEF PPC_BP}
  {$DEFINE PPC_DELPHI}
  {$DEFINE PPC_DELPHI2}
{$ENDIF}

{---------------------------------------------------------------------------}
{  DELPHI3 COMPILER changes compiler type - Updated 27Aug98 LdB             }
{---------------------------------------------------------------------------}
{$IFDEF VER100}
  {$UNDEF PPC_BP}
  {$DEFINE PPC_DELPHI}
  {$DEFINE PPC_DELPHI3}
  {$UNDEF BP_VMTLink}
{$ENDIF}

{---------------------------------------------------------------------------}
{  DELPHI4 COMPILER changes compiler type - Updated 25Oct98 pfv             }
{---------------------------------------------------------------------------}
{$IFDEF VER120}
  {$UNDEF PPC_BP}
  {$DEFINE PPC_DELPHI}
  {$DEFINE PPC_DELPHI3}
  {$DEFINE PPC_DELPHI4}
  {$UNDEF BP_VMTLink}
{$ENDIF}

{---------------------------------------------------------------------------}
{  OS2 COMPILERS change compiler type and mode - Updated 27Aug98 LdB        }
{  Note: Assumes BPOS2 16BIT OS2 patch except for FPC which undefines this  }
{---------------------------------------------------------------------------}
{$IFDEF OS2}
  {$UNDEF OS_DOS}
  {$DEFINE OS_OS2}
  {$UNDEF PROC_Real}
  {$DEFINE PROC_Protected}
  {$UNDEF PPC_BP}
  {$DEFINE PPC_BPOS2}
  {$IFDEF FPC}
    {$UNDEF PPC_BPOS2}
  {$ENDIF}
{$ENDIF}

{---------------------------------------------------------------------------}
{  VIRTUAL PASCAL changes compiler type/32 bit - Updated 27Aug98 LdB        }
{  Note: VP2 can compile win 32 code so changes op system as needed         }
{---------------------------------------------------------------------------}
{$IFDEF VirtualPascal}
  {$UNDEF BIT_16}
  {$DEFINE BIT_32}
  {$IFDEF PPC_BPOS2}
    {$UNDEF PPC_BPOS2}
  {$ENDIF}
  {$DEFINE PPC_VIRTUAL}
  {$IFDEF WIN32}
    {$UNDEF PPC_BP}
    {$UNDEF OS_OS2}
    {$DEFINE OS_WINDOWS}
  {$ENDIF}
{$ENDIF}

{---------------------------------------------------------------------------}
{  SPEED COMPILER changes compiler type/32 bit  - Updated 27Aug98 LdB       }
{---------------------------------------------------------------------------}
{$IFDEF Speed}
  {$UNDEF BIT_16}
  {$DEFINE BIT_32}
  {$UNDEF PPC_BPOS2}
  {$DEFINE PPC_SPEED}
{$ENDIF}

{---------------------------------------------------------------------------}
{  FPC AMIGA COMPILER changes op system and CPU type - Updated 27Aug98 LdB  }
{---------------------------------------------------------------------------}
{$IFDEF AMIGA}
  {$UNDEF OS_DOS}
  {$DEFINE OS_AMIGA}
  {$IFDEF CPU86}
    {$UNDEF CPU86}
  {$ENDIF}
  {$IFNDEF CPU68}
    {$DEFINE CPU68}
  {$ENDIF}
{$ENDIF}

{---------------------------------------------------------------------------}
{  FPC ATARI COMPILER changes op system and CPU type - Updated 27Aug98 LdB  }
{---------------------------------------------------------------------------}
{$IFDEF ATARI}
  {$UNDEF OS_DOS}
  {$DEFINE OS_ATARI}
  {$IFDEF CPU86}
    {$UNDEF CPU86}
  {$ENDIF}
  {$IFNDEF CPU68}
    {$DEFINE CPU68}
  {$ENDIF}
{$ENDIF}

{---------------------------------------------------------------------------}
{  FPC MAC COMPILER changes op system and CPU type - Updated 27Aug98 LdB    }
{---------------------------------------------------------------------------}
{$IFDEF MACOS}
  {$UNDEF OS_DOS}
  {$DEFINE OS_MAC}
  {$IFDEF CPU86}
    {$UNDEF CPU86}
  {$ENDIF}
  {$IFNDEF CPU68}
    {$DEFINE CPU68}
  {$ENDIF}
{$ENDIF}





