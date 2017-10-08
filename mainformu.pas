unit mainformu;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, TAGraph, TASeries, Forms, Controls, Graphics,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls;

type
  { TMeterRead }
  TMeterRead = class(TObject)
    TS : TDateTime;
    CH1 : single;
    CH2 : single;
  end;

  { TForm1 }

  TForm1 = class(TForm)
    btnClear: TButton;
    btnLoad: TButton;
    btnCheck: TButton;
    btnRemove: TButton;
    btnView: TButton;
    btnProcess: TButton;
    btnWriteCsv: TButton;
    Chart1: TChart;
    Chart1BarSeries1: TBarSeries;
    Chart2: TChart;
    Chart2LineSeries1: TLineSeries;
    edtOffBelow: TEdit;
    edtCH1Max: TEdit;
    edtCH1min: TEdit;
    edtCh2Max: TEdit;
    edtCH2Min: TEdit;
    edtOnAbove: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    lbLogging: TListBox;
    lbOutput: TListBox;
    lbFiles: TListBox;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    Splitter5: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure btnCheckClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnProcessClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnWriteCsvClick(Sender: TObject);
  private
    bins: array of integer;
    binMax: array of single;
    meterReads: array of TMeterRead;
    function hasCommas(line : string) : boolean;
    procedure extractData(const line : string; var col1,col2,col3 : string);
    procedure logLine(logString : string);
    function calcState(const value, lowLimit, highLimit : single; var currentState:boolean):boolean;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }
uses
  dateutils;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  lbFiles.Clear;
end;

procedure TForm1.btnCheckClick(Sender: TObject);
const
  NUM_BINS = 10;
var
  i,j : integer;
  myFileName : string;
  lineTime,lineValA,lineValB : string;
  myFile : TStringList = nil;
  maxVal, minVal, span, spanInc : single;
  goodLines, badLines, totLines : integer;
  logTime : TDateTime;
  CH1val, CH2val : single;
begin
  goodLines := 0;
  badLines := 0;
  totLines := 0;
  maxVal := 0;
  minVal := maxint;
  PageControl1.ActivePageIndex:=0;

  if meterReads <> nil then begin
    for i := 0 to length(meterReads) -1 do   // clean up the meter read objects
      meterReads[i].free;
    FreeAndNil(meterReads);
  end;

  myFile := TStringList.Create;
  try
    for i := 0 to lbFiles.Items.Count -1 do begin  // all the files in the list
      myFile.Clear;
      myFileName := lbFiles.Items[i];
      logLine('Using: ' + myFileName);
      myFile.LoadFromFile(myFileName);
      totLines := myFile.Count;
      logLine('File lines = ' + IntToStr(totLines));
      for j := 0 to totlines -1 do begin              // all the lines in the file
        if hasCommas(myFile[j]) then begin
          inc(goodLines);
          extractData(myFile[j],lineTime,lineValA,lineValB);
          if trim(lineTime) <> trim('UTC TIME SEC') then begin          { DONE : need to do comparison with no spaces }
            try
              logTime := UnixToDateTime(trunc(StrToFloat(lineTime)));
              ch1val := StrToFloat(lineValA);
              ch2val := StrToFloat(lineValB);
            except
              showMessage('Error in file '+myFileName+' at line '+intToStr(j+1));
              raise
            end;
            logLine(lineTime+' '+lineValA+' '+lineValB);
            logLine(datetimetostr(logTime)+' '+floattostr(CH1val)+' '+floattostr(CH2val));
            if CH2val > maxVal then                                      { TODO : fix for ch1 or ch2 }
              maxVal := CH2val;
            if CH2Val < minVal then
              minVal := CH2val;
          setlength(meterReads,length(meterReads)+1);  // make the array one bigger
          meterReads[length(meterReads)-1] := TMeterRead.create;
          meterReads[length(meterReads)-1].TS := logTime;
          meterReads[length(meterReads)-1].CH1 := CH1val;
          meterReads[length(meterReads)-1].CH2 := CH2val;
          end;
        end
        else begin
          inc(badLines);
        end;
      end;
      logLine(intTostr(goodlines) + ' good and ' + IntToStr(badLines) + ' bad lines');
      logLine('Min: ' + FloatToStr(minVal) + 'Max ' + FloatToStr(maxVal));
      edtCH2Min.Text:=FloatToStr(minVal);
      edtCH2Max.Text:=FloatToStr(maxVal);
    end;
  finally
    myFile.Free;
  end;

  // we have an array of TMeterRead's and are finished with the files
  setlength(bins,NUM_BINS);  // setup to find the distributions of the readings, there should be 2 clusters
  SetLength(binMax,NUM_BINS);
  span := maxVal - minVal;  // find the incremental values for the bin maximums
  spanInc := span / NUM_BINS;
  for i := 0 to NUM_BINS -1 do      // load up the max values for the bins
    binmax[i] := ((i+1) * spanInc) + minVal;

  for i := 0 to length(meterReads) -1 do begin
    if meterReads[i].CH2 < binmax[0] then
      inc(bins[0])
    else if meterReads[i].CH2 < binmax[1] then
      inc(bins[1])
    else if meterReads[i].CH2 < binmax[2] then
      inc(bins[2])
    else if meterReads[i].CH2 < binmax[3] then
      inc(bins[3])
    else if meterReads[i].CH2 < binmax[4] then
      inc(bins[4])
    else if meterReads[i].CH2 < binmax[5] then
      inc(bins[5])
    else if meterReads[i].CH2 < binmax[6] then
      inc(bins[6])
    else if meterReads[i].CH2 < binmax[7] then
      inc(bins[7])
    else if meterReads[i].CH2 < binmax[8] then
      inc(bins[8])
    else if meterReads[i].CH2 < binmax[9] then
      inc(bins[9]);
  end;
  logLine(intToStr(bins[0])+', '+intToStr(bins[1])+', '+intToStr(bins[2])+', '+intToStr(bins[3])+', '+intToStr(bins[4])+', '+intToStr(bins[5])+', '+intToStr(bins[6])+', '+intToStr(bins[7])+', '+intToStr(bins[8])+', '+intToStr(bins[9]));
  Chart1BarSeries1.Clear;
  for i := 0 to length(bins)-1 do           // populate the chart
    Chart1BarSeries1.AddXY(binMax[i],bins[i]);
