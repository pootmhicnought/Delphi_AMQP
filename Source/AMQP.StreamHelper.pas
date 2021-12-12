{$I AMQP.Options.inc}

unit AMQP.StreamHelper;

interface

Uses
  SysUtils, Classes, IdGlobal;

Type

  { TStreamHelper }

  TStreamHelper = Class helper for TStream
  Private
    function GetAsString(AEncoding: TEncoding): String;
    procedure SetAsString(AEncoding: TEncoding; const Value: String);
  Public
    Procedure WriteMSB( var Buffer; Count: Cardinal );
    Procedure WriteOctet( B: Byte );
    Procedure WriteUInt8( I: UInt8 );
    Procedure WriteUInt16( I: UInt16 );
    Procedure WriteUInt32( I: UInt32 );
    Procedure WriteUInt64( I: UInt64 );
    Procedure WriteInt8( I: Int8 );
    Procedure WriteInt16( I: Int16 );
    Procedure WriteInt32( I: Int32 );
    Procedure WriteInt64( I: Int64 );
    Procedure WriteFloat( F: Single);
    procedure WriteDouble( D: Double);
    Procedure WriteShortStr( S: String );
    Procedure ReadMSB( var Buffer; Count: Integer );
    Procedure ReadOctet( var B: Byte );
    Procedure ReadUInt8( var I: UInt8 );
    Procedure ReadUInt16( var I: UInt16 );
    Procedure ReadUInt32( var I: UInt32 );
    Procedure ReadUInt64( var I: UInt64 );
    Procedure ReadInt8( var I: Int8 );
    Procedure ReadInt16( var I: Int16 );
    Procedure ReadInt32( var I: Int32 );
    Procedure ReadInt64( var I: Int64 );
    Procedure ReadShortStr( var S: String );
    Procedure ReadLongStr( var S: String );
    Procedure ReadFloat( var F: Single);
    Procedure ReadDouble( var D: Double);
    Function AsBytes: TIdBytes;
    Property AsString[ Encoding: TEncoding ]: String read GetAsString write SetAsString;

    {$IfDef FPC}
    function Skip(Amount: Integer): Integer;

    function WriteData(const Buffer: TBytes; Count: Longint): Longint; overload;
    function WriteData(const Buffer: Pointer; Count: Longint): Longint; overload;
    function WriteData(const Buffer: Boolean): Longint; overload;
    function WriteData(const Buffer: Boolean; Count: Longint): Longint; overload;
    function WriteData(const Buffer: Char): Longint; overload;
    function WriteData(const Buffer: Char; Count: Longint): Longint; overload;
    function WriteData(const Buffer: Int8): Longint; overload;
    function WriteData(const Buffer: Int8; Count: Longint): Longint; overload;
    function WriteData(const Buffer: UInt8): Longint; overload;
    function WriteData(const Buffer: UInt8; Count: Longint): Longint; overload;
    function WriteData(const Buffer: Int16): Longint; overload;
    function WriteData(const Buffer: Int16; Count: Longint): Longint; overload;
    function WriteData(const Buffer: UInt16): Longint; overload;
    function WriteData(const Buffer: UInt16; Count: Longint): Longint; overload;
    function WriteData(const Buffer: Int32): Longint; overload;
    function WriteData(const Buffer: Int32; Count: Longint): Longint; overload;
    function WriteData(const Buffer: UInt32): Longint; overload;
    function WriteData(const Buffer: UInt32; Count: Longint): Longint; overload;
    function WriteData(const Buffer: Int64): Longint; overload;
    function WriteData(const Buffer: Int64; Count: Longint): Longint; overload;
    function WriteData(const Buffer: UInt64): Longint; overload;
    function WriteData(const Buffer: UInt64; Count: Longint): Longint; overload;
    function WriteData(const Buffer: Single): Longint; overload;
    function WriteData(const Buffer: Single; Count: Longint): Longint; overload;
    function WriteData(const Buffer: Double): Longint; overload;
    function WriteData(const Buffer: Double; Count: Longint): Longint; overload;
    {$IfNDef ARM}
    {$IfNDef WIN64}
    function WriteData(const Buffer: Extended): Longint; overload;
    function WriteData(const Buffer: Extended; Count: Longint): Longint; overload;
    function WriteData(const Buffer: TExtended80Rec): Longint; overload;
    function WriteData(const Buffer: TExtended80Rec; Count: Longint): Longint; overload;
    {$EndIf}
    {$EndIf}

    function Write(const Buffer: TBytes; Offset, Count: Longint): Longint; overload;
    {$EndIf}
  End;

