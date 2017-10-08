unit memoFormu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TmemoForm }

  TmemoForm = class(TForm)
    btnEdit: TButton;
    btnSave: TButton;
    Memo1: TMemo;
    Panel1: TPanel;
    procedure btnEditClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
  private

  public
    fileName : string;
  end;

var
  memoForm: TmemoForm;

implementation

{$R *.lfm}

{ TmemoForm }
var
  firstShow : boolean = true;

procedure TmemoForm.Memo1Change(Sender: TObject);
begin

end;

procedure TmemoForm.FormCreate(Sender: TObject);
begin
  firstShow := true;
end;

procedure TmemoForm.btnSaveClick(Sender: TObject);
begin
  memo1.Lines.SaveToFile(fileName);
end;

procedure TmemoForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

procedure TmemoForm.btnEditClick(Sender: TObject);
begin
  memo1.ReadOnly:=false;
end;

procedure TmemoForm.FormShow(Sender: TObject);
begin
  if firstShow then begin
    memoForm.Memo1.Lines.LoadFromFile(fileName);
    memoForm.Caption:=ExtractFileName(fileName);
    firstShow := false
  end;
end;

end.

