unit InstantLibraryMain_u;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Colors, FMX.ListView,
  FMX.Layouts, FMX.ListBox, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  Androidapi.Helpers, Androidapi.JNI.GraphicsContentViewText, Androidapi.JNI.JavaTypes
  , Androidapi.JNIBridge, System.IOUtils, FMX.Edit, FMX.DialogService;

type
  TfrmInstantLibMain = class(TForm)
    tbcMain: TTabControl;
    tbiViewList: TTabItem;
    memViewList: TMemo;
    ListBox1: TListBox;
    tbiEditList: TTabItem;
    edtSearchAuthor: TEdit;
    SearchEdtBtnAuthor: TSearchEditButton;
    memEditList: TMemo;
    ListBox2: TListBox;
    Button1: TButton;
    edtSeriesName: TEdit;
    edtAuthor: TEdit;
    pnlToolbar: TPanel;
    btnEditList: TCornerButton;
    btnAdd: TCornerButton;
    edtBookName: TEdit;
    btnAddLibrary: TCornerButton;
    chkIsStandAlone: TCheckBox;
    chkAlreadyRead: TCheckBox;
    btnSaveToList: TCornerButton;
    btnFinalizeLibrary: TCornerButton;
    btnDeleteItems: TCornerButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure btnLoadClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnClearClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnModClick(Sender: TObject);
    procedure btntestClick(Sender: TObject);
    procedure tbiEditListClick(Sender: TObject);
    procedure btnAddLibraryClick(Sender: TObject);
    procedure chkIsStandAloneChange(Sender: TObject);
    procedure edtBookNameEnter(Sender: TObject);
    procedure edtAuthorEnter(Sender: TObject);
    procedure edtBookNameClick(Sender: TObject);
    procedure edtAuthorClick(Sender: TObject);
    procedure btnEditListClick(Sender: TObject);
    procedure btnSaveToListClick(Sender: TObject);
    procedure edtSearchAuthorClick(Sender: TObject);
    procedure btnFinalizeLibraryClick(Sender: TObject);
    procedure SearchEdtBtnAuthorClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    procedure LoadBookList;  //-->  Assited code using ChatGPT
    procedure SaveBookList;
    //procedure AddBook;
    procedure DeleteBook;
    procedure DeleteSelectedText;
    procedure SeriesAndAuthorOnly;  //--> From Here is it my code
    procedure BooksArrayLoad;
    procedure DisplayWholeList;
    procedure SaveWholeList;
    procedure AddToLibrary;
    procedure SaveListChanges;
    procedure LoadCurrentBookdetailsToEdit;
    procedure OverwriteEditedDetails ( sChange : string);
    function FindBookCorrespondingAuthor( sLine : string ) : string;
    function CountArraySeriesAndAuthor : integer;
    function SearchForBookSeries(sBook : string) : string;

end;

var
  frmInstantLibMain: TfrmInstantLibMain;
  iStartUp, iBookMax : integer;
  tfBooklist : textfile;
  arrBooks : array[1..100, 1..4] of string;
  arrSeriesAndAuthor : array[1..100, 1..3] of string;
  sBooklistFile, sSeriesName, sEditBookDetails : string;
  SeriesAuthor, BookAndAuthor : TStringlist;
  bEditlist : boolean;

implementation

{$R *.fmx}

uses
  InstantLibraryLogin_u;

procedure TfrmInstantLibMain.AddToLibrary;
  var sCheck : string;
  bSeriesDone : boolean;
begin
  //Check if the book is read
  if chkAlreadyRead.IsChecked = true then sCheck := '[x]' else sCheck := '[_]';

  //Check if a new book relates to the series
  if sSeriesName = edtSeriesName.Text then
    begin
      memEditList.Lines.Add(sCheck + ' ' +edtBookName.Text);
    end//if it is not related
  else
    begin
      memEditList.Lines.Add(edtSeriesName.Text + ' - ' + edtAuthor.Text);
      memEditList.Lines.Add(sCheck + ' ' + edtBookName.Text);
    end;

  //Assign series to var.
  sSeriesName := edtSeriesName.Text;

end;

procedure TfrmInstantLibMain.BooksArrayLoad;
  var
  sLine, sFirstChar, sBook, sAuthor : string;
  i, iCount, r, iPosAt, iPosComma : integer;
  bAuthor : boolean;
