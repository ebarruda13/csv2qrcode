unit csv2qrcode_formprincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ComCtrls,
  ExtCtrls, Spin, qrencode, csv;

type

  { TFormPrincipal }

  TFormPrincipal = class(TForm)
    ButtonQrcodeRegistro: TButton;
    ButtonQrcodeTodosRegistros: TButton;
    ButtonVoltaCampo: TButton;
    ButtonAvancaCampo: TButton;
    ButtonCarregarArquivoCsv: TButton;
    CheckBoxIgnorarPrimeiraLinha: TCheckBox;
    ComboBoxDelimitadorCampo: TComboBox;
    ComboBoxNivelCorrecaoErro: TComboBox;
    ComboBoxDelimitadorTexto: TComboBox;
    EditPrefixoNomeArquivo: TEdit;
    EditCampo: TEdit;
    EditCsv: TEdit;
    ImageQRcode: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    ListBoxCsv: TListBox;
    OpenDialogCsv: TOpenDialog;
    PageControlQRcode: TPageControl;
    SaveDialogBmp: TSaveDialog;
    SelectDirectoryDialogQRcode: TSelectDirectoryDialog;
    SpinEditImagemDimensao: TSpinEdit;
    StatusBarQRcode: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure ButtonQrcodeRegistroClick(Sender: TObject);
    procedure ButtonQrcodeTodosRegistrosClick(Sender: TObject);
    procedure ButtonAvancaCampoClick(Sender: TObject);
    procedure ButtonCarregarArquivoCsvClick(Sender: TObject);
    procedure ButtonVoltaCampoClick(Sender: TObject);
    procedure CheckBoxIgnorarPrimeiraLinhaChange(Sender: TObject);
    procedure ComboBoxDelimitadorCampoChange(Sender: TObject);
    procedure ComboBoxDelimitadorTextoChange(Sender: TObject);
    procedure ComboBoxNivelCorrecaoErroChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure ListBoxCsvClick(Sender: TObject);
  private
  public
    Csv: TCsv;
    PrimeiraLinha: SmallInt;
    NivelCorrecaoErro: SmallInt;
  end;

var
  FormPrincipal: TFormPrincipal;

implementation

{$R *.lfm}

{ TFormPrincipal }

procedure TFormPrincipal.FormCreate(Sender: TObject);
begin
  FormPrincipal.Top  := 100;
  FormPrincipal.Left := 100;

  Csv := TCsv.Create;

  PrimeiraLinha     := 1;
  NivelCorrecaoErro := 0;

  PageControlQRcode.ActivePageIndex := 0;
end;

procedure TFormPrincipal.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Csv.Free;
end;

procedure TFormPrincipal.ButtonCarregarArquivoCsvClick(Sender: TObject);
begin
  if OpenDialogCsv.Execute then
  begin
    EditCsv.Text := OpenDialogCsv.FileName;

    Csv.Arquivo := EditCsv.Text;

    ListBoxCsv.Items.Assign(Csv.Conteudo);
  end;
end;

procedure TFormPrincipal.ButtonAvancaCampoClick(Sender: TObject);
begin
  if ListBoxCsv.ItemIndex > PrimeiraLinha - 1 then
  begin
    Csv.Campo      := Csv.Campo + 1;
    EditCampo.Text := Csv.ValorCampoRegistro(Csv.Campo, ListBoxCsv.ItemIndex);
  end
  else
  begin
    EditCampo.Text := '';
  end;
end;

procedure TFormPrincipal.ButtonVoltaCampoClick(Sender: TObject);
begin
  if ListBoxCsv.ItemIndex > PrimeiraLinha - 1 then
  begin
    Csv.Campo      := Csv.Campo - 1;
    EditCampo.Text := Csv.ValorCampoRegistro(Csv.Campo, ListBoxCsv.ItemIndex);
  end
  else
  begin
    EditCampo.Text := '';
  end;
end;

procedure TFormPrincipal.CheckBoxIgnorarPrimeiraLinhaChange(Sender: TObject);
begin
  PrimeiraLinha := StrToIntDef(BoolToStr(CheckBoxIgnorarPrimeiraLinha.Checked, '1', '0'), 0);
end;

procedure TFormPrincipal.ComboBoxDelimitadorCampoChange(Sender: TObject);
begin
  Csv.DelimitadorCampo := ComboBoxDelimitadorCampo.Text;
end;

procedure TFormPrincipal.ComboBoxDelimitadorTextoChange(Sender: TObject);
begin
  Csv.DelimitadorTexto := ComboBoxDelimitadorTexto.Text;
end;

procedure TFormPrincipal.ComboBoxNivelCorrecaoErroChange(Sender: TObject);
begin
  NivelCorrecaoErro := ComboBoxNivelCorrecaoErro.ItemIndex;
end;

procedure TFormPrincipal.ListBoxCsvClick(Sender: TObject);
begin
  if ListBoxCsv.ItemIndex > PrimeiraLinha - 1 then
  begin
    EditCampo.Text := Csv.ValorCampoRegistro(1, ListBoxCsv.ItemIndex);
  end;
end;

procedure TFormPrincipal.ButtonQrcodeRegistroClick(Sender: TObject);
var
  Retangulo: TRect;
  QRcode: TQRcode;
  TmpBmp: TBitmap;
