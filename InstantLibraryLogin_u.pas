unit InstantLibraryLogin_u;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Colors, InstantLibraryMain_u;

type
  TfrmInstantLibLogin = class(TForm)
    ColorButton1: TColorButton;
    lblEnterLib: TLabel;
    procedure ColorButton1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmInstantLibLogin: TfrmInstantLibLogin;

implementation

{$R *.fmx}

procedure TfrmInstantLibLogin.ColorButton1Click(Sender: TObject);
begin
  //Display Main Form + Load Booklist on show of the screen
  with frmInstantLibMain do
    begin
      Show;
      tbcMain.ActiveTab := tbiViewList;
      //Load txtfile content to respected arrays
      SeriesAndAuthorOnly;
      BooksArrayLoad;

      //Display the Booklist
      DisplayWholeList;
    end;// with frmInstantLibMain
  frmInstantLibLogin.Hide;
end;

procedure TfrmInstantLibLogin.FormShow(Sender: TObject);
begin
  frmInstantLibMAin.Hide;
end;

end.
