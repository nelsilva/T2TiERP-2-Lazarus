{ *******************************************************************************
Title: T2Ti ERP
Description: Janela para armazenar os tipos de documentos do GED

The MIT License

Copyright: Copyright (C) 2016 T2Ti.COM

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

The author may be contacted at:
t2ti.com@gmail.com</p>

@author Albert Eije (T2Ti.COM)
@version 2.0
******************************************************************************* }
unit UGedTipoDocumento;

interface

uses
  BrookHTTPClient, BrookFCLHTTPClientBroker, BrookHTTPUtils, BrookUtils, FPJson, ZDataset,
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UTelaCadastro, Menus, StdCtrls, ExtCtrls, Buttons, Grids, DBGrids,
  ComCtrls, LabeledCtrls, rxdbgrid, rxtoolbar, DBCtrls, StrUtils,
  Math, Constantes, CheckLst, ActnList, ToolWin, ShellApi, db, BufDataset, Biblioteca,
  ULookup, VO;

  type

  TFGedTipoDocumento = class(TFTelaCadastro)
    BevelEdits: TBevel;
    EditNome: TLabeledEdit;
    EditTamanhoMaximo: TLabeledCalcEdit;
    procedure FormCreate(Sender: TObject);
    procedure BotaoConsultarClick(Sender: TObject);
    procedure BotaoSalvarClick(Sender: TObject);
  private
    { Private declarations }
    procedure GridParaEdits; override;

    // Controles CRUD
    function DoInserir: Boolean; override;
    function DoEditar: Boolean; override;
    function DoExcluir: Boolean; override;
    function DoSalvar: Boolean; override;
  public
    { Public declarations }
  end;

implementation

uses GedTipoDocumentoVO, GedTipoDocumentoController, Tipos;
{$R *.lfm}

{$REGION 'Infra'}
procedure TFGedTipoDocumento.BotaoConsultarClick(Sender: TObject);
var
  RetornoConsulta: TZQuery;
  ListaCampos: TStringList;
  i: integer;
begin
  inherited;

  if Sessao.Camadas = 2 then
  begin
    Filtro := MontaFiltro;

    CDSGrid.Close;
    CDSGrid.Open;
    ConfiguraGridFromVO(Grid, ClasseObjetoGridVO);

    ListaCampos  := TStringList.Create;
    RetornoConsulta := TGedTipoDocumentoController.Consulta(Filtro, IntToStr(Pagina));
    RetornoConsulta.Active := True;

    RetornoConsulta.GetFieldNames(ListaCampos);

    RetornoConsulta.First;
    while not RetornoConsulta.EOF do begin
      CDSGrid.Append;
      for i := 0 to ListaCampos.Count - 1 do
      begin
        CDSGrid.FieldByName(ListaCampos[i]).Value := RetornoConsulta.FieldByName(ListaCampos[i]).Value;
      end;
      CDSGrid.Post;
      RetornoConsulta.Next;
    end;
  end;
end;

procedure TFGedTipoDocumento.BotaoSalvarClick(Sender: TObject);
begin
  inherited;
  BotaoConsultarClick(Sender);
end;

procedure TFGedTipoDocumento.FormCreate(Sender: TObject);
begin
  ClasseObjetoGridVO := TGedTipoDocumentoVO;
  ObjetoController := TGedTipoDocumentoController.Create;

  inherited;
end;
{$ENDREGION}

{$REGION 'Controles CRUD'}
function TFGedTipoDocumento.DoInserir: Boolean;
begin
  Result := inherited DoInserir;

  if Result then
  begin
    EditNome.SetFocus;
  end;
end;

function TFGedTipoDocumento.DoEditar: Boolean;
begin
  Result := inherited DoEditar;

  if Result then
  begin
    EditNome.SetFocus;
  end;
end;

function TFGedTipoDocumento.DoExcluir: Boolean;
begin
  if inherited DoExcluir then
  begin
    try
      Result := TGedTipoDocumentoController.Exclui(IdRegistroSelecionado);
    except
      Result := False;
    end;
  end
  else
  begin
    Result := False;
  end;

  if Result then
    BotaoConsultar.Click;
end;

function TFGedTipoDocumento.DoSalvar: Boolean;
begin
  Result := inherited DoSalvar;

  if Result then
  begin
    try
      if not Assigned(ObjetoVO) then
        ObjetoVO := TGedTipoDocumentoVO.Create;

      TGedTipoDocumentoVO(ObjetoVO).IdEmpresa := Sessao.Empresa.Id;
      TGedTipoDocumentoVO(ObjetoVO).Nome := EditNome.Text;
      TGedTipoDocumentoVO(ObjetoVO).TamanhoMaximo := EditTamanhoMaximo.Value;

      if StatusTela = stInserindo then
      begin
        TGedTipoDocumentoController.Insere(TGedTipoDocumentoVO(ObjetoVO));
      end
      else if StatusTela = stEditando then
      begin
        TGedTipoDocumentoController.Altera(TGedTipoDocumentoVO(ObjetoVO));
      end;
    except
      Result := False;
    end;
  end;
end;
{$ENDREGION}

{$REGION 'Controle de Grid'}
procedure TFGedTipoDocumento.GridParaEdits;
var
  IdCabecalho: String;
begin
  inherited;
  if not CDSGrid.IsEmpty then
  begin
    IdCabecalho := IntToStr(IdRegistroSelecionado);
    ObjetoVO := TGedTipoDocumentoController.ConsultaObjeto('ID=' + IdCabecalho);
  end;

  if Assigned(ObjetoVO) then
  begin
    EditNome.Text := TGedTipoDocumentoVO(ObjetoVO).Nome;
    EditTamanhoMaximo.Value := TGedTipoDocumentoVO(ObjetoVO).TamanhoMaximo;

    // Serializa o objeto para consultar posteriormente se houve alterações
    FormatSettings.DecimalSeparator := '.';
    StringObjetoOld := ObjetoVO.ToJSONString;
    FormatSettings.DecimalSeparator := ',';
  end;
end;
{$ENDREGION}

end.

