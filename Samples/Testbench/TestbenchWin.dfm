object TestbenchForm: TTestbenchForm
  Left = 0
  Top = 0
  Caption = 'AMQP Testbench'
  ClientHeight = 592
  ClientWidth = 1202
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    1202
    592)
  PixelsPerInch = 96
  TextHeight = 13
  object MemoMessages: TMemo
    Left = 8
    Top = 400
    Width = 881
    Height = 184
    Anchors = [akLeft, akRight, akBottom]
    Color = clBlack
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = 18
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 1
    ExplicitTop = 629
    ExplicitWidth = 897
  end
  object ButtonConnect: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Connect'
    TabOrder = 0
    OnClick = ButtonConnectClick
  end
  object MemoSent: TMemo
    Left = 8
    Top = 160
    Width = 401
    Height = 235
    Anchors = [akLeft, akTop, akBottom]
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 16
    Font.Name = 'Courier New'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 2
    ExplicitHeight = 464
  end
  object MemoReceived: TMemo
    Left = 617
    Top = 160
    Width = 385
    Height = 235
    Anchors = [akLeft, akTop, akRight, akBottom]
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = 16
    Font.Name = 'Courier New'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 3
    ExplicitWidth = 401
    ExplicitHeight = 464
  end
  object MemoSentBytes: TMemo
    Left = 415
    Top = 160
    Width = 196
    Height = 234
    Anchors = [akLeft, akTop, akBottom]
    Color = clGreen
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = 16
    Font.Name = 'Courier New'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 4
    ExplicitHeight = 463
  end
  object MemoReceivedBytes: TMemo
    Left = 1008
    Top = 104
    Width = 186
    Height = 291
    Anchors = [akTop, akRight, akBottom]
    Color = clGreen
    Ctl3D = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWhite
    Font.Height = 16
    Font.Name = 'Courier New'
    Font.Style = []
    ParentCtl3D = False
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 5
    ExplicitLeft = 1024
    ExplicitHeight = 520
  end
  object ButtonDisconnect: TButton
    Left = 8
    Top = 39
    Width = 75
    Height = 25
    Caption = 'Disconnect'
    TabOrder = 6
    OnClick = ButtonDisconnectClick
  end
  object ButtonPublishRed: TButton
    Left = 600
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Publish Red'
    TabOrder = 7
    OnClick = ButtonPublishRedClick
  end
  object ButtonOpenChannel: TButton
    Left = 89
    Top = 9
    Width = 90
    Height = 25
    Caption = 'Open Channel'
    TabOrder = 8
    OnClick = ButtonOpenChannelClick
  end
  object ButtonCloseChannel: TButton
    Left = 89
    Top = 40
    Width = 90
    Height = 25
    Caption = 'Close Channel'
    TabOrder = 9
    OnClick = ButtonCloseChannelClick
  end
  object ButtonExchangeDeclare: TButton
    Left = 185
    Top = 9
    Width = 106
    Height = 25
    Caption = 'Declare Exchange'
    TabOrder = 10
    OnClick = ButtonExchangeDeclareClick
  end
  object ButtonExchangeDelete: TButton
    Left = 185
    Top = 39
    Width = 106
    Height = 25
    Caption = 'Delete Exchange'
    TabOrder = 11
    OnClick = ButtonExchangeDeleteClick
  end
  object ButtonQueueDeclare: TButton
    Left = 297
    Top = 8
    Width = 103
    Height = 25
    Caption = 'Declare Queue'
    TabOrder = 12
    OnClick = ButtonQueueDeclareClick
  end
  object ButtonQueueDelete: TButton
    Left = 297
    Top = 42
    Width = 103
    Height = 25
    Caption = 'Delete Queue'
    TabOrder = 13
    OnClick = ButtonQueueDeleteClick
  end
  object ButtonQueueBind: TButton
    Left = 415
    Top = 8
    Width = 82
    Height = 25
    Caption = 'Bind Queue'
    TabOrder = 14
    OnClick = ButtonQueueBindClick
  end
  object ButtonQueueUnbind: TButton
    Left = 415
    Top = 39
    Width = 82
    Height = 25
    Caption = 'Unbind queue'
    TabOrder = 15
    OnClick = ButtonQueueUnbindClick
  end
  object ButtonPublishBlue: TButton
    Left = 600
    Top = 39
    Width = 75
    Height = 25
    Caption = 'Publish Blue'
    TabOrder = 16
    OnClick = ButtonPublishBlueClick
  end
  object ButtonGetRed: TButton
    Left = 696
    Top = 9
    Width = 75
    Height = 25
    Caption = 'Get red'
    TabOrder = 17
    OnClick = ButtonGetRedClick
  end
  object ButtonGetBlue: TButton
    Left = 696
    Top = 40
    Width = 75
    Height = 25
    Caption = 'Get Blue'
    TabOrder = 18
    OnClick = ButtonGetBlueClick
  end
  object ButtonConfirmSelect: TButton
    Left = 864
    Top = 8
    Width = 89
    Height = 25
    Caption = 'Confirm Select'
    TabOrder = 19
    OnClick = ButtonConfirmSelectClick
  end
  object ButtonConsumeBlue: TButton
    Left = 976
    Top = 8
    Width = 91
    Height = 25
    Caption = 'Consume Blue'
    TabOrder = 20
    OnClick = ButtonConsumeBlueClick
  end
  object Panel1: TPanel
    Left = 895
    Top = 401
    Width = 299
    Height = 183
    Anchors = [akRight, akBottom]
    BorderStyle = bsSingle
    Caption = 'Panel1'
    Ctl3D = False
    ParentCtl3D = False
    ShowCaption = False
    TabOrder = 21
    ExplicitLeft = 911
    ExplicitTop = 630
    object LabelStatus: TLabel
      Left = 8
      Top = 8
      Width = 56
      Height = 13
      Caption = 'LabelStatus'
    end
  end
  object ButtonPurgeRed: TButton
    Left = 503
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Purge Red'
    TabOrder = 22
    OnClick = ButtonPurgeRedClick
  end
  object ButtonCancelBlue: TButton
    Left = 976
    Top = 40
    Width = 91
    Height = 25
    Caption = 'Cancel Blue'
    TabOrder = 23
    OnClick = ButtonCancelBlueClick
  end
  object ButtonReject: TButton
    Left = 777
    Top = 9
    Width = 75
    Height = 25
    Caption = 'Reject red'
    TabOrder = 24
    OnClick = ButtonRejectClick
  end
  object ButtonThreadConsume: TButton
    Left = 1073
    Top = 8
    Width = 96
    Height = 25
    Caption = 'Consume Thread'
    TabOrder = 25
    OnClick = ButtonThreadConsumeClick
  end
  object ButtonCancelRed: TButton
    Left = 1073
    Top = 40
    Width = 96
    Height = 25
    Caption = 'Cancel Red'
    TabOrder = 26
    OnClick = ButtonCancelRedClick
  end
  object ButtonBigExchange: TButton
    Left = 185
    Top = 71
    Width = 106
    Height = 25
    Caption = 'Declare Big Exchange'
    TabOrder = 27
    OnClick = ButtonBigExchangeClick
  end
  object Button1: TButton
    Left = 297
    Top = 73
    Width = 103
    Height = 25
    Caption = 'Declare Big Queue'
    TabOrder = 28
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 415
    Top = 70
    Width = 82
    Height = 25
    Caption = 'Bind big queue'
    TabOrder = 29
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 600
    Top = 70
    Width = 75
    Height = 25
    Caption = 'Publish big'
    TabOrder = 30
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 696
    Top = 71
    Width = 75
    Height = 25
    Caption = 'Get big'
    TabOrder = 31
    OnClick = Button4Click
  end
  object btn1: TButton
    Left = 185
    Top = 102
    Width = 106
    Height = 25
    Caption = 'Declare Exchange 1'
    TabOrder = 32
    OnClick = btn1Click
  end
  object btn2: TButton
    Left = 297
    Top = 102
    Width = 103
    Height = 25
    Caption = 'Declare Exchange 2'
    TabOrder = 33
    OnClick = btn2Click
  end
  object btn3: TButton
    Left = 415
    Top = 102
    Width = 82
    Height = 25
    Caption = 'Bind Exchange'
    TabOrder = 34
    OnClick = btn3Click
  end
  object btn4: TButton
    Left = 344
    Top = 132
    Width = 153
    Height = 25
    Caption = 'Unbind Color from Exchange2'
    TabOrder = 35
    OnClick = btn4Click
  end
  object btn5: TButton
    Left = 536
    Top = 102
    Width = 139
    Height = 25
    Caption = 'Publish Red To Exchange 1'
    TabOrder = 36
    OnClick = btn5Click
  end
  object Timer1: TTimer
    Interval = 200
    OnTimer = Timer1Timer
    Left = 1167
    Top = 613
  end
end