begin
  if ListBoxCsv.ItemIndex > PrimeiraLinha - 1 then
  begin
    QRcode := TQRCode.Create();

    try
      Retangulo := Rect(0, 0, SpinEditImagemDimensao.Value, SpinEditImagemDimensao.Value);

      case NivelCorrecaoErro of
        0: QRcode.EcLevel := QR_ECLEVEL_L;
        1: QRcode.EcLevel := QR_ECLEVEL_M;
        2: QRcode.EcLevel := QR_ECLEVEL_Q;
        3: QRcode.EcLevel := QR_ECLEVEL_H;
      end;

      if Length(Csv.DelimitadorTexto) > 0 then
        QRcode.Text := StringReplace(ListBoxCsv.Items.Strings[ListBoxCsv.ItemIndex], Csv.DelimitadorTexto, '', [rfReplaceAll, rfIgnoreCase])
      else
        QRcode.Text := ListBoxCsv.Items.Strings[ListBoxCsv.ItemIndex];

      ImageQRcode.Picture.Bitmap.Height      := SpinEditImagemDimensao.Value;
      ImageQRcode.Picture.Bitmap.Width       := SpinEditImagemDimensao.Value;
      ImageQRcode.Canvas.Brush.Color         := clWhite;
      ImageQRcode.Picture.Bitmap.PixelFormat := pf24bit;

      ImageQRcode.Canvas.FillRect(Retangulo);

      QRcode.Paint(ImageQRcode.Canvas, Retangulo);

      Retangulo := Rect(0, 0, QRcode.BmpWidth, QRcode.BmpWidth);

      ImageQRcode.Picture.Bitmap.Height := QRcode.BmpWidth;
      ImageQRcode.Picture.Bitmap.Width  := QRcode.BmpWidth;

      QRcode.Paint(ImageQRcode.Canvas, Retangulo);

      TmpBmp := TBitmap.Create;

      TmpBmp.Width  := SpinEditImagemDimensao.Value;
      TmpBmp.Height := SpinEditImagemDimensao.Value;

      Retangulo := Rect(0, 0, SpinEditImagemDimensao.Value, SpinEditImagemDimensao.Value);

      TmpBmp.Canvas.StretchDraw(Retangulo, ImageQRcode.Picture.Bitmap);

      ImageQRcode.Picture.Bitmap.Assign(TmpBmp);

      SaveDialogBmp.FileName := EditPrefixoNomeArquivo.Text + Csv.ValorCampoRegistro(1, ListBoxCsv.ItemIndex) + '.bmp';

      if SaveDialogBmp.Execute then
      begin
        ImageQRcode.Picture.SaveToFile(SaveDialogBmp.FileName);
      end;
    finally
      TmpBmp.Free;
      QRcode.Free;
    end;
  end;
end;

procedure TFormPrincipal.ButtonQrcodeTodosRegistrosClick(Sender: TObject);
var
  Indice: Integer;
  Retangulo: TRect;
  QRcode: TQRcode;
  TmpBmp: TBitmap;
begin
  if (ListBoxCsv.Items.Count > PrimeiraLinha) and SelectDirectoryDialogQRcode.Execute then
  begin
    QRcode := TQRCode.Create();
    TmpBmp := TBitmap.Create;

    case NivelCorrecaoErro of
      0: QRcode.EcLevel := QR_ECLEVEL_L;
      1: QRcode.EcLevel := QR_ECLEVEL_M;
      2: QRcode.EcLevel := QR_ECLEVEL_Q;
      3: QRcode.EcLevel := QR_ECLEVEL_H;
    end;

    ImageQRcode.Picture.Bitmap.Height      := SpinEditImagemDimensao.Value;
    ImageQRcode.Picture.Bitmap.Width       := SpinEditImagemDimensao.Value;
    ImageQRcode.Canvas.Brush.Color         := clWhite;
    ImageQRcode.Picture.Bitmap.PixelFormat := pf24bit;

    try
      for Indice := PrimeiraLinha to ListBoxCsv.Items.Count - 1 do
      begin
        ListBoxCsv.ItemIndex := Indice;

        Retangulo := Rect(0, 0, SpinEditImagemDimensao.Value, SpinEditImagemDimensao.Value);

        ImageQRcode.Canvas.FillRect(Retangulo);

        if Length(Csv.DelimitadorTexto) > 0 then
          QRcode.Text := StringReplace(ListBoxCsv.Items.Strings[ListBoxCsv.ItemIndex], Csv.DelimitadorTexto, '', [rfReplaceAll, rfIgnoreCase])
        else
          QRcode.Text := ListBoxCsv.Items.Strings[ListBoxCsv.ItemIndex];

        QRcode.Paint(ImageQRcode.Canvas, Retangulo);

        Retangulo := Rect(0, 0, QRcode.BmpWidth, QRcode.BmpWidth);

        ImageQRcode.Picture.Bitmap.Height := QRcode.BmpWidth;
        ImageQRcode.Picture.Bitmap.Width  := QRcode.BmpWidth;

        QRcode.Paint(ImageQRcode.Canvas, Retangulo);

        TmpBmp.Width  := SpinEditImagemDimensao.Value;
        TmpBmp.Height := SpinEditImagemDimensao.Value;

        Retangulo := Rect(0, 0, SpinEditImagemDimensao.Value, SpinEditImagemDimensao.Value);

        TmpBmp.Canvas.StretchDraw(Retangulo, ImageQRcode.Picture.Bitmap);

        ImageQRcode.Picture.Bitmap.Assign(TmpBmp);

        ImageQRcode.Picture.SaveToFile(IncludeTrailingPathDelimiter(SelectDirectoryDialogQRcode.FileName) + EditPrefixoNomeArquivo.Text + Csv.ValorCampoRegistro(1, ListBoxCsv.ItemIndex) + '.bmp');
      end;
    finally
      QRcode.Free;
      TmpBmp.Free;
    end;
  end;
end;

end.

