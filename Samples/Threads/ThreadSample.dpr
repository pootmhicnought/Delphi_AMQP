// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
program ThreadSample;

uses
  Vcl.Forms,
  ThreadSampleWin in 'ThreadSampleWin.pas' {ThreadSampleForm},
  AMQP.Channel in '..\..\Source\AMQP.Channel.pas',
  AMQP.Classes in '..\..\Source\AMQP.Classes.pas',
  AMQP.Connection in '..\..\Source\AMQP.Connection.pas',
  AMQP.Frame in '..\..\Source\AMQP.Frame.pas',
  AMQP.Header in '..\..\Source\AMQP.Header.pas',
  AMQP.Helper in '..\..\Source\AMQP.Helper.pas',
  AMQP.Interfaces in '..\..\Source\AMQP.Interfaces.pas',
  AMQP.Message in '..\..\Source\AMQP.Message.pas',
  AMQP.MessageProperties in '..\..\Source\AMQP.MessageProperties.pas',
  AMQP.Method in '..\..\Source\AMQP.Method.pas',
  AMQP.Payload in '..\..\Source\AMQP.Payload.pas',
  AMQP.Protocol in '..\..\Source\AMQP.Protocol.pas',
  AMQP.StreamHelper in '..\..\Source\AMQP.StreamHelper.pas',
  AMQP.Types in '..\..\Source\AMQP.Types.pas',
  AMQP.IMessageProperties in '..\..\Source\AMQP.IMessageProperties.pas',
  AMQP.Arguments in '..\..\Source\AMQP.Arguments.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TThreadSampleForm, ThreadSampleForm);
  Application.Run;
end.
