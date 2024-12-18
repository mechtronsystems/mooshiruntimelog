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
    btnAbout: TButton;
    btnAnalyse: TButton;
    btnClear: TButton;
    btnLoad: TButton;
    btnProcess: TButton;
    btnRemove: TButton;
    btnView: TButton;
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
    edtClip: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    lblCh2Max: TLabel;
    lblCH1Min: TLabel;
    lblCh1Max: TLabel;
    lblCH2Min: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label8: TLabel;
    lbFiles: TListBox;
    lblCH1Units: TLabel;
    lblCH2Units: TLabel;
    lbLogging: TListBox;
    lbOutput: TListBox;
    OpenDialog1: TOpenDialog;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    rgChannel: TRadioGroup;
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    Splitter3: TSplitter;
    Splitter4: TSplitter;
    Splitter5: TSplitter;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    tbNumBins: TTrackBar;
    procedure btnAboutClick(Sender: TObject);
    procedure btnAnalyseClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnProcessClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure btnViewClick(Sender: TObject);
    procedure btnWriteCsvClick(Sender: TObject);
    procedure rgChannelClick(Sender: TObject);
  private
    bins: array of integer;
    binMax: array of single;
    meterReads: array of TMeterRead;
    function hasCommas(line : string) : boolean;
    function extractData(const line : string; var col1,col2,col3 : string):integer;
    procedure LoadArrayFromFile(var maxVal1, minVal1, maxVal2, minVal2 : single);
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
  dateutils, memoFormu, aboutformu;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  lbFiles.Clear;
end;

procedure TForm1.LoadArrayFromFile(var maxVal1, minVal1, maxVal2, minVal2 : single);
var
  i,j : integer;
  myFileName : string;
  lineTime,lineValA,lineValB : string;
  myFile : TStringList = nil;
  paramcount : integer =0;
  goodLines, badLines, totLines : integer;
  logTime : TDateTime;
  CH1val, CH2val : single;
begin
  goodLines := 0;
  badLines := 0;
  totLines := 0;
  maxVal1 := 0;
  minVal1 := maxint;
  maxVal2 := 0;
  minVal2 := maxint;
  PageControl1.ActivePageIndex:=0;

  for i := 0 to length(meterReads) -1 do begin  // clean up the meter read objects
    meterReads[i].free;
  end;
  setlength(meterReads,0);

  // Create an array of TMeterRead's
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
        // show the mooshimeter data in the logs, board id etc
        // get the measurement type fields
        if hasCommas(myFile[j]) then begin   // check for data lines with commas
          inc(goodLines);
          paramcount:=extractData(myFile[j],lineTime,lineValA,lineValB);
          if paramcount =3 then begin
            if j=7 then begin // we should be on the data lines header
              lblCH1Units.Caption :=LineValA;
              lblCH2Units.Caption :=LineValB;
              logLine(myFile[j]);
            end;
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
              if CH1val > maxVal1 then
                maxVal1 := CH1val;
              if CH1Val < minVal1 then
                minVal1 := CH1val;
              if CH2val > maxVal2 then
                maxVal2 := CH2val;
              if CH2Val < minVal2 then
                minVal2 := CH2val;
              setlength(meterReads,length(meterReads)+1);  // make the array one bigger
              meterReads[length(meterReads)-1] := TMeterRead.create;
              meterReads[length(meterReads)-1].TS := logTime;
              meterReads[length(meterReads)-1].CH1 := CH1val;
              meterReads[length(meterReads)-1].CH2 := CH2val;
            end;
          end else begin
            logLine('Incorrect param count for line '+IntToStr(j));
          end;
        end
        else begin
          inc(badLines);
        end;
      end;
      logLine(intTostr(goodlines) + ' good and ' + IntToStr(badLines) + ' bad lines');
      logLine('Ch1Min: ' + FloatToStr(minVal1) + 'Ch1Max ' + FloatToStr(maxVal1));
      logLine('Ch2Min: ' + FloatToStr(minVal2) + 'Ch2Max ' + FloatToStr(maxVal2));
      edtCH1Min.Text:=FloatToStr(minVal1);
      edtCH1Max.Text:=FloatToStr(maxVal1);
      edtCH2Min.Text:=FloatToStr(minVal2);
      edtCH2Max.Text:=FloatToStr(maxVal2);
    end;
  finally
    myFile.Free;
  end;
end;

procedure TForm1.btnAnalyseClick(Sender: TObject);
var
  i,j : integer;
  maxVal1, minVal1, maxVal2, minVal2, span, spanInc : single;
  clipVal : integer;
  numBins : integer;
  UsingCh2 : boolean;
  meterRead: Single;