end;

procedure TForm1.btnLoadClick(Sender: TObject);
var
  i : integer;
begin
  if OpenDialog1.execute then begin
    lbFiles.clear;
    for i := 0 to OpenDialog1.Files.Count -1 do
      lbFiles.Items.Add(OpenDialog1.Files.Strings[i]);
  end;
end;

function BoolToInt(state : boolean):integer;
begin
  if state then
    result := 1
  else
    result := 0;
end;

function BoolToOnOff(state : boolean):String;
begin
  if state then
    result := 'On'
  else
    result := 'Off';
end;

function calcDurationSecs(firstTime,secondTime : TDateTime):integer;
Var
  HH,MM,SS,MS: Word;
begin
  DecodeTime((secondTime - firstTime),HH,MM,SS,MS);
  result := (HH * 60 * 60) + (MM * 60) + SS;
end;

function calcDurationMins(firstTime,secondTime : TDateTime):integer;
Var
  HH,MM,SS,MS: Word;
begin
  DecodeTime((secondTime - firstTime),HH,MM,SS,MS);
  result := (HH * 60) + (MM);
  if SS > 29 then
    inc(result);
end;

procedure TForm1.btnProcessClick(Sender: TObject);
var
  offBelow,onAbove : single;
  i:integer;
  lastVal,currentVal : single;
  lastState,currentState : boolean;
  startTime,lastTime,currentTime : TDateTime;
  duration : integer;
begin
  try
    offBelow := StrToFloat(edtOffBelow.text);
    onAbove := StrToFloat(edtOnAbove.text);
  except
    showmessage('Off Below: and On Before: must be numbers');
    exit;
  end;
  PageControl1.ActivePageIndex:=1;
  lbOutput.Clear;
  Chart2LineSeries1.clear;
  lastVal := meterReads[0].CH2;     // setup initial values
  lastState := lastVal > onAbove;
  currentState:=lastState;
  startTime := meterReads[0].TS;
  lastTime := startTime;
  duration := 0;
  lbOutput.Items.Add('"Timestamp","State"');
  lbOutput.Items.Add('"'+datetimetostr(meterReads[0].TS)+'","'+BoolToOnOff(currentState)+'"');
  Chart2LineSeries1.AddXY(duration,BoolToInt(currentState));

  for i := 1 to length(meterReads)-1 do begin     // loop through the rest
    currentVal := meterReads[i].CH2;
    currentTime := meterReads[i].TS;
    If calcState(currentVal,offBelow,onAbove,currentState) then begin               { TODO : fix time stamp for map - either times or minutes in a duration field }
      // we have a defined state
      if currentState <> lastState then begin// level change event
        duration := calcDurationMins(lastTime,currentTime);
        lbOutput.Items.Add('"'+datetimetostr(meterReads[i].TS)+'","'+BoolToOnOff(currentState)+'"');
        duration := calcDurationMins(startTime,currentTime);
        Chart2LineSeries1.AddXY(duration,BoolToInt(currentState));
      end;
      lastVal := currentVal;
      lastState := currentState;
      lastTime := currentTime;
    end
    else begin
         // we are in an undefined state, so ignore the reading
    end;
  end;
end;

procedure TForm1.btnRemoveClick(Sender: TObject);
begin
  // remove selected item
end;

procedure TForm1.btnWriteCsvClick(Sender: TObject);
var
  fileName : string;
begin
  fileName := 'mooshistate'+dateTimeToStr(Now)+'.csv';
  lbOutput.Items.SaveToFile(fileName);
end;

function TForm1.calcState(const value, lowLimit, highLimit: single; var currentState:boolean): boolean;
begin
  currentState := false;
  result := true;
  if value > highLimit then
    currentState := true
  else if value < lowLimit then
    currentState := false
  else
    result := false;
end;

function TForm1.hasCommas(line: string): boolean;
begin
  result := false;
  if pos(',',line) > 0 then result := true;
end;

procedure TForm1.extractData(const line: string; var col1, col2, col3: string);
var
  valList : TstringList;
begin
  valList := TstringList.create;
  try
    valList.Delimiter := ',';
    valList.StrictDelimiter := true;
    valList.DelimitedText:=line;
    col1 := valList[0];
    col2 := valList[1];
    col3 := valList[2];
  finally
    valList.free;
  end;
end;

procedure TForm1.logLine(logString: string);
begin
  lbLogging.Items.Append(DateTimeToStr(now) + ' ' + logString);
end;


end.