implementation

{ TStreamHelper }

function TStreamHelper.AsBytes: TIdBytes;
var
  OldPosition: Integer;
begin
  OldPosition := Position;
  Position := 0;
  SetLength( Result, Size );
  ReadBuffer( Result[0], Size );
  Position := OldPosition;
end;

function TStreamHelper.GetAsString(AEncoding: TEncoding): String;
var
  StringStream: TStringStream;
begin
  StringStream := TStringStream.Create( '', AEncoding );
  Try
    StringStream.CopyFrom( Self, 0 );
    Result := StringStream.DataString;
  Finally
    StringStream.Free;
  End;
end;

procedure TStreamHelper.ReadDouble(var D: Double);
begin
 ReadMSB(D, SizeOf(D));
end;

procedure TStreamHelper.ReadFloat(var F: Single);
begin
 ReadMSB(F, SizeOf(F));
end;

procedure TStreamHelper.ReadInt16(var I: Int16);
begin
  ReadMSB( I, 2 );
end;

procedure TStreamHelper.ReadInt32(var I: Int32);
begin
  ReadMSB( I, 4 );
end;

procedure TStreamHelper.ReadInt64(var I: Int64);
begin
  ReadMSB( I, 8 );
end;

procedure TStreamHelper.ReadInt8(var I: Int8);
begin
  Read( I, 1 );
end;

procedure TStreamHelper.ReadLongStr(var S: String);
var
  Str: AnsiString;
  Len: UInt32;
begin
  ReadUInt32( Len );
  SetLength( Str, Len );
  if Len > 0 then
    Read( Str[1], Len );
  S := String( Str );
end;

procedure TStreamHelper.ReadMSB(var Buffer; Count: Integer);
var
  Cnt: Integer;
begin
  For Cnt := 0 to Count-1 do
    Read( PByteArray(@Buffer)[Count - Cnt - 1], 1 );
end;

procedure TStreamHelper.ReadOctet(var B: Byte);
begin
  Read( B, 1 );
end;

procedure TStreamHelper.ReadShortStr(var S: String);
var
  Str: AnsiString;
  Len: Byte;
begin
  ReadUInt8( Len );
  SetLength( Str, Len );
  if Len > 0 then
    Read( Str[1], Len );
  S := String( Str );
end;

procedure TStreamHelper.ReadUInt16(var I: UInt16);
begin
  ReadMSB( I, 2 );
end;

procedure TStreamHelper.ReadUInt32(var I: UInt32);
begin
  ReadMSB( I, 4 );
end;

procedure TStreamHelper.ReadUInt64(var I: UInt64);
begin
  ReadMSB( I, 8 );
end;

procedure TStreamHelper.ReadUInt8(var I: UInt8);
begin
  Read( I, 1 );
end;

procedure TStreamHelper.SetAsString(AEncoding: TEncoding; const Value: String);
var
  StringStream: TStringStream;
begin
  StringStream := TStringStream.Create( Value, AEncoding );
  Try
    Self.CopyFrom( StringStream, 0 );
  Finally
    StringStream.Free;
  End;
end;

{$ifdef fpc}
function TStreamHelper.Skip(Amount: Integer): Integer;
var
  P: Integer;
begin
  P := Position;
  Result := Seek(Amount, soCurrent) - P;
end;
{$endif}

{$ifdef fpc}
function TStreamHelper.Write(const Buffer: TBytes; Offset, Count: Longint
  ): Longint;
begin
    Result := Write(Buffer[Offset], Count);
end;
{$endif}

{$ifdef fpc}
function TStreamHelper.WriteData(const Buffer: Boolean): Longint;
begin
  Result := Write(Buffer, SizeOf(Buffer));
end;
{$endif}

{$ifdef fpc}
function TStreamHelper.WriteData(const Buffer: Boolean; Count: Longint
  ): Longint;
const
  BufSize = SizeOf(Buffer);