begin
  //Intailize VAR
  i := 0;
  iCount := 0;
  r := 0;
  bAuthor := false;

  //Will load the book names in a array --> Main function of this code
  BookAndAuthor := TStringList.Create;
  if not FileExists(sBooklistFile) then exit;

  //If the file is found
  try
    BookAndAuthor.LoadFromFile(sBooklistfile);
    for i := 0 to BookAndAuthor.Count -1 do
      begin
        //Assign sLine the value of current stringlist loop-counter index
        sLine := BookAndAuthor[i];

        //Check if it end of series/stand alone book
        if sLine = '//;' then
          begin
            //Resets Author var. to add a new series
            sAuthor := '';
            bAuthor := false;
          end;

        //Get Books series if there is
        if bAuthor = false then
          begin
            sAuthor := FindBookCorrespondingAuthor(sLine);
            if sAuthor <> '' then bAuthor := true;
          end; //if false

        //Get sLine first character
        sFirstChar := Copy(sLine, 1, 1);

        //Check if string is a book
        if sFirstChar = '-' then
          begin
            //Load book + Author in array
            inc(r);
            iPosComma := POS(',', sLine);
            arrBooks[r, 1] := trim(Copy(sLine, 2, iPosComma -2));
            arrBooks[r, 2] := sAuthor;
            Delete(sLine, 1, iPosComma + 1);
            arrBooks[r, 3] := trim(sLine);
          end;//if string is a book

      end; //for i


  finally
     BookAndAuthor.Free;
  end; // try se end

end;

procedure TfrmInstantLibMain.btnAddClick(Sender: TObject);
begin
  //Give permission to add to list
  bEditList := false;
  edtSeriesName.Enabled := true;
  edtBookName.Enabled := true;
  edtAuthor.Enabled := true;
  chkISStandAlone.Enabled := true;
  chkAlreadyRead.Enabled := true;
  btnAddLibrary.Enabled := true;
  btnSaveToList.Enabled := true;

  //Update edits text
  edtseriesName.Text := 'Enter series name here';
  edtBookName.Text := 'Enter book name here';
  edtAuthor.Text := 'Enter author name here';

  //Set focus to first option
  chkIsStandAlone.SetFocus;
end;

procedure TfrmInstantLibMain.btnAddLibraryClick(Sender: TObject);
  var sSeries : string;
begin
  //Valadation of the input for edits
  //Series
  if (trim(edtSeriesName.Text) = '') or ((edtSeriesName.Text) = 'Enter series name here')  then
    begin
      Showmessage('Enter series name please.');
      exit;
    end;

  //Book
  if (trim(edtBookName.Text) = '') or ((edtBookName.Text) = 'Enter book name here') then
    begin
      Showmessage('Enter book name please.');
      exit;
    end;

  //Author
  if (trim(edtAuthor.Text) = '') or ((edtAuthor.Text) = 'Enter author name here') then
    begin
      Showmessage('Enter book name please.');
      exit;
    end;

  //Determine which procedure will be followed
  AddToLibrary;
end;

procedure TfrmInstantLibMain.btnClearClick(Sender: TObject);
begin
  memViewList.Lines.Clear;
end;

procedure TfrmInstantLibMain.btnModClick(Sender: TObject);
begin
  LoadBookList;
end;

procedure TfrmInstantLibMain.btnDeleteClick(Sender: TObject);
begin
  DeleteSelectedText
end;

procedure TfrmInstantLibMain.btnEditListClick(Sender: TObject);
  var iCursorPos : integer;
begin
  //Give permission to edit to list
  bEditList := true;
  edtSeriesName.Enabled := true;
  edtBookName.Enabled := true;
  edtAuthor.Enabled := true;
  chkISStandAlone.Enabled := true;
  chkAlreadyRead.Enabled := true;
  btnAddLibrary.Enabled := false;
  btnSaveToList.Enabled := true;

  //Load the book of the current position of the curser to the edits
  LoadCurrentBookdetailsToEdit;

  //Load the details to the sBooksDetails var
  sEditBookDetails := edtSeriesName.Text +','+ edtBookName.Text + '@' + edtAuthor.Text;

  //Giving the user instruction on how to proceed
  memEditList.Lines.Add('Select the book/series that you want to change.'+
  'Make your changes and please press the save changes option after you made the changes.');
end;

