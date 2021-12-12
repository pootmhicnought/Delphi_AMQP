{$I AMQP.Options.inc}

unit AMQP.SyncObjs;

interface

uses
  Classes,
  SysUtils,
  {$IfDef WINDOWS}
  Windows,
  {$Else}
  {$ifdef UNIX}
  BaseUnix,
  ctypes,
  {$EndIf}
  {$EndIf}
  syncobjs
  ;

type

    { TConditionVariableCS }

    {$IFDEF WINDOWS}
    TRTLConditionVariable = record
      Ptr: Pointer;
    end;
    {$ELSE}
    {$IfDef UNIX}
     TRTLConditionVariable = TRTLCriticalSection;
     PRTLConditionVariable = ^TRTLConditionVariable;
    {$EndIf}
    {$ENDIF}

    TConditionVariableCS = class(TSynchroObject)
    private
      FConditionVariable: TRTLConditionVariable;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Acquire; override;
      procedure Release; override;
      procedure ReleaseAll;
      function WaitFor(CriticalSection: TCriticalSection; TimeOut: LongWord = INFINITE): TWaitResult;
      function WaitForRTL(var CriticalSection: TRTLCriticalSection; TimeOut: LongWord = INFINITE): TWaitResult;
    end;

implementation



type
    TInitializeConditionVariableProc = procedure (out ConditionVariable: TRTLConditionVariable); stdcall;
    TSleepConditionVariableCSProc = function (var ConditionVariable: TRTLConditionVariable; var CriticalSection: TRTLCriticalSection;
       dwMilliseconds: {$IfDef Unix}ttimespec{$else}DWORD{$EndIf}): {$IfDef WINDOWS}BOOL{$Else}Boolean{$EndIf}; stdcall;
    TWakeConditionVariableProc = procedure (var ConditionVariable: TRTLConditionVariable); stdcall;
    TWakeAllConditionVariableProc = procedure (var ConditionVariable: TRTLConditionVariable); stdcall;

    { TCriticalSectionHack }

    TCriticalSectionHack = class(TCriticalSection)
    private
      CriticalSection: TRTLCriticalSection;
    public
    end;

var
  InitializeConditionVariableProc: TInitializeConditionVariableProc;
  SleepConditionVariableCSProc: TSleepConditionVariableCSProc;
  WakeConditionVariableProc: TWakeConditionVariableProc;
  WakeAllConditionVariableProc: TWakeAllConditionVariableProc;


  {$If Defined(FPC) and Defined(Unix)}
  function pthread_cond_init(__cond:PRTLConditionVariable; __cond_attr: pointer):longint;cdecl;external;
  function pthread_cond_destroy(__cond:PRTLConditionVariable):longint;cdecl;external;
  function pthread_cond_signal(__cond:PRTLConditionVariable):longint;cdecl;external;
  function pthread_cond_broadcast(__cond:PRTLConditionVariable):longint;cdecl;external;
  function pthread_cond_wait(__cond:PRTLConditionVariable; __mutex:PRTLCriticalSection):longint;cdecl;external;
  function pthread_cond_timedwait(__cond:PRTLConditionVariable; __mutex:PRTLCriticalSection; __abstime:ptimespec):longint;cdecl;external;


  procedure InternalInitConditionVariable(out ConditionVariable: TRTLConditionVariable); stdcall;
  begin
   pthread_cond_init(@ConditionVariable, nil);
  end;

  procedure InternalConditionVariableSignal(var ConditionVariable: TRTLConditionVariable); stdcall;
  begin
   pthread_cond_signal(@ConditionVariable);
  end;

  function InternalConditionVariableWait(var ConditionVariable: TRTLConditionVariable; var CriticalSection: TRTLCriticalSection; dwMilliseconds: ttimespec): Boolean; stdcall;
  begin
   Result := pthread_cond_timedwait(@ConditionVariable, @CriticalSection, @dwMilliseconds) = 0;
  end;

  procedure InternalConditionVariableBroadcast(var ConditionVariable: TRTLConditionVariable); stdcall;
  begin
   pthread_cond_broadcast(@ConditionVariable);
  end;

  {$EndIf}


{ TCriticalSectionHack }

constructor TConditionVariableCS.Create;
begin
{$IfDef UNIX}
   InternalInitConditionVariable(FConditionVariable);
{$EndIf}
end;

procedure TConditionVariableCS.Acquire;
begin
  raise ESyncObjectException.Create('Can not call acquire on condition variable.');
end;

destructor TConditionVariableCS.Destroy;
begin
 {$IfDef UNIX}
  pthread_cond_destroy(@FConditionVariable);
 {$EndIf}
  inherited Destroy;
end;

procedure TConditionVariableCS.Release;
begin
  WakeConditionVariableProc(FConditionVariable);
end;

procedure TConditionVariableCS.ReleaseAll;
begin
  WakeAllConditionVariableProc(FConditionVariable);
end;

function TConditionVariableCS.WaitFor(CriticalSection: TCriticalSection;
  TimeOut: LongWord): TWaitResult;
begin
  if CriticalSection = nil then
    raise EArgumentException.Create('Critical section cannot be nil');
  Result := WaitForRTL(TCriticalSectionHack(CriticalSection).CriticalSection, TimeOut);
end;

function TConditionVariableCS.WaitForRTL(var CriticalSection: TRTLCriticalSection;
  TimeOut: LongWord): TWaitResult;
var
  ltimeOut: {$IfDef UNIX}Ttimespec{$Else}LongWord{$EndIf};
begin
{$IfDef UNIX}
 ltimeOut.tv_sec:=TimeOut div 1000;
 ltimeOut.tv_nsec:=(TimeOut mod 1000) * 1000000;
{$Else}
 ltimeOut := TimeOut;
{$EndIf}
 if SleepConditionVariableCSProc(FConditionVariable, CriticalSection, LTimeOut) then
    Result := wrSignaled
 else
   case GetLastOSError of
     {$If Defined(WINDOWS)}ERROR_TIMEOUT{$ElseIf defined(UNIX)}ESysETIMEDOUT{$EndIf}: Result := wrTimeout;
     {$If Defined(WINDOWS)}WAIT_ABANDONED: Result := wrAbandoned;{$EndIf}
   end;
end;



procedure InitConditionVariableProc;
var
  Module: HMODULE;
begin
 {$IfDef WINDOWS}
   Module:= GetModuleHandle('kernel32.dll');
   InitializeConditionVariableProc:= GetProcAddress(Module, 'InitializeConditionVariable');
   if @InitializeConditionVariableProc <> nil then
     begin
       WakeConditionVariableProc:=GetProcAddress(Module, 'WakeConditionVariable');
       WakeAllConditionVariableProc:=GetProcAddress(Module, 'WakeAllConditionVariable');
       SleepConditionVariableCSProc:=GetProcAddress(module, 'SleepConditionVariableCS');
     end;
 {$Else}
 {$IfDef UNIX}
   InitializeConditionVariableProc := @InternalInitConditionVariable;
   WakeConditionVariableProc:= @InternalConditionVariableSignal;
   WakeAllConditionVariableProc := @InternalConditionVariableBroadcast;
   SleepConditionVariableCSProc := @InternalConditionVariableWait;
 {$EndIf}
 {$EndIf}
end;

initialization
  InitConditionVariableProc;

end.

