unit aboutformu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TaboutForm }

  TaboutForm = class(TForm)
    Memo1: TMemo;
    procedure Memo1Change(Sender: TObject);
  private

  public

  end;

var
  aboutForm: TaboutForm;

implementation

{$R *.lfm}

{ TaboutForm }

procedure TaboutForm.Memo1Change(Sender: TObject);
begin

end;

end.