procedure TfrmInstantLibMain.btnFinalizeLibraryClick(Sender: TObject);
begin
  //Close the edit tools and give feedback to the user
  bEditList := false;
  edtSeriesName.Enabled := false;
  edtBookName.Enabled := false;
  edtAuthor.Enabled := false;
  chkISStandAlone.Enabled := false;
  chkAlreadyRead.Enabled := false;
  btnAddLibrary.Enabled := false;
  btnSaveToList.Enabled := false;
  showmessage('Library is finalized and up to date. Returning to your library.');

  //Return user to main list
  tbcMain.ActiveTab := tbiViewList;
end;

procedure TfrmInstantLibMain.btnLoadClick(Sender: TObject);
begin
  //Load txtfile content to respected arrays
  SeriesAndAuthorOnly;
  BooksArrayLoad;

  //Display the Booklist
  DisplayWholeList;
end;

procedure TfrmInstantLibMain.btnSaveToListClick(Sender: TObject);
  var AddBooksToLibrary : TStringlist;
   i, iPosComma, iPosAt, iCurserPos, iCurrentLine : integer;
   sNewSeriesName, sNewBookName, sNewAuthor, sOldSeries, sOldBookName, sOldAuthor, sLine, sCheck : string;
begin
  btnFinalizeLibrary.Enabled := true;
  if bEditList = false then  //---> if the list in add mode
    begin
      //Create the stringlist
      AddBooksToLibrary := TStringList.Create;

      try
        //Loop through memEditList to add the new content to the stringlist
        for i := 0 to memEditList.Lines.Count -1 do
          begin
            AddBooksToLibrary.Add(memEditList.Lines[i]);
          end;//for i

        //re-intialize i
        i := 0;

        //Adding the content of the stringlist to the "mainlist"
        memViewList.Lines.Add('');
        for i := 0 to AddBooksToLibrary.Count -1 do
          begin
            memViewList.Lines.Add(AddBooksToLibrary[i]);
          end;// re-intialized for i

      finally
        AddBooksToLibrary.Free;
      end; //try

      //Save the new added items to the txtfile
      SaveWholeList;
      SeriesAndAuthorOnly;
      BooksArrayLoad;
      showmessage('Your library has been updated.');
    end
  else  //----> if it is edit mode
    begin
      //Extract the old content of the lines
      iPosComma := POS(',', sEditBookDetails);
      sOldSeries := Copy(sEditBookdetails, 1, iPosComma -1);
      Delete(sEditBookDetails, 1, iPosComma);
      iPosAt := POS('@', sEditBookDetails);
      sOldBookName := Copy(sEditBookDetails, 1, iPosAt -1);
      Delete(sEditBookDetails, 1, iPosAt);
      sOldAuthor := sEditBookDetails;

      //Assign the changes to a var group
      sNewSeriesName := trim(edtSeriesName.Text);
      sNewBookName := trim(edtBookName.Text);
      sNewAuthor := trim(edtAuthor.Text);

      //Determine what was changed and make the change
      if sOldSeries <> sNewSeriesName then
        begin// if Series was changed
          //Find the active line + the content
          iCurserPos := memViewList.CaretPosition.Pos;
          iCurrentLine := memViewList.CaretPosition.Line;

          //Replace the old value with the new one
          memViewList.Lines[iCurrentLine] := sNewSeriesName + ' - ' + sOldAuthor;

        end;
      if sOldBookName <> sNewBookName then
        begin // if Book was changed
          //Find the active line + the content
          iCurserPos := memViewList.CaretPosition.Pos;
          iCurrentLine := memViewList.CaretPosition.Line;

          //Replace the old value with the new one
          if chkAlreadyRead.IsChecked then sCheck := 'x' else sCheck := '_';
          memViewList.Lines[iCurrentLine] := '[' + sCheck +']' + ' ' + sNewBookName;

        end;
      if sOldAuthor <> sNewAuthor then
        begin//if Author was changed
          //Find the active line + the content
          iCurserPos := memViewList.CaretPosition.Pos;
          iCurrentLine := memViewList.CaretPosition.Line;

          //Replace the old value with the new one
          memViewList.Lines[iCurrentLine] := sOldSeries + ' - ' + sNewAuthor;
        end;

      //Save the newly changed list + Update Arrays
      SaveWholeList;
      SeriesAndAuthorOnly;
      BooksArrayLoad;
      showmessage('Your library has been updated.');
    end;

end;

procedure TfrmInstantLibMain.btntestClick(Sender: TObject);
begin
  //Load txtfile content to respected arrays
   SeriesAndAuthorOnly;
   BooksArrayLoad;

   //Display the Booklist
   DisplayWholeList;
end;

