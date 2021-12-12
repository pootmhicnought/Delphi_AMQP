unit TestbenchWin;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.SyncObjs,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  AMQP.Connection, AMQP.Interfaces, AMQP.Classes;

type
  TConsumerThread = Class(TThread)
  Strict Private
    FQueue: TAMQPMessageQueue;
    Procedure WriteLine( Text: String; Sync: Boolean );
  Protected
    Procedure Execute; Override;
    Constructor Create( AQueue: TAMQPMessageQueue ); Reintroduce;
  End;

  TTestbenchForm = class(TForm)
    MemoMessages: TMemo;
    ButtonConnect: TButton;
    MemoSent: TMemo;
    MemoReceived: TMemo;
    MemoSentBytes: TMemo;
    MemoReceivedBytes: TMemo;
    ButtonDisconnect: TButton;
    ButtonPublishRed: TButton;
    ButtonOpenChannel: TButton;
    ButtonCloseChannel: TButton;
    ButtonExchangeDeclare: TButton;
    ButtonExchangeDelete: TButton;
    ButtonQueueDeclare: TButton;
    ButtonQueueDelete: TButton;
    ButtonQueueBind: TButton;
    ButtonQueueUnbind: TButton;
    ButtonPublishBlue: TButton;
    ButtonGetRed: TButton;
    ButtonGetBlue: TButton;
    ButtonConfirmSelect: TButton;
    ButtonConsumeBlue: TButton;
    Panel1: TPanel;
    LabelStatus: TLabel;
    Timer1: TTimer;
    ButtonPurgeRed: TButton;
    ButtonCancelBlue: TButton;
    ButtonReject: TButton;
    ButtonThreadConsume: TButton;
    ButtonCancelRed: TButton;
    ButtonBigExchange: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    btn1: TButton;
    btn2: TButton;
    btn3: TButton;
    btn4: TButton;
    btn5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonConnectClick(Sender: TObject);
    procedure ButtonDisconnectClick(Sender: TObject);
    procedure ButtonPublishRedClick(Sender: TObject);
    procedure ButtonOpenChannelClick(Sender: TObject);
    procedure ButtonCloseChannelClick(Sender: TObject);
    procedure ButtonExchangeDeclareClick(Sender: TObject);
    procedure ButtonExchangeDeleteClick(Sender: TObject);
    procedure ButtonQueueDeclareClick(Sender: TObject);
    procedure ButtonQueueDeleteClick(Sender: TObject);
    procedure ButtonQueueBindClick(Sender: TObject);
    procedure ButtonQueueUnbindClick(Sender: TObject);
    procedure ButtonPublishBlueClick(Sender: TObject);
    procedure ButtonGetRedClick(Sender: TObject);
    procedure ButtonGetBlueClick(Sender: TObject);
    procedure ButtonConfirmSelectClick(Sender: TObject);
    procedure ButtonConsumeBlueClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ButtonPurgeRedClick(Sender: TObject);
    procedure ButtonCancelBlueClick(Sender: TObject);
    procedure ButtonRejectClick(Sender: TObject);
    procedure ButtonThreadConsumeClick(Sender: TObject);
    procedure ButtonCancelRedClick(Sender: TObject);
    procedure ButtonBigExchangeClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure btn2Click(Sender: TObject);
    procedure btn3Click(Sender: TObject);
    procedure btn4Click(Sender: TObject);
    procedure btn5Click(Sender: TObject);
  private
    AMQP: TAMQPConnection;
    Channel: IAMQPChannel;
    RecvWireDebug: TStringList;
    SentWireDebug: TStringList;
    RecvMethodDebug: TStringList;
    SentMethodDebug: TStringList;
    DebugLock: TCriticalSection;
    Thread: TConsumerThread;

    Procedure ConsumeDebug( AMemo: TMemo; AStrings: TStrings );
    Procedure AddAndScrollToBottom( AMemo: TMemo; AStrings: TStrings );

    Procedure AMQPWireEvent( Sender: TObject; SendRecv: TSendRecv; AStrings: TStrings );
    Procedure AMQPDebugEvent( Sender: TObject; SendRecv: TSendRecv; AStrings: TStrings );
  public
  end;

var
  TestbenchForm: TTestbenchForm;

implementation

Uses
  AMQP.Message, AMQP.StreamHelper, AMQP.Arguments, AMQP.IMessageProperties, AMQP.MessageProperties, AMQP.Types;

{$R *.dfm}

procedure TTestbenchForm.AddAndScrollToBottom(AMemo: TMemo; AStrings: TStrings);
begin
  AMemo.Lines.AddStrings( AStrings );
  SendMessage( AMemo.Handle, EM_LINESCROLL, 0, AMemo.Lines.Count);
end;

