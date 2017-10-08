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
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
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


procedure TmemoForm.FormCreate(Sender: TObject);
begin
  firstShow := true;
end;

procedure TmemoForm.btnSaveClick(Sender: TObject);
begin
  memo1.Lines.SaveToFile(fileName);
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