procedure TfrmInstantLibMain.Button1Click(Sender: TObject);
begin
  //Load txtfile content to respected arrays
   SeriesAndAuthorOnly;
   BooksArrayLoad;

   //Display the Booklist
   DisplayWholeList;
end;

procedure TfrmInstantLibMain.chkIsStandAloneChange(Sender: TObject);
begin
  //Set text to acording to the status of the checkbox
  if chkIsStandAlone.IsChecked = false then
    begin
      edtSeriesName.Text := 'Enter Series Name';
      edtSeriesName.Enabled := true;
      edtSeriesName.SetFocus;
    end
  else
    begin
      edtSeriesName.Text := 'Not applicable here';
      edtSeriesName.Enabled := false;
      edtBookname.SetFocus;
    end;
end;

function TfrmInstantLibMain.CountArraySeriesAndAuthor: integer;
  var i, iCount : integer;
begin
  //Will count all the indexes in the array that has a value in
  iCount := 0;
  for i := 1 to 100 do
  begin
    if (arrSeriesAndAuthor[i, 1] <> '') and (arrSeriesAndAuthor[i, 2] <> '') then inc(iCount);
  end;
  //Will send Counted integer back a result
  Result := iCount;
end;

procedure TfrmInstantLibMain.DeleteBook;
begin

end;

procedure TfrmInstantLibMain.DeleteSelectedText;  //maybe uithaal want kan anders delete
begin
  if memViewlist.SelLength > 0 then
  begin
    memViewlist.SelText.Empty; // Replace selected text with an empty string
    ShowMessage('Selected text deleted.');
  end
  else
    ShowMessage('No text selected.');
end;

procedure TfrmInstantLibMain.DisplayWholeList;
  var i, r, iLoops : integer;
  bSeriesDone : boolean;
begin
  //Intailize VAR
  r := 0;
  iLoops := CountArraySeriesAndAuthor;

  //Will display both arrays with their respected series books
  for i := 1 to iLoops do
    begin
      //Will addd the series and authir to memoViewlist
      bSeriesDone := false;
      memViewlist.Lines.Add(arrSeriesAndAuthor[i, 1] + ' - ' + arrSeriesAndAuthor[i, 2]);

      //For loop to find the series's books
      while bSeriesDone = false do
        begin
          inc(r);
          //Checks if Series + Book Author is equal
          if arrSeriesAndAuthor[i, 2] = arrBooks[r, 2] then
            begin
              // Check if book is read, to determine how the [ ] going to look
              if arrBooks[r, 3] = 'true' then memViewList.Lines.Add('[x] ' + arrBooks[r, 1]) else memViewList.Lines.Add('[ ] ' + arrBooks[r, 1]);

              //Check if series is still running
              if arrSeriesAndAuthor[i, 2] <> arrBooks[r + 1, 2] then bSeriesDone := true else bSeriesDone := false;

            end;//if Series + Book Auhtor =

        end;//while <> true

    end;// for i

end;

procedure TfrmInstantLibMain.edtAuthorClick(Sender: TObject);
begin
  edtAuthor.SetFocus;
end;

procedure TfrmInstantLibMain.edtAuthorEnter(Sender: TObject);
begin
  edtAuthor.SetFocus;
end;

procedure TfrmInstantLibMain.edtBookNameClick(Sender: TObject);
begin
  edtBookName.SetFocus;
end;

procedure TfrmInstantLibMain.edtBookNameEnter(Sender: TObject);
begin
  edtBookName.SetFocus;
end;

procedure TfrmInstantLibMain.edtSearchAuthorClick(Sender: TObject);
begin
  //Highlight search box
  edtSearchAuthor.SetFocus;
end;

function TfrmInstantLibMain.FindBookCorrespondingAuthor(sLine: string): string;
  var r, iPosAt : integer;
  bFound : boolean;
begin
  //Intialize
  r := 0;
  iPosAt := 0;
  bFound := false;

  //Edit sLine to match the arrays way of storing
  iPosAt := POS('@', sLine);
  sLine := trim(Copy(sLine, 2, iPosAt -2 ));

  //Search in array for sereis author
  for r := 1 to 100 do
    begin
      if sLine = arrSeriesAndAuthor[r, 1] then
        begin
          Result :=  arrSeriesAndAuthor[r, 2];
          exit;
        end;//if sLine =

    end;//for r

end;

procedure TfrmInstantLibMain.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  memViewlist.Lines.Clear;
  tbcMain.ActiveTab := tbiViewList;;