procedure TTestbenchForm.AMQPDebugEvent(Sender: TObject; SendRecv: TSendRecv; AStrings: TStrings);
begin
  DebugLock.Enter;
  Try
    case SendRecv of
      srSend    : SentMethodDebug.AddStrings( AStrings );
      srReceive : RecvMethodDebug.AddStrings( AStrings );
    end;
  Finally
    DebugLock.Release;
  End;
end;

procedure TTestbenchForm.AMQPWireEvent(Sender: TObject; SendRecv: TSendRecv; AStrings: TStrings);
begin
  DebugLock.Enter;
  Try
    case SendRecv of
      srSend    : SentWireDebug.AddStrings( AStrings );
      srReceive : RecvWireDebug.AddStrings( AStrings );
    end;
  Finally
    DebugLock.Release;
  End;
end;

procedure TTestbenchForm.btn1Click(Sender: TObject);
begin
  Channel.ExchangeDeclare( 'Exchange1', etTopic, []);
end;

procedure TTestbenchForm.btn2Click(Sender: TObject);
begin
  Channel.ExchangeDeclare( 'Exchange2', etTopic, []);
end;

procedure TTestbenchForm.btn3Click(Sender: TObject);
begin
 Channel.ExchangeBind('Exchange2', 'Exchange1', 'color.#', []);
 Channel.ExchangeBind('Colors', 'Exchange2', 'color.red', []);
end;

procedure TTestbenchForm.btn4Click(Sender: TObject);
begin
 Channel.ExchangeUnBind('Colors', 'Exchange2', 'color.red', []);
end;

procedure TTestbenchForm.btn5Click(Sender: TObject);
var Prop: IAMQPMessageProperties;
begin
  if Channel = nil then
    raise Exception.Create('Channel not open');
  Prop := TAMQPMessageProperties.Create('TestBench');
  Prop.ApplicationHeaders.Add('Field1', TShortShortInt.Create(100));
  Prop.ApplicationHeaders.Add('Field2', TDouble.Create(1021.12));
  Prop.ApplicationHeaders.Add('Field3', TLongString.Create('Test'));
  Prop.ApplicationHeaders.Add('Field4', TFieldArray.Create.Add('1').Add(2).Add(1921.281));
  Prop.Priority.Value := 220;
  Channel.BasicPublish( 'Exchange1', 'color.red', 'Magenta is the word!', False, Prop);
end;

procedure TTestbenchForm.ButtonGetBlueClick(Sender: TObject);
var
  Msg: TAMQPMessage;
begin
  Msg := Channel.BasicGet( 'blue' );
  Try
    if Msg <> nil then
    Begin
      MemoMessages.Lines.Add( 'Message: ' + Msg.Body.AsString[ TEncoding.ASCII ] );
      Msg.Ack;
    End
    Else
      MemoReceived.Lines.Add( 'No message' );
  Finally
    Msg.Free;
  End;
end;

procedure TTestbenchForm.ButtonQueueUnbindClick(Sender: TObject);
begin
  Channel.QueueUnBind( 'red',  'Colors', 'color.red' , []);
  Channel.QueueUnBind( 'blue', 'Colors', 'color.blue' , []);
end;

procedure TTestbenchForm.ButtonRejectClick(Sender: TObject);
var
  Msg: TAMQPMessage;
begin
  Msg := Channel.BasicGet( 'red' );
  Try
    if Msg <> nil then
    Begin
      MemoMessages.Lines.Add( 'Message: ' + Msg.Body.AsString[ TEncoding.ASCII ] );
      Msg.Reject;
    End
    Else
      MemoReceived.Lines.Add( 'No message' );
  Finally
    Msg.Free;
  End;
end;

procedure TTestbenchForm.ConsumeDebug(AMemo: TMemo; AStrings: TStrings);
begin
  If AStrings.Count > 0 then
  Begin
    AddAndScrollToBottom( AMemo, AStrings );
    AStrings.Clear;
  End;
end;

procedure TTestbenchForm.ButtonQueueBindClick(Sender: TObject);
begin
  Channel.QueueBind( 'red',  'Colors', 'color.red', [] );
  Channel.QueueBind( 'blue', 'Colors', 'color.blue', [] );
end;

procedure TTestbenchForm.ButtonQueueDeclareClick(Sender: TObject);
begin
  Channel.QueueDeclare( 'red' , []);
  Channel.QueueDeclare( 'blue' , []);
end;

procedure TTestbenchForm.ButtonQueueDeleteClick(Sender: TObject);
begin
  Channel.QueueDelete( 'red',  False, False );
  Channel.QueueDelete( 'blue', False, False );
end;

procedure TTestbenchForm.ButtonExchangeDeclareClick(Sender: TObject);
begin
  Channel.ExchangeDeclare( 'Colors', etTopic , []);
