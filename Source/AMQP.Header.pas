{$I AMQP.Options.inc}
unit AMQP.Header;

interface

Uses
  Classes, AMQP.Payload, AMQP.IMessageProperties;

Type
  TAMQPHeader = Class(TAMQPPayload)
  strict private
    FClassID      : UInt16;
    FWeight       : UInt16;
    FBodySize     : UInt64;
    FPropertyList : IAMQPMessageProperties;
  Public
    Property ClassID      : UInt16                 read FClassID;
    Property Weight       : UInt16                 read FWeight;
    Property BodySize     : UInt64                 read FBodySize;
    Property PropertyList : IAMQPMessageProperties read FPropertyList;
    Procedure Assign( AHeader: TAMQPHeader );
    Procedure LoadFromStream( AStream: TStream ); Override;
    Constructor Create; Override;
    Destructor Destroy; Override;
  End;

const
{$IfDef FPC}
   sCompilDef = 'FPC' + {$I %FPCVERSION%};
  {$If Defined(CPUARM)}
     sArchitectureDef = 'ARM';
  {$ElseIf defined(CPUAARCH64)}
     sArchitectureDef = 'AARCH64';
  {$ElseIf defined(CPUX86_64)}
     sArchitectureDef = 'x86_64';
  {$ElseIf defined(CPU386)}
     sArchitectureDef = 'i386';
  {$Else}
     sArchitectureDef = 'Unknown';
  {$endIf}

  {$If Defined(UNIX)}
    {$If Defined(LINUX)}
       sTargetOsDef = 'Linux';
    {$ElseIf defined(BSD)}
       sTargetOsDef = 'BSD';
    {$EndIf}
  {$ElseIf Defined(WINDOWS)}
    {$If Defined(MSWINDOWS)}
       {$If Defined(WIN32)}
         sTargetOsDef = 'Windows';
       {$ElseIf Defined(WIN64)}
         sTargetOsDef = 'Windows';
       {$Else}
         sTargetOsDef = 'Unknown';
       {$EndIf}
    {$EndIf}
  {$EndIf}
{$Else}
       sCompilDef = 'Delphi';
       sTargetOsDef = 'Windows';
       {$IfDef WIN64}
       sArchitectureDef = 'x86_64';
       {$Else}
       sArchitectureDef = 'i386';
       {$EndIf}
{$EndIf}
       sApplicationId = sArchitectureDef+'-'+sTargetOsDef;


implementation

Uses
  AMQP.MessageProperties, AMQP.StreamHelper;

{ TAMQPHeader }

procedure TAMQPHeader.Assign(AHeader: TAMQPHeader);
begin
  FClassID       := AHeader.ClassID;
  FWeight        := AHeader.Weight;
  FBodySize      := AHeader.BodySize;
  FPropertyList.Assign( AHeader.PropertyList );
end;

constructor TAMQPHeader.Create;
begin
  inherited;
  Name           := 'Header';
  FClassID       := 0;
  FWeight        := 0;
  FBodySize      := 0;
  FPropertyList  := TAMQPMessageProperties.Create( sApplicationId );
end;

destructor TAMQPHeader.Destroy;
begin
  FPropertyList := nil;
  inherited;
end;

procedure TAMQPHeader.LoadFromStream(AStream: TStream);
begin
  AStream.ReadUInt16( FClassID );
  AStream.ReadUInt16( FWeight );
  AStream.ReadUInt64( FBodySize );
  FPropertyList.LoadFromStream( AStream );
end;

end.