end;

procedure TfrmInstantLibMain.FormCreate(Sender: TObject);
begin
  //Intailize Global VAR
  iStartUp := 0;
  sSeriesName := '';

  //Access the internal storage of phone for file
  sBookListFile := TPath.Combine(TPath.GetDocumentsPath, 'Booklist.txt');

  //If the file is not found, it creates a list
  if FileExists(sBookListFile) <> true then TFile.WriteAllText(sBookListFile, 'Booklist.txt'); // Create an empty file
end;

procedure TfrmInstantLibMain.FormShow(Sender: TObject);
begin
  //Makes main form disapear on starup of app
  inc(iStartUp);
  if iStartUp = 1 then
    begin
      frmInstantLibMain.Hide;
      frmInstantLibLogin.Show;
    end;
end;

procedure TfrmInstantLibMain.LoadBookList;
  var
  BookNames: TStringList;
  sBook: string;
begin
   BookNames := TStringList.Create;
  try
    BookNames.LoadFromFile(sBookListFile);
    memViewList.Lines.Clear;
    for sBook in BookNames do
      memViewList.Lines.Add(sBook);
  finally
    BookNames.Free;
  end;
end;

procedure TfrmInstantLibMain.LoadCurrentBookdetailsToEdit;
  var iCurserPos, i, iPosComma, iPosDash, iCurrentLine : integer;
  sLine, sBook, sSeries, sAuthor, sCheckMark : string;
begin
  //Intailize
  iCurserPos := 0;
  iPosComma := 0;
  iPosDash := 0;
  iCurrentLine := 0;
  sLine := '';

  //Get Curser Pos and the active line
  iCurserPos := memViewList.CaretPosition.Pos;
  iCurrentLine := memViewList.CaretPosition.Line;
  sLine := memViewList.Lines[iCurrentLine];

  //Check the content to determine if the line is a book or a series then
  if sLine[1] <> '[' then
    begin
      //Break up into series and author
      iPosDash := POS('-', sLine);
      sSeries := Copy(sLine, 1, iPosDash -1);
      Delete(sLine, 1, iPosDash +1);
      sAuthor := sLine;
      sBook := 'Book is not selected';
      edtBookName.Enabled := false;
    end//if it is the series and author line
  else
    begin
      edtBookName.Enabled := true;
      //Get Book Name
      sBook := trim(Copy(sLine, 4, Length(sLine)));

      //Get Read Status
      sCheckMark := Copy(sLine, 2, 1);

      //Search for Book's series
      sLine := SearchForBookSeries(sBook);

      //Break up into the series and author
      iPosComma := POS(',', sLine);
      sSeries := Copy(sLine, 1, iPosComma -1);
      Delete(sLine, 1, iPosComma );
      sAuthor := sLine;
    end;//if it is the book line

  //Load the content to the edit
  if sSeries <> '' then chkIsStandAlone.IsChecked := false else chkISStandAlone.IsChecked := true;
  edtSeriesName.Text := sSeries;
  edtbookName.Text := sBook;
  edtAuthor.Text := sAuthor;
  if sCheckMark = 'x' then chkAlreadyRead.IsChecked := true else chkAlreadyRead.IsChecked := false;

  //Add the content to the string for further use

end;

procedure TfrmInstantLibMain.OverwriteEditedDetails(sChange: string);
  var iCurserPos, iCurrentLine : integer;
  sLine : string;
begin
  //Find the active line + the content
  iCurserPos := memViewList.CaretPosition.Pos;
  iCurrentLine := memViewList.CaretPosition.Line;

  //Replace the old value with the new one
  memViewList.Lines[iCurrentLine] := sChange;
end;

procedure TfrmInstantLibMain.SaveBookList;
var  BookNames: TStringList;
  I: Integer;
begin
   BookNames := TStringList.Create;
  try
    for I := 0 to memViewlist.Lines.Count - 1 do
      BookNames.Add(memViewlist.Lines[I]);
    BookNames.SaveToFile(sBookListFile);
    ShowMessage('Book list saved!');
  finally
    BookNames.Free;
  end;
end;

procedure TfrmInstantLibMain.SaveListChanges;
begin

end;

procedure TfrmInstantLibMain.SaveWholeList;
  var BooklistTxt : TStringlist;
  i, iPosDash, iLeng : integer;
  sLine : string;
  bread : boolean;