begin
  if Count > BufSize then
    Result := Write(Buffer, BufSize) + Skip(Count - BufSize)
  else
    Result := Write(Buffer, Count)
end;
{$endif}

{$ifdef fpc}
function TStreamHelper.WriteData(const Buffer: Char): Longint;
begin
  Result := Write(Buffer, SizeOf(Buffer));
end;
{$endif}

{$ifdef fpc}
function TStreamHelper.WriteData(const Buffer: Char; Count: Longint): Longint;
const
  BufSize = SizeOf(Buffer);
begin
  if Count > BufSize then
    Result := Write(Buffer, BufSize) + Skip(Count - BufSize)
  else
    Result := Write(Buffer, Count)
end;
{$endif}

{$ifdef fpc}
function TStreamHelper.WriteData(const Buffer: Double): Longint;
begin
  Result := Write(Buffer, SizeOf(Buffer));
end;
{$endif}

{$ifdef fpc}
function TStreamHelper.WriteData(const Buffer: Double; Count: Longint): Longint;
const
  BufSize = SizeOf(Buffer);
begin
  if Count > BufSize then
    Result := Write(Buffer, BufSize) + Skip(Count - BufSize)
  else
    Result := Write(Buffer, Count)
end;
{$endif}

{$ifdef fpc}
{$ifndef ARM}
{$IfNDef WIN64}
function TStreamHelper.WriteData(const Buffer: Extended): Longint;
begin
  Result := Write(Buffer, SizeOf(Buffer));
end;
{$EndIf}
{$EndIf}
{$EndIf}

{$ifdef fpc}
{$ifndef ARM}
{$IfNDef WIN64}
function TStreamHelper.WriteData(const Buffer: Extended; Count: Longint
  ): Longint;
const
  BufSize = SizeOf(Buffer);
begin
  if Count > BufSize then
    Result := Write(Buffer, BufSize) + Skip(Count - BufSize)
  else
    Result := Write(Buffer, Count)
end;
{$EndIf}
{$EndIf}
{$EndIf}

{$ifdef fpc}
function TStreamHelper.WriteData(const Buffer: Int16): Longint;
begin
  Result := Write(Buffer, SizeOf(Buffer));
end;
{$endif}

{$ifdef fpc}
function TStreamHelper.WriteData(const Buffer: Int16; Count: Longint): Longint;
const
  BufSize = SizeOf(Buffer);
begin
  if Count > BufSize then
    Result := Write(Buffer, BufSize) + Skip(Count - BufSize)
  else
    Result := Write(Buffer, Count)
end;
{$EndIf}

{$ifdef fpc}
function TStreamHelper.WriteData(const Buffer: Int32): Longint;
begin
  Result := Write(Buffer, SizeOf(Buffer));
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: Int32; Count: Longint): Longint;
const
  BufSize = SizeOf(Buffer);
begin
  if Count > BufSize then
    Result := Write(Buffer, BufSize) + Skip(Count - BufSize)
  else
    Result := Write(Buffer, Count)
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: Int64): Longint;
begin
  Result := Write(Buffer, SizeOf(Buffer));
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: Int64; Count: Longint): Longint;
const
  BufSize = SizeOf(Buffer);
begin
  if Count > BufSize then
    Result := Write(Buffer, BufSize) + Skip(Count - BufSize)
  else
    Result := Write(Buffer, Count)
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: Int8): Longint;
begin
  Result := Write(Buffer, SizeOf(Buffer));
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: Int8; Count: Longint): Longint;
const
  BufSize = SizeOf(Buffer);
begin
  if Count > BufSize then
    Result := Write(Buffer, BufSize) + Skip(Count - BufSize)
  else
    Result := Write(Buffer, Count)
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: Pointer; Count: Longint
  ): Longint;
begin
  Result := Write(Buffer^, Count);
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: Single): Longint;
begin
  Result := Write(Buffer, SizeOf(Buffer));
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: Single; Count: Longint): Longint;
const
  BufSize = SizeOf(Buffer);
begin
  if Count > BufSize then
    Result := Write(Buffer, BufSize) + Skip(Count - BufSize)
  else
    Result := Write(Buffer, Count)
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: TBytes; Count: Longint): Longint;
begin
  Result := Write(Buffer, 0, Count);
