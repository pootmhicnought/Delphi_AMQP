{$IfDef FPC}
        {$Mode DELPHI}
        {$SmartLink On}
        {$If Defined(CPUAARCH64) or Defined(CPUARM)}
                {$DEFINE ARM}
    {$EndIf}
{$EndIf}