begin
  maxVal1 := 0;
  minVal1 := maxint;
  maxVal2 := 0;
  minVal2 := maxint;
  PageControl1.ActivePageIndex:=0;
  UsingCh2:=rgChannel.ItemIndex=1;

  LoadArrayFromFile(maxVal1, minVal1, maxVal2, minVal2);
  // we have an array of TMeterRead's and are finished with the files
  numBins := tbNumBins.Position;
  setLength(bins,0);
  setlength(bins,numBins);  // setup to find the distributions of the readings, there should be 2 clusters
  setLength(binMax,0);
  setLength(binMax,numBins);

  if not UsingCh2 then
    span := maxVal1 - minVal1  // ch1 find the incremental values for the bin maximums
  else
    span := maxVal2 - minVal2;  // ch2 find the incremental values for the bin maximums
  spanInc := span / numBins;
  for i := 0 to NumBins -1 do begin      // load up the max values for the bins
    binmax[i] := ((i+1) * spanInc) + minVal1;
  end;

  for i := 0 to length(meterReads) -1 do begin
    if not UsingCh2 then
      meterRead:=meterReads[i].CH1
    else
      meterRead:=meterReads[i].CH2;
    for j := 0 to numBins -1 do begin
      if meterRead < binmax[j] then begin
        inc(bins[j]);
        break;
      end;
    end;
  end;

  logLine(intToStr(bins[0])+', '+intToStr(bins[1])+', '+intToStr(bins[2])+', '+intToStr(bins[3])+', '+intToStr(bins[4])+', '+intToStr(bins[5])+', '+intToStr(bins[6])+', '+intToStr(bins[7])+', '+intToStr(bins[8])+', '+intToStr(bins[9]));
  Chart1BarSeries1.Clear;
  try
    clipVal := strToInt(edtClip.text);
  except
    clipVal := 0;
    showMessage('Clip value must be an integer');
  end;
  for i := 0 to length(bins)-1 do
    if (clipVal > 0) and (bins[i]>clipVal) then // populate the chart
      Chart1BarSeries1.AddXY(binMax[i],clipVal)
    else
      Chart1BarSeries1.AddXY(binMax[i],bins[i]);
end;

procedure TForm1.btnAboutClick(Sender: TObject);
begin
  aboutform.showmodal;
end;

function CompareFileNames(List: TStringList; Index1, Index2: Integer): Integer;  // return -ve: 1<2, 0: 1=2, +ve: 1>2
var
  fileName1, Filename2 : string;
  logPos1, logPos2 : integer;
  dashPos1, dashPos2 : integer;
  logId1, logId2 : integer;
begin
  fileName1 := extractFileName(List[Index1]);
  filename2 := extractFileName(List[Index2]);
  logPos1 := pos('Log',fileName1);
  logPos2 := pos('Log',fileName2);
  fileName1 := copy(fileName1,logPos1+3);
  fileName2 := copy(fileName2,logPos2+3);
  dashPos1 := pos('-',fileName1);
  dashPos2 := pos('-',fileName2);
  logId1 := strToInt(copy(fileName1,0,dashPos1-1));       // find and extract the log number
  logId2 := strToInt(copy(fileName2,0,dashPos2-1));       // find and extract the log number
  result := logId1-logId2;
end;

procedure TForm1.btnLoadClick(Sender: TObject);
var
  i : integer;
  slFiles : TStringList;
begin
  if OpenDialog1.execute then begin
    slFiles := TStringList.create;
    try
      for i := 0 to OpenDialog1.Files.Count -1 do
        slFiles.Add(OpenDialog1.Files.Strings[i]);
      slFiles.CustomSort(@CompareFileNames);
      lbFiles.clear;
      for i:= 0 to slFiles.Count-1 do
        lbFiles.items.Add(slFiles[i]);
    finally
      slFiles.free;
    end;
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
    if rgChannel.ItemIndex=0 then
      currentVal := meterReads[i].CH1
    else
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
  lbfiles.Items.Delete(lbFiles.ItemIndex);// remove selected item
end;

procedure TForm1.btnViewClick(Sender: TObject);
begin
  if lbFiles.ItemIndex > -1 then begin
    memoForm := TmemoForm.Create(application);
    try
      memoForm.fileName:=lbfiles.Items[lbfiles.ItemIndex];
      memoForm.showmodal;
    finally
      FreeAndNil(memoForm);
    end;
  end;
end;

procedure TForm1.btnWriteCsvClick(Sender: TObject);
var
  fileName : string;
begin
  fileName := 'mooshistate'+dateTimeToStr(Now)+'.csv';
  lbOutput.Items.SaveToFile(fileName);
end;

procedure TForm1.rgChannelClick(Sender: TObject);
begin
  if (Sender as TRadioGroup).ItemIndex = 0 then begin
    edtCH1Max.Enabled:= true;
    edtCH1min.Enabled:= true;
    lblCH1Min.Enabled:= true;
    lblCh1Max.Enabled:= true;
    lblCH1Units.Enabled:= true;
    edtCH2Max.Enabled:= false;
    edtCH2min.Enabled:= false;
    lblCH2Min.Enabled:= false;
    lblCh2Max.Enabled:= false;
    lblCH2Units.Enabled:= true;
  end
  else begin
    edtCH1Max.Enabled:= false;
    edtCH1min.Enabled:= false;
    lblCH1Min.Enabled:= false;
    lblCh1Max.Enabled:= false;
    lblCH1Units.Enabled:= true;
    edtCH2Max.Enabled:= true;
    edtCH2min.Enabled:= true;
    lblCH2Min.Enabled:= true;
    lblCh2Max.Enabled:= true;
    lblCH2Units.Enabled:= true;
  end;
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

function TForm1.extractData(const line: string; var col1, col2, col3: string): integer;
var
  valList : TstringList;
begin
  result:=0;
  valList := TstringList.create;
  try
    valList.Delimiter := ',';
    valList.StrictDelimiter := true;
    valList.DelimitedText:=line;
    result:=valList.count;
    if valList.count=3 then begin
      col1 := valList[0];
      col2 := valList[1];
      col3 := valList[2];
    end else begin
      col1 :='';
      col2 :='';
      col3 :='';
    end;
  finally
    valList.free;
  end;
end;

procedure TForm1.logLine(logString: string);
begin
  lbLogging.Items.Append(DateTimeToStr(now) + ' ' + logString);
end;


end.