end;
{$EndIf}

{$IfDef fpc}
{$IfNDef ARM}
{$IfNDef WIN64}
function TStreamHelper.WriteData(const Buffer: TExtended80Rec): Longint;
begin
  Result := Write(Buffer, SizeOf(Buffer));
end;
{$EndIf}
{$EndIf}
{$EndIf}

{$IfDef fpc}
{$IfNDef ARM}
{$IfNDef WIN64}
function TStreamHelper.WriteData(const Buffer: TExtended80Rec; Count: Longint
  ): Longint;
const
  BufSize = SizeOf(Buffer);
begin
  if Count > BufSize then
    Result := Write(Buffer, BufSize) + Skip(Count - BufSize)
  else
    Result := Write(Buffer, Count)
end;
{$EndIf}
{$EndIf}
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: UInt16): Longint;
begin
  Result := Write(Buffer, SizeOf(Buffer));
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: UInt16; Count: Longint): Longint;
const
  BufSize = SizeOf(Buffer);
begin
  if Count > BufSize then
    Result := Write(Buffer, BufSize) + Skip(Count - BufSize)
  else
    Result := Write(Buffer, Count)
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: UInt32): Longint;
begin
  Result := Write(Buffer, SizeOf(Buffer));
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: UInt32; Count: Longint): Longint;
const
  BufSize = SizeOf(Buffer);
begin
  if Count > BufSize then
    Result := Write(Buffer, BufSize) + Skip(Count - BufSize)
  else
    Result := Write(Buffer, Count)
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: UInt64): Longint;
begin
  Result := Write(Buffer, SizeOf(Buffer));
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: UInt64; Count: Longint): Longint;
const
  BufSize = SizeOf(Buffer);
begin
  if Count > BufSize then
    Result := Write(Buffer, BufSize) + Skip(Count - BufSize)
  else
    Result := Write(Buffer, Count)
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: UInt8): Longint;
begin
  Result := Write(Buffer, SizeOf(Buffer));
end;
{$EndIf}

{$IfDef fpc}
function TStreamHelper.WriteData(const Buffer: UInt8; Count: Longint): Longint;
const
  BufSize = SizeOf(Buffer);
begin
  if Count > BufSize then
    Result := Write(Buffer, BufSize) + Skip(Count - BufSize)
  else
    Result := Self.Write(Buffer, Count)
end;
{$EndIf}

procedure TStreamHelper.WriteDouble(D: Double);
begin
 WriteMSB(D, SizeOf(D));
end;

procedure TStreamHelper.WriteFloat(F: Single);
begin
 WriteMSB(F, SizeOf(F));
end;

procedure TStreamHelper.WriteInt16(I: Int16);
begin
  WriteMSB( I, 2 );
end;

procedure TStreamHelper.WriteInt32(I: Int32);
begin
  WriteMSB( I, 4 );
end;

procedure TStreamHelper.WriteInt64(I: Int64);
begin
  WriteMSB( I, 8 );
end;

procedure TStreamHelper.WriteInt8(I: Int8);
begin
  WriteMSB( I, 1 );
end;

procedure TStreamHelper.WriteMSB(var Buffer; Count: Cardinal);
var
  Index: Integer;
begin
  For Index := Count-1 downto 0 do
    WriteData( PByteArray(@Buffer)[Index], 1 );
end;

procedure TStreamHelper.WriteOctet(B: Byte);
begin
  WriteMSB( B, 1 );
end;

procedure TStreamHelper.WriteShortStr(S: String);
var
  Char: AnsiChar;
  Str: AnsiString;
  B: Byte;
begin
  B   := S.Length;
  Str := AnsiString( S );
  WriteData( B );
  for Char in Str do
    WriteData( Char );
end;

procedure TStreamHelper.WriteUInt64(I: UInt64);
begin
  WriteMSB( I, 8 );
end;

procedure TStreamHelper.WriteUInt16(I: UInt16);
begin
  WriteMSB( I, 2 );
end;

procedure TStreamHelper.WriteUInt32(I: UInt32);
begin
  WriteMSB( I, 4 );
end;

procedure TStreamHelper.WriteUInt8(I: UInt8);
begin
  WriteMSB( I, 1 );
end;

end.