begin
  //intailize VAR
  bRead := false;

  //Create the stringlist
  BooklistTxt := TStringList.Create;
  try
     //Loop through the memo's content
  for i := 0 to memViewList.Lines.Count -1 do
    begin
      //Assign value to sLine to ensure the txtfile's format is correct for next use
      sLine := memViewList.Lines[i];

      //Checks if it is a series line or book line
      if (sLine[1] <> '[') or (sLine <> '') then
        begin
          Insert('*', sLine, 1);
          iPosDash := POS('-', sLine);
          Insert('@', sLine, iPosDash +1);
          Delete(sLine, POS('-',sLine), 1);
          Delete(sLine, POS('@', sLine) +1, 1);
        end//if series + author line
      else
        begin
          //Check status of book
          if sLine[2] = 'x' then bRead := true else bRead := false;

          //Get book name
          iLeng := length(sLine);
          Delete(sLine, 3, iLeng);

          //Construct the correct format
          sLine := sLine + ', ' + BoolToStr(bRead);

        end; //if book line


      //Checks for space
      if sLine = '' then
        begin
          sLine := '//;';
        end;

      //Send sLine to the stringlist
      BookListTxt.Add(sLine);

      //Save to the txtfile
      BooklistTxt.SaveToFile(sBookListFile);

    end;//for i

  finally
    Booklisttxt.Free;

  end; //try

end;

procedure TfrmInstantLibMain.SearchEdtBtnAuthorClick(Sender: TObject);
  var sSearch : string;
  i : integer;
begin
  //Assign searched title to VAR
  sSearch := edtSearchAuthor.Text;

  //Loop through array to find the author
  for i := 1 to 100 do
    begin
      if sSearch = arrSeriesAndAuthor[i, 2] then
        begin
          //Add the series and the author
          //Search for the Auhtor in the book
        end; // if Search =

    end;

end;

function TfrmInstantLibMain.SearchForBookSeries(sBook: string): string;
  var i, j : integer;
   sSeries, sAuthor : string;
begin
  //Search for the author first
  for i := 1 to 100 do
    begin
      if arrBooks[i, 1] = sBook then
        begin
          sAuthor := arrBooks[i, 2];
          //Search for the series
          for j := 1 to 100 do
            begin
              if sAuthor = arrSeriesAndAuthor[j, 2] then
                begin
                  sSeries := arrSeriesAndAuthor[j, 1];
                end;//if Author's align

            end;//for j

        end;//if the books align

    end;//for i

  //Send Series and Author back
  Result := sSeries + ',' + sAuthor;
end;

procedure TfrmInstantLibMain.SeriesAndAuthorOnly;
  var
  sSeries, sAuthor, sFirstChar, sLine : string;
  i, r, iPosAt, iCount, iSeries : integer;
begin
  //Intailize VAR
  r := 0;
  iCount := 0;
  iSeries := 0;

  //Will load the Series Name and the author in a array
  SeriesAuthor := TStringList.Create;
  if not FileExists(sBooklistFile) then exit;

  //If the file is found
  try
    SeriesAuthor.LoadFromFile(sBooklistfile, TEncoding.UTF8);

    //Loop through stringlist to sort
    for i := 0 to SeriesAuthor.Count - 1 do
      begin
        sLine := SeriesAuthor[i];
        sFirstChar := Copy(sLine, 1, 1);
        if sFirstChar = '*' then
          begin
            //Increase r for the row in the array
            inc(r);

            //Seperate series and the author + add seperately to array
            iPosAt := Pos('@', sLine);
            sSeries := trim(Copy(sLine, 2, iPosAt -2));
            arrSeriesAndAuthor[r, 1] := sSeries;
            Delete(sLine, 1, iPosAt);
            arrSeriesAndAuthor[r, 2] := sLine;
            inc(iCount);

            //Increase the "PK" value
            inc(iSeries);

            //Assign a "PK" to the Series;
            arrSeriesAndAuthor[r, 3] := inttostr(iSeries);

          end;//if *

      end;//for i

  finally
    SeriesAuthor.Free;
  end;

end;

procedure TfrmInstantLibMain.SpeedButton1Click(Sender: TObject);
begin
  LoadBookList;
end;

procedure TfrmInstantLibMain.SpeedButton2Click(Sender: TObject);
begin
 SaveBooklist;
end;

procedure TfrmInstantLibMain.tbiEditListClick(Sender: TObject);
begin
  //Display the book's details depending on where the curser is in the viewlist
  if bEditList = true then LoadCurrentBookdetailsToEdit;
end;

end.