end;

procedure TTestbenchForm.ButtonExchangeDeleteClick(Sender: TObject);
begin
  Channel.ExchangeDelete( 'Colors' );
end;

procedure TTestbenchForm.ButtonGetRedClick(Sender: TObject);
var
  Msg: TAMQPMessage;
begin
  Msg := Channel.BasicGet( 'red' );
  Try
    if Msg <> nil then
    Begin
      MemoMessages.Lines.Add( 'Message: ' + Msg.Body.AsString[ TEncoding.ASCII ] );
      Msg.Ack;
    End
    Else
      MemoReceived.Lines.Add( 'No message' );
  Finally
    Msg.Free;
  End;
end;

procedure TTestbenchForm.ButtonDisconnectClick(Sender: TObject);
begin
  Try
    AMQP.Disconnect;
  Finally
    Channel := nil;
  End;
end;

procedure TTestbenchForm.ButtonOpenChannelClick(Sender: TObject);
begin
  Channel := AMQP.OpenChannel;
end;

procedure TTestbenchForm.ButtonPublishBlueClick(Sender: TObject);
begin
  if Channel = nil then
    raise Exception.Create('Channel not open');
  Channel.BasicPublish( 'Colors', 'color.blue', 'I see cyan in your eyes!' );
end;

procedure TTestbenchForm.ButtonPublishRedClick(Sender: TObject);
begin
  if Channel = nil then
    raise Exception.Create('Channel not open');
  Channel.BasicPublish( 'Colors', 'color.red', 'Magenta is the word!' );
end;

procedure TTestbenchForm.ButtonPurgeRedClick(Sender: TObject);
begin
  Channel.QueuePurge( 'red' );
end;

procedure TTestbenchForm.ButtonCancelRedClick(Sender: TObject);
begin
  Channel.BasicCancel( 'ConsumeRed' );
end;

procedure TTestbenchForm.Button1Click(Sender: TObject);
begin
  Channel.QueueDeclare( 'BigQueue', MakeArguments.SetMessageTTL( 12000 ), False, True, False, False, False);
end;

procedure TTestbenchForm.Button2Click(Sender: TObject);
begin
  Channel.QueueBind( 'BigQueue', 'BigMessage', '', [] );
end;

procedure TTestbenchForm.Button3Click(Sender: TObject);
var
  Payload: TMemoryStream;
  I: Integer;
begin
  if Channel = nil then
    raise Exception.Create('Channel not open');
  Payload := TMemoryStream.Create;
  Try
    for I := 1 to 2048 do
    Begin
      Payload.WriteOctet( 0 );
      Payload.WriteOctet( 1 );
      Payload.WriteOctet( 2 );
      Payload.WriteOctet( 3 );
      Payload.WriteOctet( 4 );
      Payload.WriteOctet( 5 );
      Payload.WriteOctet( 6 );
      Payload.WriteOctet( 7 );
    End;
    Channel.BasicPublish( 'BigMessage', '', Payload );
  Finally
    Payload.Free;
  End;
end;

procedure TTestbenchForm.Button4Click(Sender: TObject);

  Procedure CheckEquals( A, B: Byte );
  Begin
    if A <> B then
      raise Exception.Create('Message content error');
  End;

var
  Msg: TAMQPMessage;
  Buffer: TBytes;
  I: Integer;
begin
  Msg := Channel.BasicGet( 'BigQueue' );
  Try
    if Msg <> nil then
    Begin
      MemoMessages.Lines.Add( 'Message size: ' + Msg.Body.Size.ToString );
      Msg.Ack;

      SetLength( Buffer, Msg.Body.Size );
      Msg.Body.Read( Buffer, 0, Msg.Body.Size );
      I := 0;
      while I < Length(Buffer) do
      Begin
        CheckEquals( Buffer[i], 0 ); inc(I);
        CheckEquals( Buffer[i], 1 ); inc(I);
        CheckEquals( Buffer[i], 2 ); inc(I);
        CheckEquals( Buffer[i], 3 ); inc(I);
        CheckEquals( Buffer[i], 4 ); inc(I);
        CheckEquals( Buffer[i], 5 ); inc(I);
        CheckEquals( Buffer[i], 6 ); inc(I);
        CheckEquals( Buffer[i], 7 ); inc(I);
      End;
    End
    Else
      MemoReceived.Lines.Add( 'No message' );
  Finally
    Msg.Free;
  End;
end;

procedure TTestbenchForm.ButtonBigExchangeClick(Sender: TObject);
begin
  Channel.ExchangeDeclare( 'BigMessage', etTopic , []);
end;

procedure TTestbenchForm.ButtonCancelBlueClick(Sender: TObject);
begin
  Channel.BasicCancel( 'ConsumeBlue' );
end;

