// JCL_DEBUG_EXPERT_GENERATEJDBG OFF
// JCL_DEBUG_EXPERT_INSERTJDBG OFF
// JCL_DEBUG_EXPERT_DELETEMAPFILE OFF
program Testbench;

uses
  Vcl.Forms,
  TestbenchWin in 'TestbenchWin.pas' {TestbenchForm},
  AMQP.Method in '..\..\Source\AMQP.Method.pas',
  AMQP.Types in '..\..\Source\AMQP.Types.pas',
  AMQP.Message in '..\..\Source\AMQP.Message.pas',
  AMQP.Protocol in '..\..\Source\AMQP.Protocol.pas',
  AMQP.Connection in '..\..\Source\AMQP.Connection.pas',
  AMQP.Frame in '..\..\Source\AMQP.Frame.pas',
  AMQP.Helper in '..\..\Source\AMQP.Helper.pas',
  AMQP.Payload in '..\..\Source\AMQP.Payload.pas',
  AMQP.MessageProperties in '..\..\Source\AMQP.MessageProperties.pas',
  AMQP.Header in '..\..\Source\AMQP.Header.pas',
  AMQP.StreamHelper in '..\..\Source\AMQP.StreamHelper.pas',
  AMQP.Channel in '..\..\Source\AMQP.Channel.pas',
  AMQP.Classes in '..\..\Source\AMQP.Classes.pas',
  AMQP.Interfaces in '..\..\Source\AMQP.Interfaces.pas',
  AMQP.IMessageProperties in '..\..\Source\AMQP.IMessageProperties.pas',
  AMQP.Arguments in '..\..\Source\AMQP.Arguments.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TTestbenchForm, TestbenchForm);
  Application.Run;
end.
