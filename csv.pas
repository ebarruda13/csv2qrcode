unit csv;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

type
  { TCsv }
  TCsv = class
  private
    FCampo: Integer;
    FRegistro: Integer;
    FArquivo: String;
    FErro: Boolean;
    FErroMensagem: String;
    FDelimitadorCampo: String;
    FDelimitadorTexto: String;
    FConteudo: TStringList;
    procedure SetCampo(const Valor: Integer);
    procedure SetRegistro(const Valor: Integer);
    procedure SetArquivo(const Valor: String);
  public
    property Campo: Integer read FCampo write SetCampo;
    property Registro: Integer read FRegistro write SetRegistro;
    property Arquivo: String read FArquivo write SetArquivo;
    property Erro: Boolean read FErro;
    property ErroMensagem: String read FErroMensagem;
    property DelimitadorCampo: String read FDelimitadorCampo write FDelimitadorCampo;
    property DelimitadorTexto: String read FDelimitadorTexto write FDelimitadorTexto;
    property Conteudo: TStringList read FConteudo;

    constructor create;
    destructor Destroy; override;

    function LinhasQuantidade: Integer;
    function ValorCampoRegistro(PCampo, PRegistro: Integer): String;
  end;

implementation

{ TCsv }

constructor TCsv.Create;
begin
  FErro             := false;
  FCampo            := -1;
  FRegistro         := -1;
  FArquivo          := '';
  FDelimitadorCampo := ';';
  FDelimitadorTexto := '';
  FConteudo         := TStringList.Create;
end;

destructor TCsv.Destroy;
begin
  inherited;

  if Assigned(FConteudo) then FreeAndNil(FConteudo);
end;

procedure TCsv.SetRegistro(const Valor: Integer);
begin
  if (Valor > FConteudo.Count - 1) then
    FRegistro := -1
  else
    FRegistro := Valor;
end;

procedure TCsv.SetCampo(const Valor: Integer);
var
  Linha: String;
  Contador, Indice: Integer;
begin
  if (FRegistro < 0) or (Valor < 1) then
  begin
    FCampo := 1;
  end
  else
  begin
    Linha := FConteudo.Strings[FRegistro];

    if Copy(Linha, Length(Linha), 1) <> Copy(FDelimitadorCampo, 1, 1) then Linha := Linha + FDelimitadorCampo;

    if Length(Linha) = 0 then
    begin
      FCampo := 1;
    end
    else
    begin
      Contador := 0;

      for Indice := 1 to Length(Linha) do
      begin
        if Linha[Indice] = FDelimitadorCampo then Inc(Contador);
      end;

      if Valor > Contador then
        FCampo := 1
      else
        FCampo := Valor;
    end;
  end;
end;

procedure TCsv.SetArquivo(const Valor: String);
begin
  if FArquivo <> Valor then
  begin
    FArquivo := Valor;

    try
      FConteudo.LoadFromFile(FArquivo);

      FErro         := false;
      FErroMensagem := '';
    except
      FErro         := true;
      FErroMensagem := 'Erro ao carregar arquivo';
    end;

    if FConteudo.Count > 0 then
    begin
      FCampo    := 0;
      FRegistro := 0;
    end
    else
    begin
      FCampo    := -1;
      FRegistro := -1;
    end;
  end;
end;

function TCsv.LinhasQuantidade: Integer;
begin
  Result := FConteudo.Count;
end;

function TCsv.ValorCampoRegistro(PCampo, PRegistro: Integer): String;
var
  Linha, Valor: String;
  Indice, Contador: SmallInt;
begin
  if Length(FDelimitadorCampo) = 0 then FDelimitadorCampo := ';';

  if PRegistro > FConteudo.Count - 1 then
  begin
    FErro         := true;
    FErroMensagem := 'Número de registro inválido';
    Result        := '';
  end
  else
  begin
    Linha := FConteudo.Strings[PRegistro];

    if (Length(Linha) > 0) or (PCampo > 0) then
    begin
      if Copy(Linha, Length(Linha), 1) <> Copy(FDelimitadorCampo, 1, 1) then Linha := Linha + FDelimitadorCampo;

      Valor    := '';
      Contador := 0;

      for Indice := 1 to Length(Linha) do
      begin
        if Linha[Indice] = FDelimitadorCampo then begin
          Inc(Contador);

          if Contador = PCampo then Break;

          Valor := '';
        end else begin
          Valor := Valor + Linha[Indice];
        end;
      end;

      if Contador < PCampo then Valor := '';

      if Length(FDelimitadorTexto) > 0 then
      begin
        if Copy(FDelimitadorTexto, 1, 1) = Copy(Valor, 1, 1)then Delete(Valor, 1, 1);
        if Copy(FDelimitadorTexto, 1, 1) = Copy(Valor, Length(Valor), 1) then Delete(Valor, Length(Valor), 1);
      end;

      Result := Valor;
    end
    else
    begin
      Result := '';
    end;

    FErro         := false;
    FErroMensagem := '';
  end;
end;

end.