procedure TTestbenchForm.ButtonThreadConsumeClick(Sender: TObject);
var
  Queue: TAMQPMessageQueue;
begin
  if Channel = nil then
    raise Exception.Create('Channel not open');
  Queue := TAMQPMessageQueue.Create;
  Channel.BasicConsume( Queue, 'red', 'ConsumeRed' );
  Thread.Free;
  Thread := nil;
  Thread := TConsumerThread.Create( Queue );
end;

procedure TTestbenchForm.ButtonCloseChannelClick(Sender: TObject);
begin
  Try
    Channel.Close;
  Finally
    Channel := nil;
  End;
end;

procedure TTestbenchForm.ButtonConfirmSelectClick(Sender: TObject);
begin
  Channel.ConfirmSelect;
end;

procedure TTestbenchForm.ButtonConnectClick(Sender: TObject);
begin
  AMQP.Host          := 'broomcloset';
  AMQP.Port          := 45672;
  AMQP.VirtualHost   := '/';
  AMQP.Username      := 'guest';
  AMQP.Password      := 'guest';
  AMQP.ApplicationID := 'Testbench';
  AMQP.MaxFrameSize  := 4096;
  AMQP.Timeout       := 60000;
  AMQP.Connect;
end;

procedure TTestbenchForm.ButtonConsumeBlueClick(Sender: TObject);
begin
  if Channel = nil then
    raise Exception.Create('Channel not open');
  Channel.BasicConsume( Procedure( Msg: TAMQPMessage; var SendAck: Boolean )
                        var
                          Txt : String;
                        Begin
                          Txt := Msg.Body.AsString[ TEncoding.ASCII ];
                          TThread.Synchronize( nil, Procedure
                                                    Begin
                                                      MemoMessages.Lines.Add( Txt );
                                                    End );
                        End,
                        'blue', 'ConsumeBlue');
end;

procedure TTestbenchForm.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;
  RecvWireDebug   := TStringList.Create;
  SentWireDebug   := TStringList.Create;
  RecvMethodDebug := TStringList.Create;
  SentMethodDebug := TStringList.Create;
  DebugLock   := TCriticalSection.Create;
  AMQP := TAMQPConnection.Create;
  AMQP.HeartbeatSecs := 120;
  AMQP.Timeout := 5000;
  AMQP.OnWireDebug   := AMQPWireEvent;
  AMQP.OnDebug       := AMQPDebugEvent;
  Channel := nil;
  Thread := nil;
end;

procedure TTestbenchForm.FormDestroy(Sender: TObject);
begin
  Channel := nil;
  AMQP.Free;
  Thread.Free;
  DebugLock.Free;
  RecvWireDebug.Free;
  SentWireDebug.Free;
  RecvMethodDebug.Free;
  SentMethodDebug.Free;
end;

procedure TTestbenchForm.Timer1Timer(Sender: TObject);
var
  Status: TStringList;
begin
  DebugLock.Enter;
  Try
    ConsumeDebug( MemoSentBytes,     SentWireDebug );
    ConsumeDebug( MemoReceivedBytes, RecvWireDebug );
    ConsumeDebug( MemoSent,          SentMethodDebug );
    ConsumeDebug( MemoReceived,      RecvMethodDebug );
  Finally
    DebugLock.Release;
  End;

  Status := TStringList.Create;
  Try
    Status.Values[ 'LastHeartbeat' ] := DateTimeToStr(AMQP.LastHeartbeat);
    Status.Values[ 'IsOpen' ]        := BoolToStr( AMQP.IsOpen, True );
    LabelStatus.Caption := Status.Text;
  Finally
    Status.Free;
  End;
end;

{ TConsumerThread }

constructor TConsumerThread.Create(AQueue: TAMQPMessageQueue);
begin
  FQueue := AQueue;
  inherited Create;
end;

procedure TConsumerThread.Execute;
var
  Msg: TAMQPMessage;
begin
  WriteLine( 'Thread starting', False );
  NameThreadForDebugging( 'ConsumerThread' );
  Repeat
    Msg := FQueue.Get(INFINITE);
    if Msg = nil then
      Terminate;
    if not Terminated then
    Begin
      WriteLine( 'Thread message: ' + Msg.Body.AsString[ TEncoding.ASCII ], False );
      Msg.Ack;
      Msg.Free;
    End;
  Until Terminated;
  FQueue.Free;
  WriteLine( 'Thread stopped', True );
end;

procedure TConsumerThread.WriteLine( Text: String; Sync: Boolean );
begin
  if Sync then
    Synchronize( Procedure
                 Begin
                   TestbenchForm.MemoMessages.Lines.Add( Text );
                 End )
  else
    Queue( Procedure
           Begin
             TestbenchForm.MemoMessages.Lines.Add( Text );
           End );
end;

end.
